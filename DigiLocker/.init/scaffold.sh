#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/ekyc-application-125058-126430/DigiLocker"
cd "$WORKSPACE"
if [ -f package.json ]; then echo "scaffold-002: package.json exists, skipping scaffold"; exit 0; fi
TEMPLATE="react"
if [ -f tsconfig.json ]; then TEMPLATE="react-ts"; else
  if [ -f package.json ] && node -e "try{const p=require('./package.json'); if(p.dependencies&&p.dependencies.typescript)process.exit(0); if(p.devDependencies&&p.devDependencies.typescript)process.exit(0);}catch(e){}; process.exit(1)" >/dev/null 2>&1; then TEMPLATE="react-ts"; fi
  if [ "$TEMPLATE" = "react" ] && find "$WORKSPACE/src" -type f \( -iname "*.ts" -o -iname "*.tsx" \) | grep -q . >/dev/null 2>&1; then TEMPLATE="react-ts"; fi
fi
TMPLOG=$(mktemp)
if command -v npm >/dev/null 2>&1; then
  if npm create vite@latest . -- --template "$TEMPLATE" --yes >"${TMPLOG}" 2>&1; then :; else
    echo "scaffold-002: 'npm create' failed; falling back (see ${TMPLOG})" >&2
    if command -v npx >/dev/null 2>&1; then npx --yes create-vite@latest . --template "$TEMPLATE" >>"${TMPLOG}" 2>&1 || { cat "${TMPLOG}" >&2; rm -f "${TMPLOG}"; exit 4; }; elif command -v create-vite >/dev/null 2>&1; then create-vite . --template "$TEMPLATE" >>"${TMPLOG}" 2>&1 || { cat "${TMPLOG}" >&2; rm -f "${TMPLOG}"; exit 5; }; else cat "${TMPLOG}" >&2; rm -f "${TMPLOG}"; echo "scaffold-002: no create-vite available" >&2; exit 6; fi
  fi
else
  if command -v npx >/dev/null 2>&1; then npx --yes create-vite@latest . --template "$TEMPLATE" >"${TMPLOG}" 2>&1 || { cat "${TMPLOG}" >&2; rm -f "${TMPLOG}"; exit 7; }; elif command -v create-vite >/dev/null 2>&1; then create-vite . --template "$TEMPLATE" >"${TMPLOG}" 2>&1 || { cat "${TMPLOG}" >&2; rm -f "${TMPLOG}"; exit 8; }; else echo "scaffold-002: no npm or npx or create-vite available" >&2; rm -f "${TMPLOG}"; exit 9; fi
fi
rm -f "${TMPLOG}"
if [ ! -f package.json ]; then echo "scaffold-002: package.json missing after scaffold" >&2; exit 10; fi
node -e "const fs=require('fs'); let p=JSON.parse(fs.readFileSync('package.json','utf8')); p.scripts=p.scripts||{}; if(!p.scripts.start) p.scripts.start='vite'; if(!p.scripts.build) p.scripts.build='vite build'; fs.writeFileSync('package.json', JSON.stringify(p,null,2));" || { echo "scaffold-002: failed to ensure scripts" >&2; exit 11; }
