#!/bin/sh
set -e
cd /tmp
rm -rf kelvin-cas
git clone https://github.com/JiachenRen/kelvin-cas.git
cd kelvin-cas
echo "Building kelvin... this may take a while, please wait..."
xcodebuild -project Kelvin.xcodeproj -scheme "Kelvin CLI" -configuration Release -quiet CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
echo "Success."
echo "We need your permission to do some additional setup, please enter your password below."
sudo -s
rm -rf /Library/Frameworks/Kelvin.framework
mv /usr/local/bin/Kelvin.framework /Library/Frameworks/
echo "Cleaning up..."
rm -rf /tmp/kelvin-cas
echo "Success. Kelvin is installed in /usr/bin/local"
echo "Example usage: kelvin -i"
