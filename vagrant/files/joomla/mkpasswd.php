<?php
echo trim(crypt($argv[1], '$2y$10$' . substr(str_replace('+', '.', base64_encode(openssl_random_pseudo_bytes(17))), 0, 22)));