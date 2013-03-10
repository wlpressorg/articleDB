wlpressdb session controller
----------------------------

wlpressdb comes with a handsome session controller in order to manage 
access of privileged system users and distinguish them from regular 
frontend users.

The session controller does not utilise PHP sessions does it's own 
database-supported management. It can be used beside a PHP session 
management if required.

A session gets terminated after 15 minutes idle time but latest after 
4 hours (both configurable). Also, a session can be terminated by 
clicking the Logout button or by closing the browser window.

The session controller consist of a php class and some related database 
tables. The php class session_controller (file session.inc.php) is bound 
by wlpressdb.inc:

   // session controller
   $sc = new session_controller();
   if ((isset($_POST)) && (isset($_POST['logout']))) $sc->logout();
   $session = $sc->get_session();

The class has 2 public functions:
-  get_session ()
   checks for valid session, forces login if required
   returns session data array for valid sessions, or false

-  logout()
   terminates the current session

Setting a page as "restricted to system users only" is done with:
   define ('RESTRICTED', true);
at the beginning of a script, before wlpressdb.inc is bound.
On regular pages w/o RESTRICTED flag the session controller is active 
too to track running sessions. This allows to embed additional functions 
that are visible/accessable for logged users only.

If 'RESTRICTED' is defined as true and the user is not logged in, 
login is forced using login.inc.php (defined as $login_template).

The session controller makes use of 3 datbase tables:
   - users
   - sessions
   - session_cfg


