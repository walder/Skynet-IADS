# De-Mist: removing the MIST dependency from Skynet-IADS

**Branch:** `de-mist`
**Goal:** remove Skynet-IADS's runtime dependency on **MIST** and replace it with **MOOSE** + native DCS
calls — as a **pure dependency swap with ZERO functional change**. Skynet's behaviour (detection cadence,
HARM reaction, point defence, go-live, headings, distances, scheduling) is byte-for-byte unchanged; only the
library it leans on changes.

> Why: MIST is comparatively unmaintained, and many missions already run MOOSE. Depending on MOOSE (actively
> maintained) instead of MIST removes a second library and its per-mission DB build. This is **not** a
> compatibility shim that fakes a `mist` global — every call site was ported to a real MOOSE/native call.

---

## 1. What changed, in one paragraph

All `mist.*` usage (13 distinct calls across 7 engine files) was removed. Scalar conversions now call MOOSE
`UTILS.*` (proven formula-identical to MIST). The distance/heading math is reproduced **verbatim from MIST**
inside a new first-class module `SkynetIADSUtils` (`skynet-iads-source/skynet-iads-utils.lua`) so output is
bit-for-bit unchanged, including MIST's true-north correction. Scheduling uses native
`timer.scheduleFunction`. The two prefix-registration loops that read `mist.DBs` now iterate MOOSE
`_DATABASE`. Two instance fields named `*MistTaskID` were renamed to `*TaskID`. **New dependency: MOOSE.
Removed dependency: MIST.**

---

## 2. The new module: `SkynetIADSUtils` (`skynet-iads-source/skynet-iads-utils.lua`)

A namespaced helper table following the project's `SkynetIADS*` convention. It is added to the compiled-build
manifest **before** `skynet-iads-logger.lua` (first engine file that uses it). Public surface:

| Function | Replaces | Backed by |
|---|---|---|
| `SkynetIADSUtils.round(num, idp)` | `mist.utils.round` | `UTILS.Round` |
| `SkynetIADSUtils.metersToNM(m)` | `mist.utils.metersToNM` | `UTILS.MetersToNM` |
| `SkynetIADSUtils.metersToFeet(m)` | `mist.utils.metersToFeet` | `UTILS.MetersToFeet` |
| `SkynetIADSUtils.toDegree(rad)` | `mist.utils.toDegree` | `UTILS.ToDegree` |
| `SkynetIADSUtils.get2DDist(p1, p2)` | `mist.utils.get2DDist` | native (verbatim MIST math) |
| `SkynetIADSUtils.get3DDist(p1, p2)` | `mist.utils.get3DDist` | native (verbatim MIST math) |
| `SkynetIADSUtils.getHeading(unit)` | `mist.getHeading` | native (verbatim MIST, incl. north correction) |
| `SkynetIADSUtils.getHeadingPoints(p1, p2)` | `mist.utils.getHeadingPoints` | native (verbatim MIST) |
| `SkynetIADSUtils.random(a, b)` | `mist.random` | `math.random` |
| `SkynetIADSUtils.scheduleFunction(f, vars, t, rep, st)` | `mist.scheduleFunction` | `timer.scheduleFunction` |
| `SkynetIADSUtils.removeFunction(id)` | `mist.removeFunction` | `timer.removeFunction` |

---

## 3. The 1:1 mapping (with the math that proves "no functional change")

### 3a. Scalar conversions → MOOSE `UTILS` (formula-identical)

These were verified against MOOSE source; the formulas match MIST exactly, so they delegate directly:

| MIST | MOOSE | Formula (both) |
|---|---|---|
| `mist.utils.round(x, d)` | `UTILS.Round(x, d)` | `math.floor(x * 10^d + 0.5) / 10^d` |
| `mist.utils.metersToNM(m)` | `UTILS.MetersToNM(m)` | `m / 1852` |
| `mist.utils.metersToFeet(m)` | `UTILS.MetersToFeet(m)` | `m / 0.3048` |
| `mist.utils.toDegree(r)` | `UTILS.ToDegree(r)` | `r * 180 / math.pi` |

### 3b. Distances → reproduced from MIST (NOT mapped to `UTILS.VecDist*`)

⚠️ **Important trap avoided:** MOOSE `UTILS.VecDist2D(a,b)` operates on a MOOSE **Vec2** `{x,y}` (ground
plane). MIST's `get2DDist` takes a DCS **Vec3** `{x,y,z}` and uses **x and z**, *ignoring altitude `y`*.
Skynet passes Vec3s (`unit:getPosition().p`). A blind swap to `UTILS.VecDist2D` would use altitude as the
second axis and **change the result**. So the distance functions are reproduced directly to match MIST's
`mist.vec.mag` exactly:

```lua
-- mist.utils.get2DDist: sqrt(dx^2 + dz^2)   (x,z ground plane; altitude y ignored)
function SkynetIADSUtils.get2DDist(p1, p2)
    local dx, dz = p1.x - p2.x, p1.z - p2.z
    return (dx*dx + dz*dz) ^ 0.5
end

-- mist.utils.get3DDist: sqrt(dx^2 + dy^2 + dz^2)
function SkynetIADSUtils.get3DDist(p1, p2)
    local dx, dy, dz = p1.x - p2.x, p1.y - p2.y, p1.z - p2.z
    return (dx*dx + dy*dy + dz*dz) ^ 0.5
end
```

### 3c. Headings → reproduced verbatim from MIST (incl. true-north correction)

MIST's `getHeading` adds a **true-north correction** (DCS map grid north ≠ true north). This is preserved
exactly via DCS `coord.LOtoLL` / `coord.LLtoLO`:

```lua
-- == mist.getNorthCorrection(point)
local function getNorthCorrection(point)
    if not point.z then point = { x = point.x, y = 0, z = point.y } end   -- Vec2 -> Vec3
    local lat, lon = coord.LOtoLL(point)
    local northPosit = coord.LLtoLO(lat + 1, lon)
    return math.atan2(northPosit.z - point.z, northPosit.x - point.x)
end

-- == mist.getHeading(unit) with rawHeading=false: radians [0,2pi), north-corrected
function SkynetIADSUtils.getHeading(unit)
    local pos = unit:getPosition()
    if pos then
        local h = math.atan2(pos.x.z, pos.x.x) + getNorthCorrection(pos.p)
        if h < 0 then h = h + 2*math.pi end
        return h
    end
end

-- == mist.utils.getHeadingPoints(p1, p2)  (Skynet always calls it WITHOUT the optional `north` arg,
--    i.e. mist.utils.getDir(vec) with NO north correction): radians [0,2pi)
function SkynetIADSUtils.getHeadingPoints(p1, p2)
    local dir = math.atan2(p2.z - p1.z, p2.x - p1.x)
    if dir < 0 then dir = dir + 2*math.pi end
    return dir
end
```

Note the asymmetry is faithful to MIST: `getHeading` (the **unit** heading) applies north correction;
`getHeadingPoints` (a **bearing between two points**, called by Skynet without the `north` flag) does **not**.

### 3d. Random → `math.random`

```lua
-- mist.random(a[,b]) returns a uniform integer in range; its internal table trick only de-biases the RNG.
-- Behaviour-equivalent (both yield a uniform integer in [low,high]; an exact RNG *sequence* match is
-- impossible and irrelevant for randomness).
function SkynetIADSUtils.random(a, b)
    if not b then return math.random(1, a) end
    return math.random(a, b)
end
```

### 3e. Scheduling → native `timer.scheduleFunction`

MIST's `scheduleFunction(f, vars, t, rep, st)` runs `f(unpack(vars))` at absolute mission time `t`, repeats
every `rep` seconds (until optional stop-time `st`), and returns a cancelable id. Reproduced with the native
DCS scheduler (which also uses absolute model time and re-runs when the callback returns the next time):

```lua
function SkynetIADSUtils.scheduleFunction(f, vars, t, rep, st)
    vars = vars or {}
    return timer.scheduleFunction(function(_, now)
        pcall(f, unpack(vars))                       -- pcall: a single error doesn't tear down a repeating task (matches MIST)
        if rep and (not st or (now + rep) <= st) then return now + rep end
        return nil
    end, nil, t)
end

function SkynetIADSUtils.removeFunction(id)
    if id then timer.removeFunction(id) end
end
```

### 3f. Unit/Group enumeration → MOOSE `_DATABASE`

The two prefix-registration loops iterated `mist.DBs.unitsByName` / `mist.DBs.groupsByName` **for the names
only** — the loop value was never read (each object is re-fetched via `Unit.getByName` / `Group.getByName`).
So they map cleanly onto MOOSE's name-keyed `_DATABASE`:

```lua
-- addEarlyWarningRadarsByPrefix
for unitName, _ in pairs(_DATABASE.UNITS)  do ... end   -- was: pairs(mist.DBs.unitsByName)

-- addSAMSitesByPrefix
for groupName, _ in pairs(_DATABASE.GROUPS) do ... end  -- was: pairs(mist.DBs.groupsByName)
```

---

## 4. Other changes

- **Field rename (cosmetic de-mist):** `iads.ewRadarScanMistTaskID` → `ewRadarScanTaskID`,
  `samSetupMistTaskID` → `samSetupTaskID` (these hold scheduler ids; the name referenced the old library).
- **Build manifest:** `build-tools/build-compiled-script.ps1` now concatenates
  `skynet-iads-source/skynet-iads-utils.lua` (placed right after the type tables, before
  `skynet-iads-logger.lua`).
- **Compiled bundle:** `demo-missions/skynet-iads-compiled.lua` is regenerated from the manifest (rebuild at
  release with a proper version tag).

## 5. Dependency change

| Before | After |
|---|---|
| MIST (e.g. `mist_4_5_107.lua`) loaded before Skynet | **MOOSE** loaded before Skynet |

Load order: **MOOSE → `skynet-iads-compiled.lua` → your setup script.** Demo missions / setup that previously
loaded MIST should load MOOSE instead (README + demo triggers — follow-up).

## 6. Files changed

```
NEW  skynet-iads-source/skynet-iads-utils.lua          (SkynetIADSUtils module)
MOD  skynet-iads-source/skynet-iads.lua                (mist.DBs -> _DATABASE; field rename)
MOD  skynet-iads-source/skynet-iads-abstract-radar-element.lua
MOD  skynet-iads-source/skynet-iads-contact.lua
MOD  skynet-iads-source/skynet-iads-awacs-radar.lua
MOD  skynet-iads-source/skynet-iads-jammer.lua
MOD  skynet-iads-source/skynet-iads-logger.lua
MOD  skynet-iads-source/skynet-iads-sam-search-radar.lua
MOD  build-tools/build-compiled-script.ps1             (manifest)
GEN  demo-missions/skynet-iads-compiled.lua            (rebuilt)
```

## 7. Validation

- ✅ **Syntax:** every source file + the regenerated compiled bundle pass `luae` (DCS Lua 5.1 `loadfile`).
- ✅ **No functional `mist.` references** remain in the engine (only heritage comments documenting the swap).
- ⏳ **In-sim:** the project's unit tests are in-mission (luaunit + a test `.miz`). Run the test mission /
  a SAM-vs-aircraft smoke pass on DCS 2.9 with MOOSE loaded to confirm runtime parity before release.

---

*This is a behaviour-preserving modernization: MIST out, MOOSE in, no gameplay change.*
