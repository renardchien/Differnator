Differnator is Copyright (c) 2012 Cody Van De Mark. All Rights reserved.

Differnator
===========

Differnator is a tool for comparing two similar codebases leveraging diff command operations and other comparative operations. Differnator can do large scale comparisons across several directories or numerous pairs of similar codebases.


LICENSING
===========

  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


SYNOPSIS
===========

differnator [OPTIONS]... DIRECTORY1 DIRECTORY2


DESCRIPTION
===========

differnator allows you to do large diff operations with various controls and in batches. differnator was originally intended to produce usable
patches from two similar codebases. differnator offers you the abilities to copy non-existent files from one directory to another, to compare
which files exist or don't exist between two directories and do large scale "diff -u" operations between two directories. Directories can be
fed into differnator from an input file with two directories separated by a colon (with one colon pair per line). differnator can also allow
output to come out as a patch file. differnator allows options to output to files, append to files, do functions recursively and 
include/ignore hidden files.


OPTIONS
===========
-A * Append to output file- This requires a filename as an argument. If the file does not exist it will make one. If the file does exist, 
it will append to it

-c    Compare directories- This will determine which files exist or do not exist between two directories and list them. It will also list the 
names of files that differ between two directories

-d    Compare two codebases for differences- This will do a large diff against the files in two directories and print out the line by line
differences between files with headers for the name of each file. Use this with the -p (patch) flag in order to output a usuable 
patch file in the format of diff -u. Use this with -r (recursive) to do a full recursive comparison of the two directories.

-i    Include hidden files- This will include hidden files for operations. By default hidden files are ignored

-f    Input directories from file- This requires a filename as an argument. This will read directory pairs from a file instead of from the 
command line. It will read one pair per line separated by a colon. Otherwise this will fail. This means that colons can't be included
in the directory names.

Example of the contents of an input file

dirName1:dirName2   
dirName3:dirName4   
dirName4:dirName2   

-F    Force output (OVERWRITES OUTPUT FILE)- This requires a filename as an argument. This will output all data to a file. If the file does not exist it will make one. If the
file does exist, it will be overwritten. 

-n    Copy non-existent files from the first directory to the second directory- This will copy any files that exist in the first directory, but not 
in the second directory to the second directory. Use this with -r (Recursive) to copy folders as well. Otherwise it will only copy
files immediately in the first directory and will ignore subdirectories.

-p    Output as patch- This will remove all messages and all output from all operations except for -d (compare codebase differences) so
that output comes out as a usable patch. Use this with -o (output as file) to have all data go to a file as a usable patch. Otherwise
all data will just be dumped to the screen.

-o    Output as a file- This requires a filename as an argument. This will send all output to a file so that it is silent on the command line
unless there are fatal errors. If the file does not exist it will make a new file. If the file does not exist it will fail. Use -A (append)
or -F (force overwrite) to write to an existing file. 

-r    Recursive functionality- This will make all functions act recursively including subdirectories in their operations.

BUGS
===========

See https://github.com/renardchien/Differnator/issues for a current list of bugs or to file a new bug. 

Current Bugs
Hidden files are included with -c (compare directories) by default even without the -i (include hidden files) flag. This is due to the 
nature of the diff command. A solution has not been found.

Input files use a colon delimiter which means that directories can't have a colon in the name or else it will not work correctly. 
This is a limitation of differnator, but hopefully will be fixed in the future.

