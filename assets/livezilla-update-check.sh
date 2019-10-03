#!/bin/sh

VERSION=$(livezilla-version)
UPGRADE_CHECK=$(livezilla-upgradecheck)

if [ "$UPGRADE_CHECK" = "notinstalled" ] || [ "$UPGRADE_CHECK" = "upgrade" ]; then
    if [ "$UPGRADE_CHECK" = "notinstalled" ]; then echo "Not installed\nDoing basic install of version: $LIVEZILLA_VERSION"; fi
    if [ "$UPGRADE_CHECK" = "upgrade" ]; then echo "Upgrade needed\nUpgrading from version $VERSION to $LIVEZILLA_VERSION"; fi
    echo "Downloading package from $PACKAGE_URL"
    if [ ! -d "/tmp/livezilla-temp" ]; then
        mkdir "/tmp/livezilla-temp"
    fi
    curl -s $PACKAGE_URL -o /tmp/livezilla-temp/livezilla-current.zip
    if [ -f "/tmp/livezilla-temp/livezilla-current.zip" ]; then
        unzip -q -o /tmp/livezilla-temp/livezilla-current.zip -d "/tmp/livezilla-temp"
        if [ -d "/tmp/livezilla-temp/livezilla" ]; then
            cp -Rf "/tmp/livezilla-temp/livezilla/." "/var/www/html/"
            chown -R www-data:www-data /var/www/html
            echo "Livezilla version $LIVEZILLA_VERSION installed in /var/www/html\nPlease complete installation via Browser"
        else
            echo "Folder missing /tmp/livezilla - something went wrong"
            exit 1
        fi
    else
        echo "File missing - unable to download"
        exit 1
    fi
elif [ "$UPGRADE_CHECK" = "current" ]; then
    echo "Installed version is already current: $LIVEZILLA_VERSION"
elif [ "$UPGRADE_CHECK" = "newer" ]; then
    echo "Installed version is newer than in Docker Image - Downgrade is not supported\nInstalled: $VERSION\nWanted version: $LIVEZILLA_VERSION"
    exit 1
fi

if [ -d "/tmp/livezilla-temp" ]; then
    rm -Rf "/tmp/livezilla-temp"
fi
