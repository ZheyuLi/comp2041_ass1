#!/usr/bin/python
import sys

k = 7
for i in range(5, k + 3):
    if i > 2:
        print
        if i < 100:
            print

        else:
            continue
    break
    print i
print "yes"