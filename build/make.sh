#!/bin/bash

JS_LIB="./public/js/lib/"
JS_SRC="./public/js/src/"
CSS_SRC="./public/css/"
VIEW_SRC="./views/"

NO_ARGS=0 
E_OPTERROR=85
FINAL_RELEASE=0

# Script invoked with no command-line args
if [ $# -eq "$NO_ARGS" ]
then
 echo "Usage: `basename $0` [options]"
 exit $E_OPTERROR # Exit and explain usage.
	# Usage: scriptname -options
	# Note: dash (-) necessary
fi

while [ $# -gt 0 ]; do    # Until you run out of parameters . . .
  case "$1" in
 --help)
 	echo "Usage: `basename $0` [options]"
 	echo " -js, --javascripts-path	compile to javascripts and save as .js files"
 	echo " -css, --css-path	compile a stylus directory and save as .css files using stylus"
 	exit $E_OPTERROR
 ;;
 	#TODO - make an available option to build an RTM bundled file. --final-release -fr 
 	-fr|--final-release)
 	FINAL_RELEASE=1
 	;;
	-js|--javascripts-path)
	 JS_LIB=1
	 ;;
	-css|--css-path)
	 CSS_SRC="$1"
	 shift
	 if [ ! -f $CONFFILE ]; then
	   echo "Error: Supplied file doesn't exist!"
	   exit $E_CONFFILE     # File not found error.
	 fi
	 ;;
  esac
  shift # Check next set of parameters.
done

echo "--Start compiler, current dir is $(pwd)";
#------------------------------------------------------------------------
echo "--Compile jade files :: dirpath $VIEW_SRC";
`jade "$VIEW_SRC" --out "$VIEW_SRC"`;
#------------------------------------------------------------------------
echo "--Compile stylus files :: dirpath $CSS_SRC";
`stylus --compress "$CSS_SRC"`;
#---------------------------------------------------------------------------
echo "--Compile coffeescripts files :: dirpath $JS_SRC";
`coffee -b -o "$JS_LIB" -c "$JS_SRC"`;
#---------------------------------------------------------------------------
echo "--Minifying javascripts using closure :: dirpath $JS_LIB";
for f in $(ls ./public/js/src/*[^\.min].js);
	do
	baseName=`basename "$f" .js`
	`java -jar ./build/tools/closure-compiler/compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js "$JS_LIB$baseName".js > "$JS_LIB$baseName".min.js`;
		echo "source::$JS_LIB$baseName.js dest::$JS_LIB$baseName.min.js";
done
#---------------------------------------------------------------------------
#http://www.commandlinefu.com/commands/view/5957/bash-script-to-zip-a-folder-while-ignoring-git-files-and-copying-it-to-dropbox
if [ $FINAL_RELEASE -eq 1 ]; then
	
	echo "compiling final release, this may take a few minutes.";
	
	declare -a final_files
	final_files=("content_script" "options" "background");
	
	for file in "${final_files[@]}"
	do
		echo "releasing $file.min.js"
		`java -jar ./build/tools/closure-compiler/compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js ./public/js/lib/ender.js --js ./public/js/lib/"$file".js --js_output_file ./public/js/lib/"$file".min.js`;
	done

	zip gchrome-video-post manifest.json views/*.html public/js/lib/*.min.js public/css/*.css public/images/*.*;
	cp gchrome-video-post.zip release/gchrome-video-post.zip;	
	echo "done";
fi
