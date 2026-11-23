#!/data/data/com.termux/files/usr/bin/sh
# Download EmulatorJS stable release into ./emulatorjs/data.
# Run once while connected to the internet; afterward the emulator itself runs locally/offline.
set -eu
cd "$(dirname "$0")"

command -v curl >/dev/null 2>&1 || pkg install -y curl
command -v unzip >/dev/null 2>&1 || pkg install -y unzip
command -v python >/dev/null 2>&1 || pkg install -y python

VERSION="v4.2.3"
TMP=".emulatorjs-download"
mkdir -p "$TMP" emulatorjs
API="https://api.github.com/repos/EmulatorJS/EmulatorJS/releases/tags/$VERSION"

echo "Mengambil daftar rilis EmulatorJS $VERSION..."
curl -fL --retry 3 --connect-timeout 20 "$API" -o "$TMP/release.json"

ASSET_URL="$(python -c 'import json,sys; d=json.load(open(sys.argv[1])); a=[x for x in d.get("assets",[]) if x.get("name","").lower().endswith(".zip")]; print(a[0]["browser_download_url"] if a else "")' "$TMP/release.json")"
if [ -z "$ASSET_URL" ]; then
  echo "Asset ZIP rilis tidak ditemukan. Periksa halaman rilis EmulatorJS."
  exit 1
fi

echo "Mengunduh paket emulator resmi..."
curl -fL --retry 3 --connect-timeout 20 "$ASSET_URL" -o "$TMP/emulatorjs.zip"
mkdir -p "$TMP/unpack"
unzip -oq "$TMP/emulatorjs.zip" -d "$TMP/unpack"

# Cari folder data yang benar (harus memiliki loader.js).
DATA_DIR="$(find "$TMP/unpack" -type f -name loader.js -print | head -n 1 | sed 's#/loader.js$##')"
if [ -z "$DATA_DIR" ] || [ ! -f "$DATA_DIR/emulator.min.js" ]; then
  echo "Struktur rilis tidak cocok: loader.js/emulator.min.js tidak ditemukan."
  echo "Isi ZIP tetap ada di $TMP/unpack untuk pemeriksaan."
  exit 1
fi

rm -rf emulatorjs/data
mkdir -p emulatorjs/data
cp -R "$DATA_DIR"/. emulatorjs/data/

if [ ! -f emulatorjs/data/loader.js ] || [ ! -f emulatorjs/data/emulator.min.js ]; then
  echo "Pemasangan gagal: file utama tidak lengkap."
  exit 1
fi

rm -rf "$TMP"
echo
echo "BERHASIL: EmulatorJS lokal terpasang di emulatorjs/data/"
echo "Ukuran folder:"
du -sh emulatorjs
echo
echo "Sekarang jalankan:"
echo "  sh jalan.sh"
echo
echo "Untuk GitHub, unggah SELURUH folder retro termasuk emulatorjs/ dan roms/."
echo "Sesudah itu GitHub Pages akan menggunakan emulator lokal yang sama."
