PROJECT_NAME="glide"


verifyGoInstallation() {
	GO=$(which go)
	if [ "$?" = "1" ]; then
		echo "$PROJECT_NAME needs go. Please intall it first."
		exit 1
	fi
	if [ -z "$GOPATH" ]; then
		echo "$PROJECT_NAME needs environment variable "'$GOPATH'". Set it before continue."
		exit 1
	fi
	if [ -z "$GOBIN" ]; then
		echo "$PROJECT_NAME needs environment variable "'$GOBIN'". Set it before continue."
		exit 1
	fi
	if [ ! -d "$GOBIN" ]; then
		echo "$GOBIN "'($GOBIN)'" folder not found. Please create it before continue."
		exit 1
	fi
}

initArch() {
	ARCH=$(uname -m)
	case $ARCH in
		arm*) ARCH="arm";;
		x86) ARCH="386";;
		x86_64) ARCH="amd64";;
	esac
}

initOS() {
    OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')
}

downloadFile() {
	LATEST_RELEASE_URL="https://api.github.com/repos/Masterminds/$PROJECT_NAME/releases/latest"
	LATEST_RELEASE_JSON=$(curl -s "$LATEST_RELEASE_URL")
	TAG=$(curl -s https://glide.sh/version)
	GLIDE_DIST="glide-$TAG-$OS-$ARCH.tar.gz"
	# || true forces this command to not catch error if grep does not find anything
	DOWNLOAD_URL=$(echo "$LATEST_RELEASE_JSON" | grep 'browser_' | cut -d\" -f4 | grep "$GLIDE_DIST") || true
	if [ -z "$DOWNLOAD_URL" ]; then
        echo "Sorry, we dont have a dist for your system: $OS $ARCH"
        echo "You can ask one here: https://github.com/Masterminds/$PROJECT_NAME/issues"
        exit 1
	else
		GLIDE_TMP_FILE="/tmp/$GLIDE_DIST"
        echo "Downloading $DOWNLOAD_URL"
        curl -L "$DOWNLOAD_URL" -o "$GLIDE_TMP_FILE"
	fi
}

installFile() {
	GLIDE_TMP="/tmp/$PROJECT_NAME"
	mkdir -p "$GLIDE_TMP"
	tar xf "$GLIDE_TMP_FILE" -C "$GLIDE_TMP"
	GLIDE_TMP_BIN="$GLIDE_TMP/$OS-$ARCH/$PROJECT_NAME"
	cp "$GLIDE_TMP_BIN" "$GOBIN"
}

bye() {
	result=$?
	if [ "$result" != "0" ]; then
		echo "Fail to install $PROJECT_NAME"
	fi
	exit $result
}

testVersion() {
	set +e
	GLIDE="$(which $PROJECT_NAME)"
	if [ "$?" = "1" ]; then
		echo "$PROJECT_NAME not found. Did you add "'$GOBIN'" to your "'$PATH?'
		exit 1
	fi
	set -e
	GLIDE_VERSION=$($PROJECT_NAME -v)
	echo "$GLIDE_VERSION installed succesfully"
}

# Execution

#Stop execution on any error
trap "bye" EXIT
verifyGoInstallation
set -e
initArch
initOS
downloadFile
installFile
testVersion
