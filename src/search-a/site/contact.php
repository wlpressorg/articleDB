<!DOCTYPE html>
<html lang=en>
<head>
	<meta charset=UTF-8>
	<meta name=viewport content="width=device-width, minimum-scale=1.0, maximum-scale=1.0">
	<meta name="keywords" content="gifiles, stratfor, wikileaks-press, search engine, wikileaks, full, text, search">
	<meta name="description" content="A tool allowing you to perform full-text search and browse the leaked GIFiles released by Wikileaks">


	<title>WLPress - Article Database</title>
	
	<!-- The framework -->
	<link rel=stylesheet href=../core/css/inuit.css>
	<!-- Plugins -->
	<link rel=stylesheet href=css/igloos.css>
	<!-- style -->
	<link rel=stylesheet href=css/style.css>
</head>
<body class=wrapper>
	
	<div class=header>
       <center>
<a href="http://wikileaks-press.org/" class=logo title="Visit our homepage"><img src=img/logo.png alt="WLPress logo"></a>
        <br />
		<?
			include_once('./inc/functions.inc.php');
			foreach($menu as $label => $link)
			echo "- <a href='".$link."'>".$label."</a> ";
		?>
        <?
        echo "-";
        ?>
      </center>
	</div>

	<div class=grids>
		<div class=grid-12>
			
            <p></p>            
			
			<h2>Contact</h2>
			
			<p>This page lists all our contact details.</p>


<h3><strong>Email</strong></h3>
<p>Any comments or feedback for the project can be sent to:  <tt>contact<span style="display: none;"> </span>@wikileaks-press.org</tt></p>
<p>To contact the project&#8217;s organizers: <tt>wlpress<span style="display: none;"> </span>@<span style="display: none;"> </span>wikileaks-press.org</tt></p>

<h3>Jabber + off-the-record encryption</h3>
<p>We have a jabber account with off-the-record enabled:  <tt>wlpress@jabber.ccc.de</tt></p>
<p>Instructions for setting up off-the-record encryption: with pidgin (<a href="http://wikileaks-press.org/pidgin.flv">video</a>), with adium (<a href="http://wikileaks-press.org/adium.flv">video</a>).</p>

<h3>Chat (IRC)</h3>
<p>We invite everyone to visit our private IRC.  Feel free to join if you would like to contact us about our work, if you would like to participate in the project, or if you would simply like to chat.</p>
<p><strong>Connecting via web interface (quick and easy): </strong> If you would like to visit our chat room through your web browser, without needing to install any additional programs, you can do so by <a href="https://wikileaks-press.org/chat/?channels=wlpress">clicking here</a>.*</p>
<p>* <em>While the web interface is a quick and easy solution for reaching us, it may be vulnerable to eavesdropping.  Please consider installing an <a href="http://en.wikipedia.org/wiki/Comparison_of_Internet_Relay_Chat_clients">irc client</a> if you would like to take advantage of more robust security features as SSL+Tor (as described below).</em></p>
<p><em> </em></p>
<p><em> </em></p>
<p><strong>Connecting via IRC client (SSL):</strong> You can connect to our chat using an IRC client.  The chat address is chat.wikileaks-press.org (SSL) 6697</p>
<p>SHA1: 70 58 1F 2E 3C A1 15 3D 64 A2 C3 3B F4 39 82 D0 47 E1 06 4B<br />
SHA256: 8E 8D D7 C4 4A 1D 9E 8A 07 8F AC 51 6C C2 5B 4C 74 58 7D 04 B1 E8 79 6F D3 5E 47 0B 1D 0D 93 26<br />
Serial Number: 04:48:04</p>
<p><strong>Connecting anonymously via IRC client (Tor):</strong> You can also connect to our chat over Tor hidden services at the following onion address &#8211; pr5ahwxrf35lipjw.onion</p>
			
		</div><!-- /grid-6 -->
<hr>		
		<div class=grids>

		
		</div><!-- /grids -->
	
	<div class=footer>
		<p>This tool is provided by <a href="http://wikileaks-press.org/">WikiLeaks-Press</a>, <a href="https://www.cabledrum.net/">cabledrum</a> and various other contributors.</p>
	</div>
	
</body>
</html>
