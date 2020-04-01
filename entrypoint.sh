#!/bin/sh -l

cd "$GITHUB_WORKSPACE"

echo "Switching to given path $INPUT_PATH"
cd "$INPUT_PATH" || exit 1

ret=0
failed=""

fail () {
	failed="$failed$1 "
	echo "::error file={$1}::Header guard macro $2 expected in $1 but not found"
	ret=1
}

for header in $(find . -regex '.\+\.\(h\|H\|hh\|hpp\|hxx\)' | grep -v '^.git/' | sed -e 's/^\.\///')
do
	guard=$(echo $header | tr '[a-z]/\.' '[A-Z]__')
	# TODO: pattern
	echo "Checking $header for $guard"
	awk '
		/^\s*#\s*ifndef\s+'"$guard"'\>/ { ifndef = 1 }
		/^\s*#\s*define\s+'"$guard"'\>/ && ifndef { define = 1 }
		ifndef && define { exit 1 }' "$header" &&
		fail "$header" "$guard"
done

echo "::set-output name=fails::$failed"

exit $ret
