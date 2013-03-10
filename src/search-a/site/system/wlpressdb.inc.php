<?php

////////////////////////////////////////////////////////////////////////
// wlpressdb // WikiLeaks Press news archive database // version 0.80 //
////////////////////////////////////////////////////////////////////////

// common settings and functions for wlpressdb

// load configuration
require("wlpressdb.cfg.php");
require("session.inc.php");

// debug settings
if ((isset($debug))&&($debug)) {
	ini_set('error_reporting', E_ALL);
	ini_set('display_errors', '1');
	define('DEBUG', true);
}
else {
	ini_set('error_reporting', NULL);
	ini_set('display_errors', '0');
	define('DEBUG', false);
}

// database connection
$db = pg_connect("host=$dbhost port=$dbport dbname=$dbname user=$dbuser password=$dbpass");
unset($dbhost, $dbport, $dbname, $dbuser, $dbpass);
if (!$db) die("ERROR DBC-1");

// session controller
$sc = new session_controller();
if ((isset($_POST)) && (isset($_POST['logout']))) $sc->logout();
$session = $sc->get_session();


function ip_blacklisted () {
	// check if user IP address is blacklisted
	global $db;
	$query = "SELECT 1 FROM ip_blacklist WHERE ip_addr = '".$_SERVER['REMOTE_ADDR']."'";
	$rs = pg_query($db, $query);
	return (pg_num_rows($rs));
}

function logout_box() {
	// html output of logout box
	global $session;
	if ($session) print "<!-- logout_box -->
<div class=\"logout_box\"><form name=\"logout_form\" method=\"post\" action=\"".$_SERVER['PHP_SELF']."\" method =\"post\">
<input type=\"hidden\" name=\"logout\" value=\"1\">Logged in as <b>".$session['user']."</b>
<a href=\"#\" onclick=\"document.logout_form.submit()\">Logout</a></form></div>
<!-- logout_box -->\n";
}

?>