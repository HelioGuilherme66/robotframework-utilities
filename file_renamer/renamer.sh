#!/usr/bin/bash

OLD_EXT="txt"
NEW_EXT="robot"

EXCLUDE=""
GIT=""
while [ $# -ge 1 ];
do
    # Option -g acts on GitHub project
    if [ "$1" = "-g" ];
    then
        GIT="git "
        shift
    fi

    # Option -r reverts changes
    if [ "$1" = "-r" ];
    then
        OLD_EXT="robot"
        NEW_EXT="txt"
        shift
    fi

    # Option -h displays usage
    if [ "$1" = "-h" ];
    then
        echo "Usage: $0 [OPTIONS]"
        echo "       -h Shows this usage"
        echo "       -g Rename files with GIT command"
        echo "       -r Reverses (renames from .robot to .txt)" 
        echo "       -e <filename> Excludes filename from rename"
        echo ""
        echo "Notes: This program renames files from .txt to .robot, and"
        echo "       corresponding references in Resource import. Must be"
        echo "       run on the root directory to process all files from"
        echo "       there."  
        echo "       When using -e, Resources import processing ignores"
        echo "       this option."
        exit
    fi

    # Option -e excludes a file
    if [ "$1" = "-e" ];
    then
       EXCLUDE="$EXCLUDE $2"
       shift
       shift
    else
      shift
    fi
done

#rename files from .$OLD_EXT to .$NEW_EXT
RES_FILES=`find . -name "*.$OLD_EXT" -print`

# Avoid excluded files
if [ "$EXCLUDE" != "" ];
then
    for f in $EXCLUDE
    do
        NEWLIST=`printf "%s\n" $RES_FILES |grep -v $f`
        RES_FILES=$NEWLIST 
    done
fi

# actual rename
for f in $RES_FILES
do
   NAME=`echo $f | sed "s/\.$OLD_EXT/\.$NEW_EXT/g" -`
   $GIT mv $f $NAME
done

#fix Resource files import names
RES_FILES=`find . -name "*.$NEW_EXT" -print`

for f in $RES_FILES
do
   sed -i -e "s/^\(Resource\)\(.*\)\(\.$OLD_EXT\)/\1\2\.$NEW_EXT/gm" $f
done

