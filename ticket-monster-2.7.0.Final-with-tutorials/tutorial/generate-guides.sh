#!/bin/bash

# Require BASH 3 or newer

REQUIRED_BASH_VERSION=3.0.0

if [[ $BASH_VERSION < $REQUIRED_BASH_VERSION ]]; then
  echo "You must use Bash version 3 or newer to run this script"
  exit
fi

# Canonicalise the source dir, allow this script to be called anywhere
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# DEFINE

TARGET=target/guides
MASTER=ticket-monster.asciidoc

OUTPUT_FORMATS=("xml" "epub" "pdf")
OUTPUT_CMDS=("asciidoctor -d book -b docbook -o \${output_filename} \$MASTER" "a2x -d book -f epub -D \$dir \$MASTER" "a2x -d book -f pdf --dblatex-opts \"-s custom-asciidoc-dblatex.sty -P latex.output.revhistory=0\" -D \$dir \$MASTER")

echo "** Building tutorial"

echo "**** Cleaning $TARGET"
rm -rf $TARGET
mkdir -p $TARGET

output_format=html
dir=$TARGET/$output_format
mkdir -p $dir
echo "**** Copying shared resources to $dir"
cp -r gfx $dir

for file in *.asciidoc 
do
   output_filename=$dir/${file//.asciidoc/.$output_format}
   echo "**** Processing $file > ${output_filename}"
   asciidoctor -d book -b html5 -a toc2 -a copycss -a source-highlighter=highlightjs -o ${output_filename} $file
done

file=ticket-monster.asciidoc
for ((i=0; i < ${#OUTPUT_FORMATS[@]}; i++))
do
   output_format=${OUTPUT_FORMATS[i]}
   dir=$TARGET/$output_format
   output_filename=$dir/${file//.asciidoc/.$output_format}
   mkdir -p $dir
   echo "**** Copying shared resources to $dir"
   cp -r gfx $dir
   echo "**** Processing $file > ${output_filename}"
   eval ${OUTPUT_CMDS[i]}
done

