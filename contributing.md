This guide is work in progress and will be updated.

# Contributing

#Required software
You will need a working copy of DCS to enhance Skynet.

#Design philosophy

#Versioning
Skynet uses semantic versioning.

# setting up your editor
I recomend you use [!notepad++](https://notepad-plus-plus.org/downloads/) to edit lua files.

Add this line to functionList.xml located here YourDrive:\Users\%HOMEDIR%\AppData\Roaming\Notepad++

```lua
<association id="lua_function" langID="23" />
```

```lua


			<parser
				displayName="Lua w/o Class"
				id         ="lua_function"
				commentExpr="(?x)                                               # free-spacing (see `RegEx - Pattern Modifiers`)
								(?s:                                            # Multi Line Comment
									(?&lt;!-)-{2}                               # - start-of-comment indicator with
									\x5B(?'MLCLVL'=*)\x5B                       #   ...specific level
									.*?                                         # - whatever, until
									\x5D\k'MLCLVL'\x5D                          # - end-of-comment indicator of equal level
								)
							|	(?m-s:-{2}.*$)                                  # Single Line Comment
							|	(?s-m:                                          # String Literal
									=\s*
									\x5B(?'SLLVL'=*)\x5B                        # - start-of-string indicator with specific level
									.*?                                         # - whatever, until
									\x5D\k'SLLVL'\x5D                           # - end-of-string indicator of equal level
								)
							"
			>
				<function
					mainExpr="(?x)                                              # free-spacing (see `RegEx - Pattern Modifiers`)
							(?m)                                                # ^ and $ match at line-breaks
							(?:
								^\h*                                            # optional leading white-space at start-of-line
								(?-i:local\s+)?
								(?-i:function)
								\s+[A-Za-z_]\w*
								(?:\.[A-Za-z_]\w*)*
								(?::[A-Za-z_]\w*)?
							|
								\s*[A-Za-z_]\w*
								(?:\.[A-Za-z_]\w*)*
								\s*=
								\s*(?-i:function)
							)
							\s*\([^()]*\)
						"
				>
					<functionName>
						<nameExpr expr="(?&lt;=\bfunction\b)\s+[A-Za-z_][\w.:]*\s*\(|[A-Za-z_][\w.]*\s*=" />
						<nameExpr expr="[A-Za-z_][\w.:]*" />
					</functionName>
				</function>
			</parser>
```
Source: https://community.notepad-plus-plus.org/topic/15662/help-function-list-doesn-t-support-my-language/12