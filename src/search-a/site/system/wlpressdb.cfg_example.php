<?php

////////////////////////////////////////////////////////////////////////
// wlpressdb // WikiLeaks Press news archive database // version 0.80 //
////////////////////////////////////////////////////////////////////////

// rename wlpressdb.cfg_example.php to wlpressdb.cfg.php if you're done editing this file.

// configuration data

// PostgreSQL credentials
$dbname = "";
$dbhost = "localhost";
$dbport = 5432;
$dbuser = "";
$dbpass = "";

// exit page after session logout, blank for login screen
$session_exit_url = 'http://abc.com/';

// debug mode (boolean)
$debug = isset($debug) ? ($debug) : false;
#$debug = true;

?>
