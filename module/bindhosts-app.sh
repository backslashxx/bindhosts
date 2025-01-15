#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:/data/data/com.termux/files/usr/bin:$PATH
# Replace with your repository details
REPO_OWNER="itejo443"
REPO_NAME="BindHosts-app"

# App package name
APP_PACKAGE="me.itejo443.bindhosts"

# Temporary directory to store the APK
TEMP_DIR="/data/local/tmp/bindhosts-app"
APK_PATH="$TEMP_DIR/app.apk"

# Create necessary directories
mkdir -p "$TEMP_DIR"

download() {
	if command -v curl > /dev/null 2>&1; then
		curl --connect-timeout 10 -Ls "$1"
        else
		busybox wget -T 10 --no-check-certificate -qO - "$1"
        fi
}    

# Get the latest release URL using curl, grep, and sed
latest_release_url=$(download "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" \
    | grep '"browser_download_url":' \
    | sed -E 's/.*"browser_download_url": "(.*\.apk)".*/\1/')

# Check if the URL is valid
if [ -z "$latest_release_url" ]; then
    echo "Error: Could not find a latest release URL."
    exit 1
fi

echo "Latest APK URL: $latest_release_url"

# Download the APK file using download()
download "$latest_release_url" > "$APK_PATH" || echo "[x] Failed to download the APK."

# Install the APK as a user app
pm install -r "$APK_PATH" 2>&1 </dev/null | cat

# Check if the installation was successful by verifying the app's presence
pm path "$APP_PACKAGE" > /dev/null 2>&1 && {
    echo "APK installed successfully as a user app."
    echo "[+] BindHosts-app Installed"
    echo "[+] Enable SU with Capabilities"
    echo "[+] Enable Tile Bindhosts-app Tile && Notification Permission"
} || {
    echo "[x] Failed to install apk."
    # Save the APK to the failsafe directory if devpts hooks fail
    mkdir -p /sdcard/Download/bindhosts-app
    cp -f "$APK_PATH" /sdcard/Download/bindhosts-app/app.apk
    echo "[*] Please manually install app from /sdcard/Download/bindhosts-app"
}

# Clean up
rm -rf "$TEMP_DIR"
