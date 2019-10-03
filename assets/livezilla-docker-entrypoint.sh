#!/bin/sh

APPLICATION="Livezilla Server"

# Remove Default Site
a2dissite 000-default > /dev/null

# Set Servername
if [ -z "$SERVERNAME" ]; then
    SERVERNAME=$HOSTNAME
    echo "ServerName $HOSTNAME" > /etc/apache2/conf-available/servername.conf
else
    echo "ServerName $SERVERNAME" > /etc/apache2/conf-available/servername.conf
fi
a2enconf servername > /dev/null

# Update CA Certificate
if [ -f "/etc/ssl/apache/ca.crt" ]; then
    ln -s /etc/ssl/apache/ca.crt /usr/local/share/ca-certificates/custom-ca.crt
    update-ca-certificates > /dev/null
fi

if [ -f "/etc/ssl/apache/tls.crt" ] && [ -f "/etc/ssl/apache/ca.crt" ]; then
    [ ! -d "/etc/ssl/apache-temp" ] && mkdir "/etc/ssl/apache-temp"
    cat "/etc/ssl/apache/tls.crt" "/etc/ssl/apache/ca.crt" > "/etc/ssl/apache-temp/tls-chain.crt"
    TLS_CERT="/etc/ssl/apache-temp/tls-chain.crt"
else
    TLS_CERT="/etc/ssl/apache/tls.crt"
fi

# Check if Key exists
[ -f "/etc/ssl/apache/tls.key" ] && TLS_KEY="/etc/ssl/apache/tls.key"

# If SSL enabled - add the site
if [ -f "$TLS_CERT" ] && [ -f "$TLS_KEY" ]; then
TLS_ENABLED=1
cat > /etc/apache2/sites-available/livezilla-ssl.conf << EOF
<IfModule mod_ssl.c>
        <VirtualHost *:443>
            	DocumentRoot /var/www/html
            	
                ErrorLog \${APACHE_LOG_DIR}/error.log
	            CustomLog \${APACHE_LOG_DIR}/access.log combined

                SSLEngine on
                SSLCertificateFile $TLS_CERT
                SSLCertificateKeyFile $TLS_KEY

                <IfModule mod_rewrite.c>
                RewriteEngine On
                RewriteRule ^/?knowledge-base/$ knowledgebase.php?depth=1 [QSA,L]
                RewriteRule ^/?knowledge-base/([a-zA-Z0-9_\-]+)/$ knowledgebase.php?article=$1&depth=2 [QSA,L]
                RewriteRule ^/?knowledge-base/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/$ knowledgebase.php?article=$2&depth=3 [QSA,L]
                RewriteRule ^/?knowledge-base/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/$ knowledgebase.php?article=$3&depth=4 [QSA,L]
                RewriteRule ^/?knowledge-base/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/$ knowledgebase.php?article=$4&depth=5 [QSA,L]
                </IfModule>                

        </VirtualHost>
</IfModule>
EOF
a2enmod ssl > /dev/null
a2ensite livezilla-ssl > /dev/null
fi

# Enable HTTP Site
cat > /etc/apache2/sites-available/livezilla.conf << EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

    <IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^/?knowledge-base/$ knowledgebase.php?depth=1 [QSA,L]
    RewriteRule ^/?knowledge-base/([a-zA-Z0-9_\-]+)/$ knowledgebase.php?article=$1&depth=2 [QSA,L]
    RewriteRule ^/?knowledge-base/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/$ knowledgebase.php?article=$2&depth=3 [QSA,L]
    RewriteRule ^/?knowledge-base/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/$ knowledgebase.php?article=$3&depth=4 [QSA,L]
    RewriteRule ^/?knowledge-base/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/([a-zA-Z0-9_\-]+)/$ knowledgebase.php?article=$4&depth=5 [QSA,L]
    </IfModule>                

</VirtualHost>
EOF
a2ensite livezilla > /dev/null

# Enable Rewrite Module
a2enmod rewrite > /dev/null

# Run Upgrade Check
/usr/local/bin/livezilla-update-check.sh
VERSION=$(livezilla-version)

echo "===== Starting $APPLICATION ====="
echo "Servername  : $SERVERNAME"
echo "Version     : $VERSION"
[ "$TLS_ENABLED" = "1" ] && echo "TLS Enabled : True" || echo "TLS Enabled : False"
[ "$TLS_ENABLED" = "1" ] && echo "TLS Cert    : $TLS_CERT"
[ "$TLS_ENABLED" = "1" ] && echo "TLS Key     : $TLS_KEY"
echo "===== Apache Logs ====="

docker-php-entrypoint "$@"
