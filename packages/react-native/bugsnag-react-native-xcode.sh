#/bin/bash

set -o errexit

# Define NVM_DIR and source the nvm.sh setup script
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  . "$HOME/.nvm/nvm.sh"
elif [[ -x "$(command -v brew)" && -s "$(brew --prefix nvm)/nvm.sh" ]]; then
  . "$(brew --prefix nvm)/nvm.sh"
fi

# Set up the nodenv node version manager if present
if [[ -x "$HOME/.nodenv/bin/nodenv" ]]; then
  eval "$("$HOME/.nodenv/bin/nodenv" init -)"
elif [[ -x "$(command -v brew)" && -x "$(brew --prefix nodenv)/bin/nodenv" ]]; then
  eval "$("$(brew --prefix nodenv)/bin/nodenv" init -)"
fi

# Set up the ndenv of anyenv if preset
if [[ ! -x node && -d ${HOME}/.anyenv/bin ]]; then
  export PATH=${HOME}/.anyenv/bin:${PATH}
  if [[ "$(anyenv envs | grep -c ndenv )" -eq 1 ]]; then
    eval "$(anyenv init -)"
  fi
fi

INFO_PLIST=$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH
APP_VERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "$INFO_PLIST")
BUNDLE_VERSION=$(/usr/libexec/PlistBuddy -c "print :CFBundleVersion" "$INFO_PLIST")

API_KEY="$BUGSNAG_API_KEY"
if [ -z "$API_KEY" ]; then
  API_KEY=$(/usr/libexec/PlistBuddy -c "print :bugsnag:apiKey" "$INFO_PLIST" || echo)
fi
if [ -z "$API_KEY" ]; then
  echo "No Bugsnag API key detected - add your key to your Info.plist or BUGSNAG_API_KEY environment variable"
  exit 1
fi

DEST="$CONFIGURATION_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH"

BUNDLE_FILE="$DEST/main.jsbundle"
if [ ! -f "$BUNDLE_FILE" ]; then
  echo "Skipping source map upload because app has not been bundled."
  exit 0
fi

if [ -z "$SOURCE_MAP" ]; then
  echo "Warning: SOURCE_MAP was not specified, falling back to $BUNDLE_FILE.map"
  SOURCE_MAP="$BUNDLE_FILE.map"
fi
if [ ! -f "$SOURCE_MAP" ]; then
  echo "Error: SOURCE_MAP $SOURCE_MAP could not be found."
  echo "Ensure the --sourcemap-output option is passed to the react-native bundle command."
  exit 1
fi

# This script gets executed in the <project_root>/ios directory
PROJECT_ROOT=${PWD%\/ios}

ARGS=(
    "--api-key" "$API_KEY"
    "--app-bundle-version" "$BUNDLE_VERSION"
    "--app-version" "$APP_VERSION"
    "--bundle" "$BUNDLE_FILE"
    "--platform" "ios"
    "--source-map" "$SOURCE_MAP"
    "--project-root" "$PROJECT_ROOT"
    )

case "$CONFIGURATION" in
  *Debug*)
    ARGS+=("--dev")
    ;;
esac

if [ ! -z "$ENDPOINT" ]; then
  ARGS+=("--endpoint")
  ARGS+=("$ENDPOINT")
fi

../node_modules/.bin/bugsnag-source-maps upload-react-native "${ARGS[@]}"
