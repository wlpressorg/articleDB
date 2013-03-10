<?php

////////////////////////////////////////////////////////////////////////
// wlpressdb // WikiLeaks Press news archive database // version 0.80 //
////////////////////////////////////////////////////////////////////////

// sample for login / access to restricted pages
// restricted pages only need the definition:
//   define ('RESTRICTED', true);
// at the beginning of the script, before wlpressdb.inc.php is included

define ('RESTRICTED', true);
require_once("system/wlpressdb.inc.php");

header("location: http://testing.wikileaks-press.org/");

?>
