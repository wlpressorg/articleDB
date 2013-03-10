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
			
			<h2>About</h2>
			
					<p>WikiLeaks Press is a volunteer-organized unofficial project <a href="http://www.wikileaks.org/Supporters.html">endorsed</a> by WikiLeaks.  Here are some of the things we currently do:</p>
<p><a href="http://wikileaks-press.org/links/"><strong>Press archive</strong></a>: For over a year, we have been curating a collection of articles which use material released by WikiLeaks; every article we find which purports to draw on WikiLeaks material will eventually appear in this collection.  In addition to archiving these articles, together with tags and other metadata, we have been saving the full text of each article; copies of the articles archive data (together with full text) may be made available upon request.  Stay tuned &#8211; this project is currently being updated.</p>
<p><a href="http://wikileaks-press.org/category/briefings/"><strong>Press digest</strong></a>: Every week, we publish digests of news and scholarly articles which make use of leaked material published by WikiLeaks.</p>
<p><a href="http://wikileaks-press.org/category/editorial/"><strong>Investigations and retrospective analysis</strong></a>: We publish our own analytical pieces and retrospective studies of how leaks have been used.  We are also <a href="http://wikileaks-press.org/contribute/">now accepting articles</a> for publication on our website.</p>
<p><a href="http://wikileaks-press.org/category/latest-news/"><strong>News aggregation</strong></a>: We aggregate news relating to WikiLeaks, press freedom, censorship, freedom of information, and whistle-blower issues.</p>
<p>In addition to these things, we have a number of <a href="http://wikileaks-press.org/get-involved/">projects</a> we would like to expand.  Don&#8217;t hesitate to get in touch if you would like to contribute!</p>
			
		</div><!-- /grid-6 -->
<hr>		
		<div class=grids>

		
		</div><!-- /grids -->
	
	<div class=footer>
		<p>This tool is provided by <a href="http://wikileaks-press.org/">WikiLeaks-Press</a>, <a href="https://www.cabledrum.net/">cabledrum</a> and various other contributors.</p>
	</div>
	
</body>
</html>
