#!/usr/bin/env bash
# Runs every case in tests/cases
set -u

root=$(cd "$(dirname "$0")/.." && pwd)
cases_dir="$root/tests/cases"
filter=${1:-}
pass=0
fail=0

# `typst eval` arrived in 0.15
if typst eval '{ 1 }' --format yaml >/dev/null 2>&1; then
  mode=eval
elif typst query --help >/dev/null 2>&1; then
  mode=query
  echo "note: no typst eval; reading the findings back with typst query"
  echo
else
  mode=none
  echo "note: neither typst eval nor typst query; checking that everything compiles"
  echo
fi

if [[ ${UPDATE:-0} == 1 && $mode == none ]]; then
  echo "UPDATE needs typst eval or typst query" >&2
  exit 2
fi

wanted() {
  [[ -z $filter || $1 == *"$filter"* ]]
}

ok() {
  echo "ok   $1"
  ((pass++))
}

failed() {
  echo "FAIL $1${2:+: $2}"
  ((fail++))
}

normalise() {
  awk 'NR == 1 && $0 == "|-" { next }
       NR == 1 && ($0 == "\"\"" || $0 == "'"''"'") { exit }
       { sub(/^  /, ""); print }'
}

findings() {
  local dir=$1
  shift
  if [[ $mode == eval ]]; then
    typst eval '{ import "/lib.typ": sanity-text; sanity-text() }' \
      --in "$dir/input.typ" --root "$root" --format yaml "$@" 2>&1 | normalise
  else
    local probe="$dir/_probe.typ"
    printf '#import "/lib.typ": sanity-text\n#include "input.typ"\n#context [#metadata(sanity-text())<sanity-out>]\n' \
      > "$probe"
    typst query --root "$root" "$probe" '<sanity-out>' \
      --field value --one --format yaml "$@" 2>&1 | normalise
    rm -f "$probe"
  fi
}

for case_dir in "$cases_dir"/*/; do
  name=$(basename "$case_dir")
  wanted "$name" || continue

  input="$case_dir/input.typ"
  expected="$case_dir/expected.txt"

  # optional extra typst arguments
  flags=()
  [[ -f "$case_dir/flags" ]] && read -ra flags < "$case_dir/flags"

  if [[ -f "$case_dir/expect-compile-error" ]]; then
    if typst compile --root "$root" -f pdf "$input" /dev/null >/dev/null 2>&1; then
      failed "$name" "expected the compilation to fail"
    else
      ok "$name"
    fi
    continue
  fi

  if ! compile_err=$(typst compile --root "$root" -f pdf "${flags[@]}" "$input" /dev/null 2>&1); then
    failed "$name" "does not compile"
    echo "$compile_err" | sed 's/^/     /'
    continue
  fi

  if [[ $mode == none ]]; then
    ok "$name (compiled)"
    continue
  fi

  actual=$(findings "$case_dir" "${flags[@]}")

  if [[ ${UPDATE:-0} == 1 ]]; then
    printf '%s\n' "$actual" > "$expected"
    echo "wrote $name"
    continue
  fi

  if [[ "$actual" == "$(cat "$expected" 2>/dev/null)" ]]; then
    ok "$name"
  else
    failed "$name"
    diff <(cat "$expected" 2>/dev/null) <(printf '%s\n' "$actual") | sed 's/^/     /'
  fi
done

[[ ${UPDATE:-0} == 1 ]] && exit 0

# a document with nothing to report must come out of the compiler exactly as
# it would have without sanity
if wanted untouched; then
  tmp=$(mktemp -d)
  for variant in plain checked; do
    typst compile --root "$root" --creation-timestamp 0 \
      "$root/tests/untouched/$variant.typ" "$tmp/$variant.pdf" >/dev/null 2>&1
  done
  if cmp -s "$tmp/plain.pdf" "$tmp/checked.pdf"; then
    ok untouched
  else
    failed untouched "enabling sanity changed the output of a clean document"
  fi
  rm -rf "$tmp"
fi

if wanted input-off; then
  tmp=$(mktemp -d)
  typst compile --root "$root" --creation-timestamp 0 \
    "$root/tests/input-off/plain.typ" "$tmp/plain.pdf" >/dev/null 2>&1
  typst compile --root "$root" --creation-timestamp 0 --input sanity=off \
    "$root/tests/input-off/checked.typ" "$tmp/checked.pdf" >/dev/null 2>&1
  if cmp -s "$tmp/plain.pdf" "$tmp/checked.pdf"; then
    ok input-off
  else
    failed input-off "sanity=off did not leave the document alone"
  fi
  rm -rf "$tmp"
fi

if wanted documented; then
  ids=$(sed -n '/^#let default-checks/,/^)/p' "$root/src/core.typ" |
    grep -o '"[a-z-]*":' | tr -d '":')
  severities=$(sed -n '/^#let default-severities/,/^)/p' "$root/src/core.typ" |
    grep -o '"[a-z-]*":' | tr -d '":')
  missing=
  manifest=$(sed -n 's/^version = "\(.*\)"/\1/p' "$root/typst.toml")
  declared=$(sed -n 's/^#let version = "\(.*\)"/\1/p' "$root/src/core.typ")
  [[ $manifest == "$declared" ]] || missing=" the version ($declared, but the manifest says $manifest)"

  for id in $ids; do
    grep -qF "#check(\"$id\")" "$root/docs/manual.typ" || missing="$missing $id(manual)"
    printf '%s\n' "$severities" | grep -qx "$id" || missing="$missing $id(severity)"
  done
  if [[ -z $missing ]]; then
    ok documented
  else
    failed documented "nothing for$missing"
  fi
fi

if wanted hostile; then
  tmp=$(mktemp -d)
  last_page() {
    rm -f "$tmp"/p-*.png
    typst compile --root "$root" -f png "$1" "$tmp/p-{n}.png" >/dev/null 2>&1
    ls "$tmp"/p-*.png | sort | tail -n 1
  }
  cp "$(last_page "$root/tests/hostile/plain.typ")" "$tmp/plain.png" 2>/dev/null
  cp "$(last_page "$root/tests/hostile/themed.typ")" "$tmp/themed.png" 2>/dev/null
  if cmp -s "$tmp/plain.png" "$tmp/themed.png"; then
    ok hostile
  else
    failed hostile "the document's theme reached the report page"
  fi
  rm -rf "$tmp"
fi

# a template that applies sanity and an author who applies it again must not
# append a report each
if wanted report-once; then
  tmp=$(mktemp -d)
  pages() {
    rm -f "$tmp"/page-*.png
    typst compile --root "$root" -f png "$1" "$tmp/page-{n}.png" >/dev/null 2>&1
    find "$tmp" -name 'page-*.png' | wc -l
  }
  once=$(pages "$root/tests/report-once/once.typ")
  twice=$(pages "$root/tests/report-once/twice.typ")
  if [[ $once -gt 0 && $once == "$twice" ]]; then
    ok report-once
  else
    failed report-once "one application gives $once pages, two give $twice"
  fi
  rm -rf "$tmp"
fi

# HTML export drops the layout the report page is built from
if [[ $mode != none ]] && wanted html; then
  tmp=$(mktemp -d)
  if typst compile --root "$root" -f html --features html \
    "$root/tests/html/input.typ" "$tmp/out.html" >/dev/null 2>&1 &&
    grep -q 'never referenced' "$tmp/out.html"; then
    ok html
  else
    failed html "the findings did not reach the HTML output"
  fi
  rm -rf "$tmp"
fi

# command line wrapper
if [[ $mode == eval ]] && wanted cli; then
  err=$(mktemp)
  pkg=/lib.typ
  cli() {
    local name=$1 doc=$2 want_code=$3 want_out=${4:-} want_err=${5:-}
    shift 5
    local out code
    out=$(SANITY_PACKAGE=$pkg "$root/bin/sanity" "$root/tests/cli/$doc" "$@" 2>"$err")
    code=$?

    if [[ $code != "$want_code" ]]; then
      failed "cli/$name" "exit $code, expected $want_code"
      return
    fi
    if [[ -n $want_out && $out != *"$want_out"* ]]; then
      failed "cli/$name" "stdout does not mention \"$want_out\""
      printf '%s\n' "$out" | sed 's/^/     /'
      return
    fi
    if [[ -n $want_err ]] && ! grep -q "$want_err" "$err"; then
      failed "cli/$name" "stderr does not mention \"$want_err\""
      sed 's/^/     /' "$err"
      return
    fi
    ok "cli/$name"
  }

  cli reads-bibliography paper.typ 1 'entry "unused2001" is never cited' '' --root "$root"
  cli resolves-against-document nested/paper.typ 1 'entry "unused2001" is never cited' '' --root "$root"
  cli clean-document clean.typ 0 'nothing to report' '' --root "$root"
  cli broken-document broken.typ 2 '' 'unknown variable' --root "$root"
  cli strict-still-reports strict.typ 1 '<fig:orphan> is never referenced' '' --root "$root"
  cli unreadable-bibliography split/paper.typ 0 '' 'could not read the bibliography' --root "$root"

  cli info-does-not-gate info.typ 0 '<fig:orphan> is never referenced' '' --root "$root"

  cli json paper.typ 1 '"id":"uncited-entry"' '' --root "$root" --json
  cli json-clean clean.typ 0 '[]' '' --root "$root" --json

  noise='unknown font'

  out=$(SANITY_PACKAGE=$pkg "$root/bin/sanity" "$root/tests/cli/warned.typ" \
    --root "$root" 2>"$err")
  code=$?
  if [[ $code == 1 && $out == *'sanity: 1 warning'* && $out != *"$noise"* ]] &&
    grep -q "$noise" "$err"; then
    ok cli/warning-does-not-open-the-gate
  else
    failed cli/warning-does-not-open-the-gate "exit $code, expected 1"
    printf '%s\n' "$out" | sed 's/^/     /'
  fi

  json_ok() {
    if command -v python3 > /dev/null 2>&1; then
      printf '%s' "$1" | python3 -c 'import json, sys; json.load(sys.stdin)' 2>/dev/null
    else
      [[ $1 == '['*']' && $1 != *$'\n'* ]]
    fi
  }

  out=$(SANITY_PACKAGE=$pkg "$root/bin/sanity" "$root/tests/cli/warned.typ" \
    --root "$root" --json 2>"$err")
  code=$?
  if [[ $code == 1 ]] && json_ok "$out"; then
    ok cli/json-stays-json
  else
    failed cli/json-stays-json "exit $code, and standard output is not JSON"
    printf '%s\n' "$out" | sed 's/^/     /'
  fi

  cli clean-with-warning warned-clean.typ 0 'nothing to report' '' --root "$root"

  cli manual-is-clean ../../docs/manual.typ 0 'nothing to report' '' --root "$root"

  pkg=$root/lib.typ
  cli root-is-slash paper.typ 1 'entry "unused2001" is never cited' '' --root /
  pkg=/lib.typ

  flat=$(mktemp -d)
  cp -r "$root/lib.typ" "$root/src" "$root/tests/cli/paper.typ" \
    "$root/tests/cli/refs.bib" "$flat/"
  flat_out=$(SANITY_PACKAGE=/lib.typ "$root/bin/sanity" "$flat/paper.typ" --root "$flat" 2>"$err")
  flat_code=$?
  if [[ $flat_code == 1 && $flat_out == *'entry "unused2001" is never cited'* ]]; then
    ok cli/document-at-the-root
  else
    failed cli/document-at-the-root "exit $flat_code"
    printf '%s\n' "$flat_out" | sed 's/^/     /'
    sed 's/^/     /' "$err"
  fi
  rm -rf "$flat"

  rm -f "$err"
fi

if wanted manual; then
  if err=$(typst compile --root "$root" -f pdf "$root/docs/manual.typ" /dev/null 2>&1); then
    ok manual
  else
    failed manual "the manual does not build"
    echo "$err" | sed 's/^/     /'
  fi
fi

for example in "$root"/examples/*.typ; do
  name="example/$(basename "$example" .typ)"
  wanted "$name" || continue
  if err=$(typst compile --root "$root" -f pdf "$example" /dev/null 2>&1); then
    ok "$name"
  else
    failed "$name"
    echo "$err" | sed 's/^/     /'
  fi
done

echo
echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
