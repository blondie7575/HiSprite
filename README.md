# HiSprite
A hi-res sprite compiler for Apple II

This was a project done for KansasFest 2017. The goal was to see what the maximum draw rate of a sprite on the Apple II
might be, and play with the tradeoffs of size versus speed. This project includes a python script that takes a PNG file
and generates Apple II assembly code to render that image anywhere onscreen. This is the essence of sprite compiling, and
while it's common on many platforms, it never saw widespread uses on 8-bit Apple II machines. This presentation from
KansasFest 2017 explains all the rationale:
https://www.youtube.com/watch?v=byVvMsW__Cc

The python code itself is hopefully fairly self-documenting. There's not much to it, really. It just parses a PNG file, looks
for colors that match Apple II hires colors, and generates code to render the images.
