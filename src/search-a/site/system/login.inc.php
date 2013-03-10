<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<meta name="robots" content="noindex,nofollow">
<meta http-equiv="content-type" content="text/html; charset=utf8">
<title>wlpressdb login</title>
<style type="text/css">
body { margin: 30px; color: black; background-color: white; }
body, td { font: 10pt Arial, Helvetica, sans-serif; }
th { font-size: 12pt; font-weight: bold; }
th, td { padding: 0px 3px 5px 3px; }
.error { font-weight: bold; color: #C00000; }
.txtfrm {width: 140px; }
p { padding-top: 50px; margin: 5px }
</style>
</head>
<body onload="document.frm.user.focus()">
<form action="<?php echo $_SERVER['PHP_SELF']; ?>" name="frm" method="post">
<table>
	<tr>
		<td></td>
		<th>wlpressdb login</th>
		<td></td>
	</tr>
	<tr>
		<td></td>
		<td align="center"><span class="error"><?php if ($login_error) echo "Auhorization failed"; ?></span></td>
		<td></td>
	</tr>
	<tr>
		<td>User:</td>
		<td><input name="user" type="text" class="txtfrm" maxlength="20"></td>
		<td></td>
	</tr>
	<tr>
		<td>Pass:</td>
		<td><input name="pass" type="password" class="txtfrm" maxlength="20"></td>
		<td><input type="submit" class="btn" value="Login"></td>
	</tr>
</table>
</form>

<p>This is a session controller test. A session gets terminated after 15 minutes idle time but latest after 4 hours (configurable).<br>
Also, a session can be terminated by clicking the  <i>Logout</i> button or by closing the browser window.</p>

<table>
	<tr>
		<td>User:</td>
		<td>wlpress</td>
	</tr>
	<tr>
		<td>Pass:</td>
		<td>test</td>
	</tr>
</table>

</body>
</html>