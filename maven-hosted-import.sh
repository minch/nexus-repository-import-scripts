#!/bin/bash

# Get command line params
while getopts ":r:u:p:" opt; do
    case $opt in
        r) REPO_URL="$OPTARG"
        ;;
        u) USERNAME="$OPTARG"
        ;;
        p) PASSWORD="$OPTARG"
        ;;
    esac
done

# Define the base directory of the Maven repository to be the current directory
BASE_DIR=$(pwd)

find $BASE_DIR -type f \
    -not -path "$BASE_DIR/mavenimport.sh" \
    -not -path "$BASE_DIR/maven-hosted-import.sh" \
    -not -path '*/\.*' \
    -not -path '*/\^archetype\-catalog\.xml*' \
    -not -path '*/\^maven\-metadata\-local*\.xml' \
    -not -path '*/\^maven\-metadata\-deployment*\.xml' | while read file; do

    # Extract Maven metadata from file path
    RELATIVE_PATH=${file#$BASE_DIR/}
    GROUP_ID=$(echo $RELATIVE_PATH | cut -d "/" -f 1-$(($(awk -F"/" '{print NF-1}' <<< $RELATIVE_PATH)-2)))
    GROUP_ID=${GROUP_ID//\//.}
    ARTIFACT_ID=$(echo $RELATIVE_PATH | rev | cut -d "/" -f 2 | rev)
    VERSION=$(echo $RELATIVE_PATH | rev | cut -d "/" -f 3 | rev)
    EXTENSION="${file##*.}"

    curl -v -u "user:pass" -X POST "${REPO_URL}/${RELATIVE_PATH}" \
	    -H 'Content-Type: multipart/form-data' \
        -F "maven2.groupId=$GROUP_ID" \
        -F "maven2.artifactId=$ARCHIVE_ID" \
        -F "maven2.version=$VERSION"  \
        -F "maven2.asset1=$file,type=application/java-archive" \
        -F "maven2.asset1.extension=$EXTENSION"
done

