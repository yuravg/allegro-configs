#!/usr/bin/env bash

# Installation script
#
# it creates symbolic links in the HOME directory pointing to local files
#

echo "Make link:"

prj=pcbenv
target="$HOME/$prj"

if [ -d "$target" ]; then
    printf "\\e[31m\\e[1mWARNING: Directory/Link already exists: %s\\e[0m\\n" "$target"
    printf "Exit without creating link!\\n"
else
	ln -v -s $(pwd)/"$prj" "$target"
fi
