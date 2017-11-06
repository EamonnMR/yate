# yate
Yet Another Template Engine
Did this for a job interview thing one time.

To run:

ruby yate.rb \<template.yate\> \<data.json\> \<output.html\>

Included: example.yate and example.json with some Lorem Ipsum to test with.

YATE is a template engine completed as a coding challenge.

Refactor ideas: turn the scope stack into a class, turn the parser into a class, do everything in one pass.

Remaining bugs: It's still adding <* ENDEACH *> nodes to the parse tree. Though this does not impact functionality, it's sort of gross.

Nice to haves: It would be cool if EACH/ENDEACH blocks left a comment block in place of an actual element to keep indentation nice.
