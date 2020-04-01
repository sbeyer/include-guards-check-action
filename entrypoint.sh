#!/bin/sh -l

macrofy_allow_lowercase () {
	echo -n "$1" |
		tr -c '[0-9A-Za-z_]' _ |
		sed -e 's/^_*\(.*\)$/\1/'
}

macrofy () {
	macrofy_allow_lowercase "$1" | tr '[a-z]' '[A-Z]'
}

guardify () {
	path="$1"
	file="$(basename "$path")"
	file_ext="$(echo "$file" | sed -e 's|^.*\.||')"
	file_base="$(echo "$file" | sed -e 's/^\(.*\)\.\([^\.]*\)$/\1/')"
	dirs="$(dirname "$path")"
	first_dir="$(echo "$dirs" | cut -d / -f 1)"
	last_dir="$(echo "$dirs" | sed -e 's|^.*/||')"

	echo -n "$INPUT_PATTERN" | sed \
			-e 's/{path}/'"$(macrofy "$path")"'/g' \
			-e 's/{file}/'"$(macrofy "$file")"'/g' \
			-e 's/{file_base}/'"$(macrofy "$file_base")"'/g' \
			-e 's/{file_ext}/'"$(macrofy "$file_ext")"'/g' \
			-e 's/{dirs}/'"$(macrofy "$dirs")"'/g' \
			-e 's/{first_dir}/'"$(macrofy "$first_dir")"'/g' \
			-e 's/{last_dir}/'"$(macrofy "$last_dir")"'/g'
}

die () {
	echo "::error::$1"
	exit 1
}

echo "Checking pattern '$INPUT_PATTERN' ..."

dummy="dir1/dir2/dir3/base.between.ext"
actual="$(guardify dir1/dir2/dir3/base.between.ext)"
expected="$(macrofy_allow_lowercase "$actual")"

if test "$actual" != "$expected"
then
	cat <<EOF
	Oops! We tested the dummy file name
		$dummy
	and the given pattern produced
		$actual
	which contains invalid characters.
	Removing invalid characters produces
		$expected

	Please fix this.
EOF
	die "Pattern contains invalid characters!"
fi

cd "$GITHUB_WORKSPACE" || die "Internal error: Cannot change to GitHub workspace directory."

echo "Switching to given path '$INPUT_PATH' ..."
cd "$INPUT_PATH" || die "Cannot change directory"

ret=0
failed=""

fail () {
	failed="$failed$1 "
	echo "::error file={$1}::Header guard macro $2 expected in $1 but not found"
	ret=1
}

for header in $(find . -regex '.\+\.\(h\|H\|hh\|hpp\|hxx\)' |
			grep -e "$INPUT_ONLY" |
			grep -v -e '^.git/' ${INPUT_IGNORE:+-e} ${INPUT_IGNORE:+"$INPUT_IGNORE"} |
			sed -e 's/^\.\///')
do
	guard="$(guardify "$header")"

	echo "Checking $header for $guard"
	awk '
		/^\s*#\s*ifndef\s+'"$guard"'\>/ { ifndef = 1 }
		/^\s*#\s*define\s+'"$guard"'\>/ && ifndef { define = 1 }
		ifndef && define { exit 1 }' "$header" &&
		fail "$header" "$guard"
done

echo "::set-output name=fails::$failed"

exit $ret
