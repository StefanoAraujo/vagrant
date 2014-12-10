#!/usr/bin/expect
spawn /usr/bin/php /vagrant/vagrant/downloads/go-pear.php
expect "1-11, 'all' or Enter to continue:"
send "1\r/usr/share/pear\r"
expect "1-11, 'all' or Enter to continue:"
send "4\r/usr/local/bin\r"
expect "1-11, 'all' or Enter to continue:"
send "5\r/usr/share/pear\r"
expect "1-11, 'all' or Enter to continue:"
send "\r\r\r"

expect eof