#!/bin/sh

#  gen_docs.sh
#  Kelvin
#
#  Created by Jiachen Ren on 9/13/19.
#  Copyright © 2019 Jiachen Ren. All rights reserved.
#  Generates MARKDOWN documentation for Kelvin example files

set -e

# Replace with parent directory to all examples
LANG="ruby"
TMP=/tmp/tmp.md

# Path to README.md
README_DIR=README.md

gen () {
  # Generate documentations from Kelvin source code
  if [ ! $1 == ./README.md ] && [[ -f $1 ]]; then
    echo "### $1" >> $TMP
    echo "\`\`\`$LANG" >> $TMP
    cat $1 >> $TMP
    echo "\`\`\`" >> $TMP
  fi
}

export -f gen

# Create a temporary file to hold manually written README.md content
touch $TMP
IFS='' # Preserve padding white space
while read -r line; do
  echo "$line" >> $TMP
  if [ "$line" == "<!-- AUTOMATIC DOC -->" ]; then
    break
  fi
done < $README_DIR

# Get a list of all kelvin source files, excluding *.md
for f in ./**/*.kel
do
    echo "Generating docs for $f"
    gen $f
done

# Update original README.md
mv $TMP $README_DIR

echo "Success!"

