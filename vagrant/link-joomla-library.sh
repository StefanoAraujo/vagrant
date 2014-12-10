#!/bin/bash

# Check the number arguments
if [ "$#" -ne 3 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  link-joomla-library.sh from to_relative subdomain"
	exit 255
fi

SOURCE=$1
TARGET=/var/www/$3/$2

# First try a soft delete
if [ -d "$TARGET" ]
then
	rm -f "$TARGET"
fi

# If the previous test failed, retry
if [ -L "$TARGET" ]
then
	rm -f "$TARGET"
fi

# If it's still there, do a recursive delete
if [ -d "$TARGET" ]
then
	rm -rf "$TARGET"
fi

ln -s "$SOURCE" "$TARGET"