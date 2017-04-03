#!/bin/bash

# Check the number arguments
if [ "$#" -ne 2 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  link-wordpress-plugin.sh source_dir destination"
	exit 255
fi

SOURCE_DIR=$1
TARGET=/var/www/$2

# First try a soft delete
if [ -d "$TARGET" ]
then
	echo "$TARGET is a directory"
	rm -f "$TARGET"
fi

# If the previous test failed, retry
if [ -L "$TARGET" ]
then
	echo "$TARGET is a link"
	rm -f "$TARGET"
fi

# If it's still there, do a recursive delete
if [ -d "$TARGET" ]
then
	echo "$TARGET is a directory (force)"
	rm -rf "$TARGET"
fi

ln -s "$SOURCE_DIR" "$TARGET"
