<?php

////////////////////////////////////////////////////////////////////////
// wlpressdb // WikiLeaks Press news archive database // version 0.80 //
////////////////////////////////////////////////////////////////////////

// session controller for system users
// called from wlpressdb.inc.php

class session_controller {

	// session cookie name
	private $session_cookie = "wlpressdb_sid";

	// login page template
	private $login_template = "system/login.inc.php";

	function get_session () {
		// checks for valid session
		// forces login if required
		// returns session data array for valid sessions (or false):
		//    sid (session id)
		//    uid (user id)
		//    user (loginname)
		//    mailaddr
		//    permissions
		global $db;
		if ((!isset($db)) or (!$db)) die("database connection error");

		// check for valid session
		$session = $this->verify_session();
		if ($session) return $session;
		if ((defined('RESTRICTED')) && (RESTRICTED)) {
			// restricted page, login required
			if ((isset($_POST)) && (isset($_POST['user'])) && (isset($_POST['pass']))) {
				// login attempt
				$user = trim(strtolower($_POST['user']));
				if ((preg_match("/^[a-z]{2,16}$/", $user)) && ($_POST['pass'])) {
					$session = $this->login($user, md5($_POST['pass']));
					// valid login
					if ($session) return $session;
				}
				// invalid login attempt
				$this->login_screen(true); 
			}
			// no valid session, login required
			$this->login_screen(false);
		}
		else return false;
	}
	
	function logout() {
		// terminate current session
		global $session_exit_url, $db;
		if ((!isset($db)) or (!$db)) die("database connection error");
		if (!isset($_COOKIE[$this->session_cookie])) return false;
		$sid = $_COOKIE[$this->session_cookie];
		if (!preg_match("/^[a-z0-9]{32}$/", $sid)) return false;
		pg_query($db, "SELECT logout('$sid')");
		setcookie($this->session_cookie, '', time() - 3600, "/", $_SERVER["HTTP_HOST"], false, true);
		if ((isset($session_exit_url)) && ($session_exit_url)) {
			header("Location: ".$session_exit_url);
			die;
		}
		$this->login_screen(false);
	}

	private function login ($user, $pass) {
		global $db;
		$query = "SELECT login('$user', '$pass', '".$_SERVER['REMOTE_ADDR']."')";
		$rs = pg_query($db, $query);
		$sid = pg_fetch_result($rs, 0, 0);
		if (!$sid) return false;
		setcookie($this->session_cookie, $sid, 0, "/", $_SERVER["HTTP_HOST"], false, true);
		return $this->verify_session ($sid);
	}

	private function verify_session ($sid = false) {
		global $db;
		if (!$sid) {
			if (!isset($_COOKIE[$this->session_cookie])) return false;
			$sid = $_COOKIE[$this->session_cookie];
			if (!preg_match("/^[a-z0-9]{32}$/", $sid)) return false;
		}
		$query = "SELECT check_session('$sid', '".$_SERVER['REMOTE_ADDR']."')";
		$rs = pg_query($db, $query);
		$uid = pg_fetch_result($rs, 0, 0);
		if (!$uid)  return false;
		$query = "SELECT '$sid' AS sid, uid, loginname AS user, mailaddr, permissions "
		."FROM users WHERE uid = '$uid'";
		$rs = pg_query($db, $query);
		return pg_fetch_assoc($rs);
	}
	
	private function login_screen ($login_error) {
		if ($login_error) sleep(2);
		include($this->login_template);
		die;
	}
}

?>