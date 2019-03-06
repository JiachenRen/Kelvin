#!/bin/sh
set -e
cd /tmp
rm -rf kelvin-cas
git clone https://github.com/JiachenRen/kelvin-cas.git
cd kelvin-cas
echo "Building kelvin... this may take a while, please wait..."
xcodebuild -project Kelvin.xcodeproj -scheme "macOS Command Line Tool" -configuration Release -derivedDataPath DerivedData -quiet
mv DerivedData/Build/Products/Release/kelvin /usr/local/bin
echo "Cleaning up..."
rm -rf /tmp/kelvin-cas
echo "Success. Kelvin is installed in /usr/bin/local"
echo "Example usage: kelvin -c"
