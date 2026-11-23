#!/data/data/com.termux/files/usr/bin/sh
set -eu
cd "$(dirname "$0")"
echo "=== CEK FILE RETRO PLAYER ==="
for f in index.html roms/roms.json roms/mariokart-super-circuit.gba roms/pokemon-firered.gba; do
  if [ -s "$f" ]; then
    echo "OK       $f ($(wc -c < "$f") bytes)"
  else
    echo "MISSING  $f"
    exit 1
  fi
done
if [ -s emulatorjs/data/loader.js ] && [ -s emulatorjs/data/emulator.min.js ]; then
  echo "OK       emulatorjs/data/loader.js"
  echo "OK       emulatorjs/data/emulator.min.js"
else
  echo "BELUM    EmulatorJS lokal. Jalankan: sh setup-offline.sh"
fi
echo
echo "Jika semua file ROM berstatus OK, lakukan git add -f roms/"
echo "Lalu git status --short untuk memastikan kedua file ROM masuk daftar commit."
