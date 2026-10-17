#!/usr/bin/env bash
set -euo pipefail

TOKEN="3fb1abe156dc14d90c2882a10bb7c1dd1c1a2bd1"
url="https://pixel-admin.grupawp.pl/api/v7/pixels.json?page_size=2000&show_active_domains=true"
i=1

while [[ -n "$url" && "$url" != "null" ]]; do
  echo "Fetching page $i: $url" >&2

  body="$(curl -sS -L --fail-with-body \
    -H "Authorization: Token ${TOKEN}" \
    -H "Accept: application/json" \
    "$url")"

  echo "----- page $i -----"
  printf '%s\n' "$body" | jq .
  echo "-------------------"

  # next (wymuszamy https)
  url="$(printf '%s\n' "$body" | jq -r '.next')"
  url="${url/http:\/\//https://}"

  ((i++))
done
