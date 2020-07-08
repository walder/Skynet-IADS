This guide is work in progress and will be updated.

# Contributing
Thanks for your interest in contributing to Skynet!
If you think you have a good idea on how to improve or enhance Skynet, please propose your idea on the [discord channel](https://discord.gg/ZEyp3g).
It's encuraged that you run your idea by the community before you spend time coding. This way you will get feedback on how the feature is perceived by the community 
and you also may get tips on how to best implement an enhancement.

#Versioning
Skynet uses [semantic versioning](https://semver.org/).

#Required software
You will need a working copy of DCS (Digital Combat Simulator) to contribute to Skynet development.

#Test first design philosophy
Skynet is developed with the [test first philosophy](https://resources.collab.net/agile-101/test-first-programming). Once you get the hang of it test first development is really great.
It may take a bit longer to develop a new feature but you will save a lot of time not having to test existing code after a small change. Writing unit tests also makes the code more modular and therefore understandable.

##Writing a unit test
Have a look at the existing unit tests to get an idea on how to write one yourself. Unit tests shall be added to the skynet-unit-tests.miz file.
Check the output of the dcs.log file for information whether the tests have passed or not. Please don't create a pull request with tests failing.


# setting up your editor
I recomend you use [notepad++](https://notepad-plus-plus.org/downloads/) to edit lua files.

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