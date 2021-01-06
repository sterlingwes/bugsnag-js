if [ "$#" -ne 1 ]
then
  echo 'Usage: build-ios.sh <react native project directory>'
  exit 1
fi

echo 'DEBUG: Running build-ios.sh'

cd rn0_60 || exit 1

echo 'DEBUG: rm -rf'

rm -rf "rn0_60.xcarchive"

cd ios || exit 1

echo 'DEBUG: pod install'

pod install || pod install --repo-update

echo 'DEBUG: xcodebuild 1'

xcrun --log xcodebuild \
  -scheme "rn0_60" \
  -workspace "rn0_60.xcworkspace" \
  -configuration Release \
  -archivePath "../rn0_60.xcarchive" \
  -allowProvisioningUpdates \
  -verbose \
  archive
echo "exit: $?"

cd ../..

echo 'DEBUG: xcodebuild 2'
ls -l
echo "In: $PWD"

xcrun --log xcodebuild -exportArchive \
  -archivePath "rn0_60/rn0_60.xcarchive" \
  -exportPath output \
  -verbose \
  -exportOptionsPlist exportOptions.plist
echo "exit: $?"

#rm -rf "rn0_60.xcarchive"
