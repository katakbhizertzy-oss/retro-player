#!/data/data/com.termux/files/usr/bin/sh
set -eu
cd "$(dirname "$0")"

if [ ! -s emulatorjs/data/loader.js ] || [ ! -s emulatorjs/data/emulator.min.js ]; then
  echo "Emulator lokal belum dipasang."
  echo "Jalankan: sh setup-offline.sh"
  exit 1
fi

command -v python >/dev/null 2>&1 || pkg install -y python
echo
echo "Retro Player berjalan di http://localhost:8080"
echo "Tekan CTRL+C untuk menghentikan server."
python -m http.server 8080
