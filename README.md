# SubCopy 2
Version 2 of SubCopy, rewritten in Swift.

SubCopy allows a user to easily extract all the files from a directory tree:

```
Directory/
 - File1
 - Dir1/
    - File2
    - File3
 - Dir2/
    - Dir3/
       - File4
```
Will become:
```
Destination/
 - File1
 - File2
 - File3
 - File4
```

Users can also choose to not copy certain files based on their extension.

As usual (Although SubCopy is the first) blogs for each commit can be found at [my site](http://andrewmwalls.wordpress.com/).
