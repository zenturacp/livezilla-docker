#!/bin/sh

VERSION=$(livezilla-version)

if [ $VERSION != $LIVEZILLA_VERSION ]; then
    echo "Current version: $VERSION\nWanted Version: $LIVEZILLA_VERSION\nDoing install/update"
    echo "Downloading package from $PACKAGE_URL"
    if [ ! -d "/tmp/livezilla-temp" ]; then
        mkdir "/tmp/livezilla-temp"
    fi
    curl -s $PACKAGE_URL -o /tmp/livezilla-temp/livezilla-current.zip
    if [ -f "/tmp/livezilla-temp/livezilla-current.zip" ]; then
        unzip -o /tmp/livezilla-temp/livezilla-current.zip -d "/tmp/livezilla-temp"
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
else
    echo "Current version installed: $VERSION\nWanted version: $LIVEZILLA_VERSION\nNothing to do - skipping upgrade"
fi

if [ -d "/tmp/livezilla-temp" ]; then
    rm -Rf "/tmp/livezilla-temp"
fi
