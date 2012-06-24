#!/bin/bash

#Copyright 2012 Cody Van De Mark
#GPLv3+
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

#VARIABLES TO SEE WHICH OPTIONS WERE ENABLED
APPEND=0;
COMPAREDIRS=0;
COMPAREFILES=0;
FROMFILE=0;
FORCE=0;
COPYFILE=0;
ASPATCH=0;
OUTPUT="";
OUTPUTFILE=0;
OUTPUTPARAM="t";
INPUT="";
RECURSIVE=0;
DIR1EMPTY=0;
DIR2EMPTY=0;
SHIFTOPT=1;
OPTERR=1;
DIR1="";
DIR2="";

#DISABLES HIDDEN FILES-SHOULD BE OFF BY DEFAULT
shopt -u dotglob;

#Function to copy files that exist only in directory A to directory B. This is only recursive if the recursive flag is enabled
function cp_dirs ()
{
	for entry in "$1"/*
	do
		items=`basename "$entry"`;
		if [ ! -f "$2/$items" ]; then
			if [ -w $2 ]; then
				if [ "$RECURSIVE" -eq 0 -a ! -d "$1/$items" ]; then
					cp "$1/$items" "$2/$items";
				elif [ "$RECURSIVE" -eq 1 ]; then
					cp -R "$1/$items" "$2/$items";
				fi
			else
				write_out "User does not have write permissions to $2";
			fi
		fi
	done
			
}

#Function to compare which files exist or do not exist between directory A and directory B. This will also list which files differ
#without showing the differences. This is only recursive if the recursive flag is enabled
function compare_dirs ()
{
	if [ "$RECURSIVE" -eq 0 -a -d "$1" -a -d "$2" ]; then
		DIFFOUT=`diff -q -u $1 $2`;
		write_out "$DIFFOUT";
	elif [ "$RECURSIVE" -eq 1 -a -d "$1" -a -d "$2" ]; then
		DIFFOUT=`diff -q -u -r $1 $2`;
		write_out "$DIFFOUT";
	fi
}

#Function to run diff -u across two directories with similar codebases. This will not be recursive unless the recursive flag is
#enabled. This will produce a large diff from all of the similar files.
function diff_compare ()
{
	for entry in "$1"/*
	do
		item="/"`basename "$entry"`;
		if [ -f "$2$item" -a ! -d "$1$item" ]; then
			diffs=`diff -u "$1$item" "$2$item"`;
	
			if [ -n "$diffs" ]; then

				write_out "\n\n=========================================="
				write_out "$item \n\n";

					force_out "$diffs";
			
			fi
		elif [ "$RECURSIVE" -eq 1 -a -d "$1$item" -a -d "$2$item" ]; then
			diff_compare "$1$item" "$2$item";
		fi
	done
}

#function to output to the terminal or a file. This overwrites write out in order to generate a patch
#All calls come from the write_out function, unless it's the diff_compare function will calls directly
#in order to generate a patch
function force_out ()
{
	if [ "$OUTPUTPARAM" == "t" ]; then
		echo -e "$*";
	else
		echo -e "$*" >> $OUTPUT;	
	fi
}

#function to call the force_out method for writing output to files/terminal/stdout unless the -p flag has been specified
function write_out ()
{
	if [ "$ASPATCH" -eq 0 ]; then
		force_out "$*";
	fi
}

#function to handle all error messages and clean exits. Warnings are handled within the functions that are producing the warning logic
#only errors that cause a fatal exit will call this function
function error_out ()
{
	if [ "$1" == "nf" ]; then
		echo "Directory $2 could not be found. Check path or permissions.";	
	elif [ "$1" == "ta" ]; then
		echo "differnator requires two arguments (directory pathes) to compare";
	elif [ "$1" == "no" ]; then
		echo "No output file specified. Please provide the output file name (Example: differnator -o output.txt )";
	elif [ "$1" == "ni" ]; then
		echo "No input file specified or input file does not exist. Please provide an appropriate input file (Example: differnator -f file.txt)";
	elif [ "$1" == "if" ]; then
		echo "Invalid flag included. Please enter a valid flag (case sensitive). Consult man pages for help." 
	elif [ "$1" == "ef" ]; then
		echo "The A, F and o flags are exclusive of one enough and cannot be combined. Only one of these flags make be used at a time"
	elif [ "$1" == "wd" ]; then
		echo "Output file cannot be a directory. Output file specified was $2";
	fi

	exit 65;
}

#Function to make sure all of the directories specified are valid directories and that the directories exist
function check_args ()
{
	if [ "$#" -ne 2 ]; then
		error_out "ta";
	fi

	if [ ! -d $1 ]; then
		error_out "nf" $1;
	fi

	if [ ! -d $2 ]; then
		error_out "nf" $2;
	fi

	if [ ! "$(ls -A $1)" ]; then
		write_out "Warning: Directory $1 is empty";
		DIR1EMPTY=1;
	fi
	if [ ! "$(ls -A $2)" ]; then
		write_out "Warning: Directory $2 is empty";
		DIR2EMPTY=1;
	fi

}

#function to check that the output file is a valid file and handle appending, overwriting or creating an output file
function check_output_file ()
{
	OUTPUT=$2;
	let SHIFTOPT="$SHIFTOPT + 1";

	if [ "$OUTPUT" == "" ]; then
		error_out "no";
	fi

	if [ -d $OUTPUT ]; then
		error_out "wd" $OUTPUT;
	fi
		
	if [ -f $OUTPUT ]; then
		if [ $1 == "o" ]; then
			echo "Output file already exists. \nIf you want to overwrite the file use -F instead of -o. \nIf you want to append to the file use -A instead of -F.";
			exit 65;
		elif [ $1 == "A" ]; then
			OUTPUTPARAM="A";
			write_out "Output file already exists, appending to $OUTPUT";
		elif [ $1 == "F" ]; then
			OUTPUTPARAM="F";
			write_out "Output file already exists, replacing $OUTPUT";
			echo "" > $OUTPUT;
		fi
	else
		OUTPUTPARAM="o";
		write_out "Writing out to $OUTPUT";
	fi

}

#function to check that the input file exists to read from
function check_input_file ()
{
	if [ ! -f $1 -o $1 == "" ]; then
		error_out "ni";
	else
		INPUT="$1";
	fi
	let SHIFTOPT="$SHIFTOPT + 1";	
}

#master function - function that executes all functionality depending on the flags specified
function execute ()
{
	if [ "$COMPAREDIRS" -eq 1 ]; then
		compare_dirs $1 $2; 
	fi

	if [ "$COMPAREFILES" -eq 1 ]; then
		diff_compare $1 $2;
	fi

	if [ "$COPYFILE" -eq 1 ]; then
		cp_dirs $1 $2;
	fi
}

#loop to get all operators (flags) from the command line
while getopts "A:cdif:F:npo:r" opt;
do
	case $opt in
	A) #append to file
		APPEND=1;
		if [ "$OUTPUTFILE" -eq 1 -o "$FORCE" -eq 1 ]; then
			error_out "ef";
		fi	
		check_output_file "A" $OPTARG;
	;;
	c) #compare directories
		COMPAREDIRS=1;
	;;
	d) #compare files in directories
		COMPAREFILES=1;
	;;
	i) #include hidden files
		shopt -s dotglob
	;;
	f) #compare directories from a file of directories
		FROMFILE=1;
		check_input_file $OPTARG;
	;;
	F) #force write to file (OVERWRITE EXISTING FILE)
		FORCE=1;
		if [ "$OUTPUTFILE" -eq 1 -o "$APPEND" -eq 1 ]; then
			error_out "ef";
		fi	
		check_output_file "F" $OPTARG;
	;;
	n) #copy non-existent files from directory A to directory B
		COPYFILE=1;
	;;
	p) #output as a patch without stamps (requires compare directories)
		ASPATCH=1;
		COMPAREFILES=1;
	;;
	o) #output
		OUTPUTFILE=1;
		if [ "$APPEND" -eq 1 -o "$FORCE" -eq 1 ]; then
			error_out "ef";
		fi	
		check_output_file "o" $OPTARG;
	;;
	r) #recursive search
		RECURSIVE=1;
	;;
	\?) #Not a valid flag
		error_out "if";
	;;
	esac
done

#shifts operators in case of arguments specified with an operator
let OPTIND="$OPTIND - $SHIFTOPT";
shift $OPTIND;

#Checks to see if no options were specifed and defaults to comparing files in directories
#if [ "$OPTIND" -eq 0 ]; then
#	COMPAREDIRS=1;
#elif [ "$FROMFILE" -eq 1 -a $OPTIND -eq 1 ]; then
#	COMPAREDIRS=1;
#fi

if [ "$COMPAREDIRS" -eq 0 -a "$COMPAREFILES" -eq 0 -a "$COPYFILE" -eq 0 ]; then
	COMPAREDIRS=1;
fi

#checks to see if an output file was specified and ignores the name of the file used as an output file. 
#otherwise it will automatically take the filename of the output as one of the directories to check 
if [ "$OUTPUT" == "" ]; then
	DIR1=$1;
	DIR2=$2;
else
	DIR1=$2;
	DIR2=$3;
fi

#checks if an input file has been provided or not. If not, it will check the arguments and continue
#if an input file as been provided, this will open the file and read out the pairs to operate on
if [ "$FROMFILE" -eq 0 ]; then
	check_args $DIR1 $DIR2;
	execute $DIR1 $DIR2;
else 
	while IFS=: read DIR1 DIR2
	do
		check_args $DIR1 $DIR2;
		execute "$DIR1" "$DIR2";
	done < "$INPUT";
fi

write_out "\n\nScript Completed! \n\n";

