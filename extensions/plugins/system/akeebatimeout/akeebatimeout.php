<?php
/**
 * @package        vagrant
 * @copyright      Copyright (c)2015 Nicholas K. Dionysopoulos / AkeebaBackup.com
 * @license        GNU GPLv3 <http://www.gnu.org/licenses/gpl.html> or later
 */

defined('_JEXEC') or die();

JLoader::import('joomla.plugin.plugin');

class plgSystemAkeebatimeout extends JPlugin
{
    public function onAfterInitialise()
    {
        $timeout = (int)$this->params->get('timeout', 30);

        set_time_limit($timeout);
    }
}