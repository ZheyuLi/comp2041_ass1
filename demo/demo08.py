#!/usr/bin/python

x = 1
y = 1
if x|y: print "true"
if x&y: print "true"
if x != y:
    print "false"
    x = y
print x