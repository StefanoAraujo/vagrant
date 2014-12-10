REPLACE INTO `#__users`
 (`id`, `name`, `username`, `email`, `password`, `block`, `sendEmail`, `registerDate`, `lastvisitDate`, `activation`, `params`, `lastResetTime`, `resetCount`, `otpKey`, `otep`, `requireReset`)
VALUES
	(ADMIN_ID, 'ADMIN_NAME Webmaster', 'ADMIN_NAME', 'ADMIN_NAME@localhost.localdomain', 'ADMIN_PW', 0, 1, '2014-12-06 12:06:00', '0000-00-00 00:00:00', '0', '{\"editor\":\"tinymce\",\"timezone\":\"Europe\\/London\",\"language\":\"\",\"admin_style\":\"\",\"admin_language\":\"en-GB\",\"helpsite\":\"\"}', '0000-00-00 00:00:00', 0, '', '', 0);

REPLACE INTO `#__user_usergroup_map` (`user_id`, `group_id`)
VALUES
	(ADMIN_ID, 8);