<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<title>WLPress - Article Database</title>
		<link rel="stylesheet" href="css/style.css"/>
	</head>
<body class="wrapper">
	<header>
		<a href="http://wikileaks-press.org/" class="logo" title="Visit our homepage"><img src="img/logo.png" alt="WLPress logo"></a>

        <?  
            include_once('./inc/functions.inc.php');
            foreach($menu as $label => $link)
            echo "- <a href='".$link."'>".$label."</a> ";
        ?>  
        <?
        echo "-";
        ?>
	</header>

	<section class="grids">
		<div class="left">
			<h2>What is this website about?</h2>
      <p>Through the years we have been collecting news 
articles which features WikiLeaks related news. News regarding material,
 like cablegate, Iraq War Logs, Afghanistan War Diaries and many more. 
We bundled them in a database and stored their full-text so people can 
search the entire text.</p>            

			<h3>Discuss</h3>
			<p>If you want to discuss the material please refer to our secure <a href="http://chat.wikileaks-press.org/">chat server</a>.
			If you are not familiar with irc then feel free to <a href="https://twitter.com/wlpress">Tweet us</a>.</p>
		</div>

		<div class="right">
			<h3>I'm not a computer wizard… HELP!</h3>
			<p>You can find the crashcourse for using our search engine over 
            <a href="/crashcourse.php">here</a>.</p>
		</div>
	</section>
	<footer>
		<p>This tool is provided by <a href="http://wikileaks-press.org/">WikiLeaks-Press</a>, <a
		href="https://www.cabledrum.net/">cabledrum</a> and various other contributors.</p>
	</footer>
</body>
</html>
