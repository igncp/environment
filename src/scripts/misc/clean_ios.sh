# https://qiita.com/shtnkgm/items/c96a58579ec406194fa8

set -e

rm -rf ~/Library/Caches/com.apple.dt.Xcode/
xcodebuild clean
xcodebuild -alltargets clean
rm -rf ~/Library/Developer/Xcode/DerivedData/
xcrun --kill-cache
xcrun simctl erase all
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*/Symbols/System/Library/Caches
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang/ModuleCache"
rm -rf "$(getconf DARWIN_USER_CACHE_DIR)/org.llvm.clang.$(whoami)/ModuleCache"
rm -rf ~/Library/Caches/Homebrew
brew cleanup -s
rm -rf $(brew --cache)
rm -rf ~/Library/Caches/SwiftLint
pod cache clean --all
rm -rf ~/Library/Caches/org.carthage.CarthageKit
rm -rf ~/Library/Caches/carthage
rm ~/.fastlane/spaceship/**/cookie

echo 'Finished cleaning'
