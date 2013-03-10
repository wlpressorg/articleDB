<?php

////////////////////////////////////////////////////////////////////////
// wlpressdb // WikiLeaks Press news archive database // version 0.80 //
////////////////////////////////////////////////////////////////////////

// sample page for article parser usage

require("system/wlpressdb.inc.php");
require('system/article_parser.php');

// blacklisted user?
// (part of session controller, does not belong to the article parser)
if (ip_blacklisted()) die("Rejected");

// get url to parse from
$url = ((isset($_GET)) && (isset($_GET['url']))) ? rawurldecode($_GET['url']) : false;

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta http-equiv="content-style-type" content="text/css">
<meta name="robots" content="noindex,nofollow">
<link rel="stylesheet" href="wlpressdb.css" type="text/css">
<title>wlpressdb: article parser</title>
</head>
<body onload="document.getElementById('loading').style.display='none'">
<?php logout_box(); ?>
<div id="loading"></div>
<h1>wlpressdb: article parser</h1>
<?php
flush();

// the next 5 lines are all what's needed for the article parser
// on success $attr contains all relevant data as associative array
$article = $attr = $errmsg = false;
if ($url) {
	$article = parse_article($url, $errmsg);
	if ($errmsg) echo "<p><b>ERROR</b>: ".$errmsg."</p>\n";
	else if ($article) $attr = $article->properties;
}

// the rest of this file is demo output only

if ($attr) {
	print "
<form>
<table class='tbl1'>
	<tr>
		<td>URL:</td>
		<td><a href='".$attr['url']."' target='_blank'>".$attr['url']."</a></td>
	</tr>
	<tr>
		<td>Title:</td>
		<td><input name='headline' type='text' value='".str_replace("'", "&#039;", $attr['title'])."'></td>
	</tr>
	<tr>
		<td>Published:</td>
		<td>";
	if ($attr['pubdate']) echo date("d M Y", strtotime($attr['pubdate']));
	else echo "<input name='pubdate' type='text'>";

	print "<td>
	</tr>
	<tr>
		<td>Language:</td>
		<td>".$attr['language']."</td>
	</tr>
	<tr>
		<td>Description:</td>
		<td><textarea name='description'>".str_replace("'", "&#039;", $attr['description'])."</textarea></td>
	</tr>
	<tr>
		<td>Categories:</td>
		<td><select name='categories' multiple>";
	// sample for database access
	// database connection is done in wlpressdb.inc.php (included above)
	$query = "SELECT cat_id, category FROM categories ORDER BY listpos";
	$rs = pg_query($db, $query);
	while ($row = pg_fetch_array($rs)) {
		echo "<option value='".$row['cat_id']."'>".$row['category']."</option>\n";
	}
	print "</select></td>
	</tr>
	<tr>
		<td>Tags:</td>
		<td><textarea name='tags'>";
	if (is_array($attr['keywords'])) {
		foreach ($attr['keywords'] as $tag) echo str_replace("'", "&#039;", $tag)."\n";
	}
	print "</textarea></td>
	</tr>";
	if ($attr['image']) {
		// show related image
		$x = $attr['image']['width'];
		$y = $attr['image']['height'];
		// limit dimensions to 180 x 120
		if ($x > 180) {
			$y = round($y * 180 / $x);
			$x = 180;
		}
		if ($y > 120) {
			$x = round($x * 120 / $y);
			$y = 120;
		}
		print "
	<tr>
		<td>Image:</td>
		<td><img src='".$attr['image']['url']."' width='$x' height='$y'></td>
	</tr>";
	}
	if ($attr['media']) {
		// media organisation identified, data from database
		$md = $attr['media'];
		print "
	<tr>
		<td>Publisher:</td>
		<td>".$md['media_en'];
		if ($md['media_en'] != $md['media_nt']) echo "<br>".$md['media_nt'];
		print "</td>
	</tr>
	<tr>
		<td>Country:</td>
		<td>".$md['country']."</td>
	</tr>
	<tr>
		<td>Region:</td>
		<td>".$md['region']."</td>
	</tr>";
	if ($md['continent']) print "
	<tr>
		<td>Continent:</td>
		<td>".$md['continent']."</td>
	</tr>";
	print "
	<tr>
		<td>Homepage:</td>
		<td><a href='".$md['homepage']."' target='_blank'>".$md['homepage']."</a></td>
	</tr>";
	}

echo "\n</table>\n";
if ($attr['pubdate']) echo "<input name='pubdate' type='hidden' value='".$attr['pubdate']."'>\n";
if ($attr['media']) echo "<input name='media_id' type='hidden' value='".$attr['media']['media_id']."'>\n";
echo "<input name='lng_id' type='hidden' value='".$attr['lng_id']."'>\n";
echo "</form>\n";
}

else {
	// no valid URL given, show input from
	print "
<form id='urlform' action='".$_SERVER['PHP_SELF']."' method='get'>
URL: 
<input class='urltxt' type='text' name='url' value='".$url."'>
<input type='submit' value='submit'>
</form>
<script type='text/javascript'>
<!--
document.getElementById('urlform').url.focus()
-->
</script>\n";
}

?>
</body>
</html>
