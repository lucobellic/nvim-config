#!/bin/sh
# Build a throwaway git repo next to the plugin that covers every diff-ribbon case, then open it
# in diffview. Run again to start from a fresh repo.
set -eu

repo="$(cd "$(dirname "$0")/.." && pwd)/.test-repo"
rm -rf "$repo"
mkdir -p "$repo"
cd "$repo"

git init -q -b main
g() { git -c user.email=test@example.com -c user.name=test -c commit.gpgsign=false "$@"; }

# Base versions
seq -f 'line %g' 1 120 > mixed.txt
printf 'gone 1\ngone 2\n' > deleted.txt
printf 'ctx\nshared a\nshared b\nctx 2\n' > merge.txt
g add .
g commit -qm base

# Branch that conflicts with main, for the three way view
git checkout -qb theirs
printf 'ctx\ntheirs a\nshared b\nctx 2\ntheirs extra\n' > merge.txt
g commit -qam theirs
git checkout -q main

printf 'ctx\nours a\nours b\nshared b\nctx 2\n' > merge.txt
g commit -qam ours
g merge theirs > /dev/null 2>&1 || true        # leaves merge.txt in conflict

# Two way cases stay uncommitted, so diffview shows them next to the conflict.
# They sit in one long file so scrolling can be tested too.
sed -i '10,12d' mixed.txt                      # pure deletion: red ribbon to a thin line
sed -i '30a new a\nnew b\nnew c' mixed.txt     # pure addition: green ribbon from a thin line
sed -i '50,55c changed 1\nchanged 2' mixed.txt # 6 lines become 2: blue change, then red deletion
sed -i '80s/.*/edited line/' mixed.txt         # simple change: blue ribbon
rm deleted.txt                                 # deleted file: no ribbon
printf 'brand new\n' > added.txt               # added file: no ribbon

echo "Test repo ready in $repo"
if [ "${1:-}" != "--no-open" ]; then
  exec nvim -c DiffviewOpen
fi
