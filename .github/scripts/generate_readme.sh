#!/bin/bash
set -e

OUTPUT="README.md"

{
  echo "# TIL"
  echo "> Today I Learned"
  echo ""
  echo "A collection of concrete writeups of small things I learn daily while working"
  echo "and researching. My goal is to work in public. I was inspired to start this"
  echo "repository after reading Simon Wilson's [hacker new post][1], and he was"
  echo "apparently inspired by Josh Branchaud's [TIL collection][2]."
  echo ""
} > "$OUTPUT"

# TIL 개수 (README.md, CLAUDE.md, .github 제외)
TOTAL=$(find . -name "*.md" \
  ! -name "README.md" \
  ! -name "CLAUDE.md" \
  ! -path "./.github/*" \
  ! -path "./.*" | wc -l | tr -d ' ')

echo "_${TOTAL} TILs and counting..._" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "---" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 최근 5개 TIL
echo "### 5 most recent TILs" >> "$OUTPUT"
echo "" >> "$OUTPUT"

git log --diff-filter=A --name-only --pretty=format: -- "*.md" \
  | grep -v "^$" \
  | grep "\.md$" \
  | grep -v "README.md" \
  | grep -v "CLAUDE.md" \
  | head -5 > /tmp/recent_files.txt

while IFS= read -r file; do
  if [ -f "$file" ]; then
    TITLE=$(head -1 "$file" | sed 's/^#* *//')
    DATE=$(git log --diff-filter=A --format="%ad" -- "$file" | head -1)
    echo "- [$TITLE]($file) - $DATE" >> "$OUTPUT"
  fi
done < /tmp/recent_files.txt

echo "" >> "$OUTPUT"

# 카테고리 링크 목록
echo "### Categories" >> "$OUTPUT"
echo "" >> "$OUTPUT"

find . -maxdepth 1 -mindepth 1 -type d \
  ! -name ".*" \
  ! -name ".github" \
  | sort | sed 's|^\./||' > /tmp/categories.txt

while IFS= read -r dir; do
  echo "- [$dir](#$dir)" >> "$OUTPUT"
done < /tmp/categories.txt

echo "" >> "$OUTPUT"

# 카테고리별 섹션
while IFS= read -r dir; do
  find "$dir" -name "*.md" ! -name "README.md" ! -name "CLAUDE.md" | sort > /tmp/cat_files.txt
  if [ -s /tmp/cat_files.txt ]; then
    echo "### [$dir](#$dir)" >> "$OUTPUT"
    while IFS= read -r file; do
      TITLE=$(head -1 "$file" | sed 's/^#* *//')
      echo "- [$TITLE]($file)" >> "$OUTPUT"
    done < /tmp/cat_files.txt
    echo "" >> "$OUTPUT"
  fi
done < /tmp/categories.txt

# 푸터
echo "[1]: https://simonwillison.net/2020/Apr/20/self-rewriting-readme/" >> "$OUTPUT"
echo "[2]: https://github.com/jbranchaud/til" >> "$OUTPUT"
