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
		<div class=grid-6>
			
			<h2>Why this search engine?</h2>

                <p>This search engine has been developed to search through the GIFiles released by WikiLeaks on the 26th of February. The static pages
                provided by WikiLeaks are not elegant for researchers and journalists to search for specific keywords or topics they want to analyse.
                With providing this tool we hope to achieve maximum impact.</p>            
			
			<h3>Discuss</h3>
			
			<p>If you want to discuss the material please refer to our secure <a href="https://chat.wikileaks-press.org">IRC server</a>. If you are not familiar with irc then feel free to <a href="https://twitter.com/wlpress">Tweet us</a>.</p>
			
		</div><!-- /grid-6 -->
		
		<div class=grid-6>
<br /> <br /> <br />	
			<div class="island promo">
				<h3>I'm not a computer wizard&hellip; HELP!</h3>
				<p>You can find the crashcourse for our search engine over <a href="/help.php">here</a>.</p>
			</div>
			
		</div><!-- /grid-6 -->
	</div><!-- /grids -->
	
	<hr>

	<div class=grids>
		<div class=grid-6>
			
			<h2>What is WLPress?</h2>

<p>WikiLeaks Press is a volunteer-organized unofficial project <a href="http://www.wikileaks.org/Supporters.html">endorsed</a> by WikiLeaks.  Here are
some of the things we currently do:</p>
<p><a href="http://wikileaks-press.org/links/"><strong>Press archive</strong></a>: For over a year, we have been curating a collection of articles
which use material released by WikiLeaks; every article we find which purports to draw on WikiLeaks material will eventually appear in this
collection.  In addition to archiving these articles, together with tags and other metadata, we have been saving the full text of each article; copies
of the articles archive data (together with full text) may be made available upon request.  Stay tuned &#8211; this project is currently being
updated.</p>
<p><a href="http://wikileaks-press.org/category/briefings/"><strong>Press digest</strong></a>: Every week, we publish digests of news and scholarly
articles which make use of leaked material published by WikiLeaks.</p>
<p><a href="http://wikileaks-press.org/category/editorial/"><strong>Investigations and retrospective analysis</a></strong>: We publish our own analytical pieces and
retrospective studies of how leaks have been used.  We are also <a href="http://wikileaks-press.org/contribute/">now accepting articles</a> for
publication on our website.</p>
<p><a href="http://wikileaks-press.org/category/latest-news/"><strong>News aggregation</strong></a>: We aggregate news relating to WikiLeaks, press
freedom, censorship, freedom of information, and whistle-blower issues.</p>
<p>In addition to these things, we have a number of <a href="http://wikileaks-press.org/get-involved/">projects</a> we would like to expand.
Don&#8217;t hesitate to get in touch if you would like to contribute!</p>
	
		</div><!-- /grid-6 -->
		
		<div class=grid-6>
	
			<h3>GIFiles</h3>
	
			<p>LONDON, Monday 27 February, <br /> <br /> WikiLeaks began publishing The Global Intelligence Files – more than five million emails from the
			Texas-headquartered "global intelligence" company Stratfor. The emails date from between July 2004 and late December 2011.<br /> <br />
            
            They reveal the inner workings of a company that fronts as an intelligence publisher, but provides confidential intelligence services to large
			corporations, such as Bhopal’s Dow Chemical Co., Lockheed Martin, Northrop Grumman, Raytheon and government agencies, including the US
			Department of Homeland Security, the US Marines and the US Defense Intelligence Agency.<br /> <br />

            The emails show Stratfor’s web of informers, pay-off structure, payment-laundering techniques and psychological methods... <br /> <br />

            For comments:<br /><br />

            WikiLeaks – Kristinn Hrafnsson, Official WikiLeaks representative, +35 4821 7121 <br /><br />

            Other comment : <br /><br />
            Bhopal Medical Appeal (in UK) – Colin Toogood : colintoogood@bhopal.org / +44 (0) 1273 603278/ +44 (0) 7798 845074  <br />
            International Campaign for Justice in Bhopal (in India) – Rachna Dhingra : rachnya@gmail.com, +91 98 261 67369 <br />
            Yes Men – mike@theyesmen.org / +44 (0) 7578 682321 - andy@theyesmen.org, +1-718-208-0684  <br />
            Privacy International – +44 (0) 20 7242 2836 <br />

           <br /> Twitter tag : #gifiles <a href="https://twitter.com/#!/search/%23gifiles">Direct link</a> </p>
			
		</div><!-- /grid-6 -->
	</div><!-- /grids -->
	
	<hr>
			
		</div><!-- /grid-6 -->
	</div><!-- /grids -->
	
	<div class=footer>
		<p>This tool is provided by <a href="http://wikileaks-press.org/">WikiLeaks-Press</a>, <a href="https://www.cabledrum.net/">cabledrum</a> and various other contributors.</p>
	</div>
	
</body>
</html>
