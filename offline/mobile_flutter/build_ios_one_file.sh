#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Loi: build iOS chi chay tren macOS + Xcode."
  echo "May Windows khong tao duoc file .ipa. Xem BUILD_IOS.md."
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Khong tim thay Flutter trong PATH."
  echo "Cai Flutter SDK tren macOS, mo terminal moi, roi chay lai file nay."
  exit 1
fi

if [ -f "../data/offline_exam.db" ]; then
  cp "../data/offline_exam.db" "assets/offline_exam.db"
fi

flutter pub get
flutter build ipa --release

mkdir -p "../dist"
IPA_PATH="$(find build/ios/ipa -name '*.ipa' | head -n 1)"
if [ -z "$IPA_PATH" ]; then
  echo "Khong tim thay file .ipa. Mo Xcode de ky app:"
  echo "  open ios/Runner.xcworkspace"
  echo "Roi chay lai script nay."
  exit 1
fi

cp "$IPA_PATH" "../dist/ATC_Offline_Mobile_iOS.ipa"
echo "Da dong goi xong: ../dist/ATC_Offline_Mobile_iOS.ipa"
