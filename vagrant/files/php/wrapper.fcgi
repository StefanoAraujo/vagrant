#!/bin/bash
#
# FastCGI wrapper for PHPVER
#
# Use it in your .htaccess file as:
#
# <Files ~ "\.php$">
#         FcgidWrapper "/usr/bin/PHPVER/PHPVER-wrapper.fcgi" .php
# </Files>
#
export PATH=/usr/bin/PHPVER:/usr/sbin:/usr/local/bin:/usr/bin
export PHPRC=/etc/PHPVER/apache2
export PHP_INI_SCAN_DIR=/etc/PHPVER/apache2/conf.d
exec /usr/bin/PHPVER/php-cgi
