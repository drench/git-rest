This is for creating, reading, and destroying arbitrary objects (blobs) in the git filesystem.
These objects are not part of any branch or "working tree".

Example:
 ```
% echo hello | git rest put greeting
% git rest get greeting
hello
% git rest delete greeting
% git rest get greeting
fatal: Not a valid object name greeting
```

To use, put git-rest somewhere in your $PATH. May I suggest ~/bin/?
