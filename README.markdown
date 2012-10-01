git-rest
========

This is for creating, reading, and destroying arbitrary objects (blobs) in the git filesystem.
These objects are not part of any branch or "working tree".

Example:

    % echo hello | git rest put greeting
    % git rest get greeting
    hello
    % git rest delete greeting
    % git rest get greeting
    fatal: Not a valid object name greeting

As git-rest's tags are not part of any tree, you will need to ask for them if you want to
come along in a git-fetch like so:

    % git fetch --tags

Better yet, tell git that you always want these kinds of tags:

    % git config remote.<REMOTENAME>.tagopt --tags
    % git fetch


To use, put git-rest somewhere in your $PATH. May I suggest ~/bin/?
