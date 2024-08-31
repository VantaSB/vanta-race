THRESHOLD=5
OPTIPNG_CMD="optipng -o1"

fails=0
IFS=$'\n'

# Only run if images were added or modified
git fetch --depth=1 origin master
FILES=$(git diff origin/master --name-only --no-renames --diff-filter=AMC | grep -E '\.png$' | sort)

if [ "x$FILES" == "x" ]; then
  echo "No images have changed since last commit to the master branch."
  exit 0
fi

echo "Checking PNG images: $FILES"

for FILENAME in $FILES; do
  unset IFS
  PERCENT=$($OPTIPNG_CMD $FILENAME 2>&1 | grep 'Output file size' | grep -E -o '([0-9.]+)%' | cut -d% -f1)

  if [ "x$PERCENT" != 'x' ]; then
    if [ $(echo "$PERCENT > $THRESHOLD" | bc) -eq 1 ]; then
			echo "Error: $FILENAME is not optimized: can reduce by $PERCENT% with lossless compression." >&2
			fails=$(( fails + 1 ))
		fi
	fi
done

if [ $fails -gt 0 ]; then
	echo "Test failed: found $fails unoptimized image(s)." >&2
	exit 1
fi

# Success
exit 0
