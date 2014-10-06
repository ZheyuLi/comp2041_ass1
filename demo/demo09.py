#!/usr/bin/python

import sys
a = [1,3,5,7]
for x in range(0,2):
    for y in 'potato':
        for z in a[0:1]:
            print x
            print y
            print z
        continue
    break
print "All tests passed :)"