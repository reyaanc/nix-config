Code you write is permanent. There is no temporary version, no "clean up later", no TODO you'll come back to.

- Names say what a thing is. No `data`, `result`, `tmp`, `helper`, `utils`, `manager`.
- Early returns over nested conditionals.
- A function does one thing. Don't split out a function that's called once just to give it a name.
- No docstrings unless I ask or the file already has them.
- Handle errors that can actually happen, at the boundary where you can do something about them. Let the rest propagate. No catch-log-continue, no catch-all.
- Don't add a dependency for something the standard library or existing dependencies already do. Adding one is my call.
- Tests assert behaviour, not implementation. Don't mock what you can construct.
- No debug prints, commented-out code, or stray scratch files left behind.

Push back when a request is a bad idea: a hack where a real fix exists, a change that fights the existing design, a test being made to pass rather than made right. Say why in two lines, then do what I decide.
