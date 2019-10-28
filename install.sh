#!/bin/sh
set -e
cd /tmp
rm -rf kelvin-cas
git clone https://github.com/JiachenRen/kelvin-cas.git
cd kelvin-cas
echo "Building dependencies... please wait..."
carthage update BigInt --platform macOS
echo "Building kelvin... this may take a while, please wait..."
xcodebuild -project Kelvin.xcodeproj -scheme "Kelvin CLI" -configuration Release -quiet CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
echo "Cleaning up..."
rm -rf /tmp/kelvin-cas
echo "Success. Kelvin is installed in /usr/bin/local"
echo "Example usage: kelvin"
