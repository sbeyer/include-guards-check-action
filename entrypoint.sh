#!/bin/sh -l

cd "$GITHUB_WORKSPACE"

echo "Switching to given path $INPUT_PATH"
cd "$INPUT_PATH" || exit 1

ret=0
failed=""

fail () {
	failed="$failed$1 "
	echo "::error file={$1}::Header guard for $1 should be $2"
	ret=1
}

for header in $(find . -regex '.\+\.\(h\|H\|hh\|hpp\|hxx\)' | grep -v '^.git/' | sed -e 's/^\.\///')
do
	guard=$(echo $header | tr '[a-z]/\.' '[A-Z]__')
	echo "Checking $header for $guard"
	grep -q "^#ifndef $guard\$" $header ||
		fail "$header" "$guard"
	# TODO: check for wrong #define after #ifndef
	# TODO: allow indenting
	# TODO: prefixes, suffixes, etc
done

echo "::set-output name=fails::$failed"

exit $ret
