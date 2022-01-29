#!/bin/sh

rm    -rf ./converting.iconset
mkdir -p  ./converting.iconset

sips -z 16 16 borochi.png --out ./converting.iconset/icon_16x16.png
sips -z 32 32 borochi.png --out ./converting.iconset/icon_16x16@2x.png

sips -z 32 32 borochi.png --out ./converting.iconset/icon_32x32.png
sips -z 64 64 borochi.png --out ./converting.iconset/icon_32x32@2x.png

sips -z 128 128 borochi.png --out ./converting.iconset/icon_128x128.png
sips -z 256 256 borochi.png --out ./converting.iconset/icon_128x128@2x.png

sips -z 256 256 borochi.png --out ./converting.iconset/icon_256x256.png
sips -z 512 512 borochi.png --out ./converting.iconset/icon_256x256@2x.png

sips -z 512 512 borochi.png --out ./converting.iconset/icon_512x512.png
# # need a larger image for this one...
# cp borochi.png ./converting.iconset/icon_512x512@2x.png

iconutil -o borochi.icns -c icns ./converting.iconset
rm -rf ./converting.iconset
mv borochi.icns ./app-template/Contents/Resources/
