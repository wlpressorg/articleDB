<?php

////////////////////////////////////////////////////////////////////////
// wlpressdb // WikiLeaks Press news archive database // version 0.80 //
////////////////////////////////////////////////////////////////////////

// wlpressdb article parser classes
// version 0.80
// 2012-02-25
// author: Cabledrummer <jack.rabbit@cabledrum.net>

// bind wlpressdb.inc.php for environment settings and database access
// (required for check_url() and get_language() functions)
require_once("wlpressdb.inc.php");

// bind simplehtmldom to parse Document Object Model
require('dom_parser.php');


function parse_article ($url, &$errmsg) {
	// main function, handles the complete parser process               
	//                                                                  
	//    array parse_article ( string $url, string &$errmsg )          
	//                                                                  
	// parameters:                                                      
	//    url:     absolute url of article to parse                     
	//    errmsg:  return variable for error messages,                  
	//             called by reference                                  
	//                                                                  
	// return value:                                                    
	//    returns array of article attributes, or false on error        
	$errmsg = null;
	if (!$media = check_url ($url, $errmsg)) return false;
	if (!$raw = get_contents($url, $errmsg)) return false;
	$raw = parse_attributes();
	$attr = refine_properties ($raw, $media);
	return $attr;
}


// mapping functions
// parser classes below should be called by this functions only

function get_contents ($url, &$errmsg) {
	// stage 1: get file from url
	$contents = new webget;
	$contents->get_contents ($url);
	if (DEBUG) new debug_info($contents);
	if ($contents->errmsg) {
		$errmsg = $contents->errmsg;
		return false;
	}
	return true;
};

function parse_attributes () {
	// stage 2: parse file using DOM
	$attributes = new meta_parser;
	$attributes->parse_attributes ();
	if (DEBUG) new debug_info($attributes);
	return $attributes;
}

function refine_properties ($attributes, $mediadata) {
	// stage 3: refine article attributes from DOM
	$properties = new article_parser;
	$properties->refine_properties ($attributes, $mediadata);
	if (DEBUG) new debug_info($properties);
	return $properties;
}

// callback functions using database access
// (no database access required except within these functions)

function check_url ($url, &$errmsg = "") {
	// database related helper function
	// checks if given url is valid
	// returns false on error, error message in $errmsg (call by reference)
	// determines publishing media from url
	// returns array of media data from database on success, else true
	global $db;
	if ((!isset($db)) or (!$db)) die("database connection error");
	$error = false;
	// URL syntactically valid?
	$parts = parse_url($url);
	if ((!$parts) or (!count($parts))) $error = true;
	else foreach (array('scheme', 'host') as $c) {
		if ((!isset($parts[$c])) or (!$parts[$c])) $error = true;
	}
	if ((!$error) && (!in_array($parts['scheme'], array('http', 'https')))) $error = true;
	if ($error) {
		$errmsg = "Invalid URL";
		return false;
	}
	$parts['host'] = strtolower($parts['host']);
	// check if domain is blacklisted
	$query = "SELECT 1 FROM domain_blacklist WHERE '".$parts['host']."' like '%' || domain";
	$rs = pg_query($db, $query);
	if (pg_num_rows($rs)) {
		$errmsg = "Domain not accepted";
		return false;
	}
	// check if article already exists
	$query = "SELECT 1 FROM articles WHERE url = '".pg_escape_string($url)."'";
	$rs = pg_query($db, $query);
	if (pg_num_rows($rs)) {
		$errmsg = "This article is already archived in our database.";
		return false;
	}
	// lookup publishing media data from database
	$query = "SELECT media_id, media_en, media_nt, country_id, lng_id, 
	url AS homepage, lng_en, country, r1.region, r2.region AS continent 
	FROM media 
	JOIN languages USING (lng_id)
	JOIN countries tc USING (country_id)
	JOIN regions r1 ON tc.region_id = r1.region_id
	LEFT JOIN regions r2 ON r1.continent_id = r2.region_id
	WHERE '".$parts['host']."' like '%' || domain AND confirmed = 1 
	ORDER BY LENGTH (domain) LIMIT 1";
	$rs = pg_query($db, $query);
	return (pg_num_rows($rs)) ? pg_fetch_assoc($rs) : true;
}

function get_language ($lng_id) {
	// get language from database
	global $db;
	if ((!isset($db)) or (!$db)) die("database connection error");
	$lng_id = trim(strtolower($lng_id));
	if (!preg_match('/^[a-z]{2}$/', $lng_id)) return false;
	$rs = pg_query($db, "SELECT lng_en FROM languages WHERE lng_id = '$lng_id'");
	return (pg_num_rows($rs)) ? pg_fetch_result($rs, 0, 0) : false;
}

// internal callback functions

function retrieve_url_contents () {
	// callback function for simple_html_dom
	return (isset(webget::$rawdata)) ? webget::$rawdata : null;
};

function retrieve_url () {
	// callback function for article_parser
	return (isset(webget::$realurl)) ? webget::$realurl : null;
};

////////////////////////////////////////////////////////////////////////

class meta_parser {
	public $charset  = null;
	public $title    = null;
	public $headline = null;
	public $meta = array('tags' => null, 'keywords' => null);
	public $links = array();
	
	// allowed character encodings
	// do not edit
	private $charsets = array (
		'932'         => 'SJIS',
		'936'         => 'CP936',
		'950'         => 'BIG-5',
		'ascii'       => 'ASCII',
		'big5'        => 'BIG-5',
		'cp1251'      => 'Windows-1251',
		'cp1252'      => 'Windows-1252',
		'cp936'       => 'CP936',
		'cp949'       => 'UHC',
		'cp950'       => 'BIG-5',
		'euccn'       => 'EUC-CN',
		'eucjp'       => 'EUC-JP',
		'euckr'       => 'EUC-KR',
		'euctw'       => 'EUC-TW',
		'gb18030'     => 'GB18030',
		'gb2312'      => 'CP936',
		'iso2022jp'   => 'ISO-2022-JP',
		'iso2022kr'   => 'ISO-2022-KR',
		'iso88591'    => 'ISO-8859-1',
		'iso885910'   => 'ISO-8859-10',
		'iso885913'   => 'ISO-8859-13',
		'iso885914'   => 'ISO-8859-14',
		'iso885915'   => 'ISO-8859-15',
		'iso88592'    => 'ISO-8859-2',
		'iso88593'    => 'ISO-8859-3',
		'iso88594'    => 'ISO-8859-4',
		'iso88595'    => 'ISO-8859-5',
		'iso88596'    => 'ISO-8859-6',
		'iso88597'    => 'ISO-8859-7',
		'iso88598'    => 'ISO-8859-8',
		'iso88599'    => 'ISO-8859-9',
		'jis'         => 'JIS',
		'koi8r'       => 'KOI8-R',
		'koi8ru'      => 'KOI8-R',
		'shiftjis'    => 'SJIS',
		'sjis'        => 'SJIS',
		'uhc'         => 'UHC',
		'usascii'     => 'ASCII',
		'utf16'       => 'UTF-16',
		'utf16be'     => 'UTF-16BE',
		'utf16le'     => 'UTF-16LE',
		'utf32'       => 'UTF-32',
		'utf32be'     => 'UTF-32BE',
		'utf32le'     => 'UTF-32LE',
		'utf7'        => 'UTF-7',
		'utf8'        => 'UTF-8',
		'win1251'     => 'Windows-1251',
		'win1252'     => 'Windows-1252',
		'win1254'     => 'ISO-8859-9',
		'windows1251' => 'Windows-1251',
		'windows1252' => 'Windows-1252',
		'windows1254' => 'ISO-8859-9'
	);

	function parse_attributes () {
		$dom = file_get_html(false);
		if (!$dom) return false;

		// determine character set
		$v = false;
		if ($dom->find("meta[charset]", null, true)) {
			$v = $this->compact_str($dom->find("meta[charset]", 0, true)->charset);
		}
		else if ($dom->find("meta[http-equiv=content-type]", null, true)) {
			$tag = $dom->find("meta[http-equiv=content-type]", 0, true)->outertext;
			if (preg_match('/content\s*=\s*".*charset\s*=\s*([^";\s]+)[";\s]/i', $tag, $regs)) {
				$v = $this->compact_str($regs[1]);

			}
		}
		if (($v) && (isset($v[$this->charsets]))) $this->charset = $this->charsets[$v];

		foreach ($dom->find("meta") as $tag) {
			$v = $this->parse_metatag($tag->outertext);
			if ($v) {
				if ($v['is_tag']) $this->meta['tags'][] = $v['value'];
				else $this->meta[$v['attr']] = $v['value'];
			}
		}
		if ($this->meta['keywords']) {
			$v = explode(',', $this->meta['keywords']);
			$this->meta['keywords'] = array();
			foreach ($v as $val) {
				if (trim($val)) $this->meta['keywords'][] = trim($val);
			}
		}
		foreach ($dom->find("link") as $tag) {
			$v = $this->parse_metalink($tag->getAllAttributes());
			if ($v) switch ($v['rel']) {
				case 'alternate': $this->links['alternate'][] = $v['link']; break;
				case 'css': $this->links['css'][] = $v['link']; break;
				default: $this->links[$v['rel']] = $v['link'];
			}
		}
		if ($dom->find('title')) $this->title = $this->utf8($dom->find('title', 0)->plaintext);
		if ($dom->find('h1')) $this->headline = $this->utf8($dom->find('h1', 0)->plaintext);
	}

	private function parse_metatag ($html) {
		if (!preg_match('/(http-equiv|name|property)\s*=\s*"([^"]+)"/i', $html, $regs)) return false;
		$attr = trim(strtolower($regs[2]));
		$is_tag = ($attr == "article:tag");
		if (!preg_match('/content\s*=\s*"([^"]+)"/i', $html, $regs)) return false;
		return array('attr' => $attr, 'value' => trim($this->utf8($regs[1])), 'is_tag' => $is_tag);
	}
	
	private function parse_metalink ($attlist) {
		$attr = array();
		foreach ($attlist as $key => $val) $attr[strtolower($key)] = $this->utf8($val);
		if (!isset($attr['rel'])) return false;
		$rel = strtolower($attr['rel']);
		if (isset($attr['type'])) $attr['type'] = strtolower($attr['type']);
		if ($rel == "alternate") return false;
		if (($rel == "stylesheet") || ((isset($attr['type'])) && ($attr['type'] == "text/css"))) return false;
		unset($attr['rel']);
		return array('rel' => $rel, 'link' => $attr);
	}
	
	private function compact_str ($str) {
		return preg_replace("/[^a-z0-9]/", "", strtolower($str));
	}

	private function utf8 ($str) {
		// converts $str to UTF8, depending on detected character encoding
		if ($this->charset) {
			// given charset
			if ($this->charset == 'UTF-8') $result = $str;
			else if (utf8_encode(utf8_decode($str)) == $str) $result = $str;
			else $result = mb_convert_encoding($str, 'UTF-8', $this->charset);
		}
		else $result = $str;
		if (!mb_check_encoding($result, 'UTF-8')) {
			// wrong or unknown encoding, try auto-detection
			$result = mb_convert_encoding($str, 'UTF-8', mb_detect_encoding($str));
		}
		if (mb_check_encoding($result, 'UTF-8')) return $result;
		// encoding failed, simple fallback
		return (utf8_encode(utf8_decode($str)) == $str) ? $str : utf8_encode($str);
	}

} // class meta_parser

////////////////////////////////////////////////////////////////////////

class article_parser {
	public $properties = array('media' => false);
	private $attr = null;
	
	// delimiter chars used in title atrribute
	private $delimiters = array(
		' - ', ' : ', ' | ', ' / ', ' ­ ', ' ¦ ', ' · ',
		' – ', ' — ', ' ― ', ' • ', ' ∙ ', ' ─ ', ' │ ',
		' ║ ', ' ■ ', ' □ ', ' ▪ ', ' ▬ ', ' ● ', ' ♦ ' 
	);

	// regExp pattern for ISO date (YYYMMDD)
	private $date_match = 
		'/(20[01][0-9]\s*[-\/]?\s*(0[1-9]|1[0-2])\s*[-\/]?\s*(0[1-9]|[12][0-9]|3[01]))(\s*[^0-9].*)*$/';
	
	// max length for keyword strings
	private $max_tag_length = 30;

	function refine_properties ($attr, $media) {
		$this->attr = $attr;
		if ((isset($media)) && (is_array($media))) {
			$this->properties['media']   = $media;
		}
		$this->properties['url']         = retrieve_url();
		$this->properties['title']       = $this->ref_title();
		$this->properties['pubdate']     = $this->ref_date();
		$this->properties['keywords']    = $this->ref_keywords();
		$this->properties['lng_id']      = $this->ref_language();
		$this->properties['description'] = $this->ref_description();
		$this->properties['image']       = $this->ref_image();
	}

	private function ref_title() {
		// determine/refine title
		$minlen = 10;
		$title = false;
		// select title source
		if (isset($this->attr->meta)) {
			if ((isset($this->attr->meta['og:title'])) && (strlen($this->attr->meta['og:title']) > $minlen))
				$title = $this->attr->meta['og:title'];
			else if ((isset($this->attr->meta['dc.title'])) && (strlen($this->attr->meta['dc.title']) > $minlen))
				$title = $this->attr->meta['dc.title'];
		}
		if ((!$title) && (isset($this->attr->title)) && (strlen($this->attr->title) > $minlen))
			$title = $this->attr->title;
		if ((!$title) && (isset($this->attr->headline)) && (strlen($this->attr->headline) > $minlen))
			$title = $this->attr->headline;
		if (!$title) return false;
		// remove preceding/trailing overhead
		// e.g. "foo corge bar | World news | The Guardian" -> "foo corge bar"
		$title = html_entity_decode($title, ENT_COMPAT, "UTF-8");
		$v = explode("\t", str_replace($this->delimiters, "\t", $title));
		if (($v) && (count($v) > 1)) {
			// choose longest segment
			$title = "";
			foreach ($v as $s) if (strlen(trim($s)) > strlen($title)) $title = trim($s);
		}
		return $title;
	}

	private function ref_date() {
		// determine publication date
		$candidates = array (
			'date', 'dc.date.issued', 'article:published_time', 'displaydate', 'pdate'
		);
		// parse ISO/RFC conform date
		foreach ($candidates as $c) if (isset($this->attr->meta[$c])) {
			$date = $this->date_check ($this->attr->meta[$c]);
			if ($date) return $date;
		}
		// last attempt: parse date from article url
		$date = $this->date_check ($this->properties['url']);
		return $date;
	}

	private function ref_keywords() {
		// determine/refine array of keywords
		$k = false;
		if ((is_array($this->attr->meta['keywords'])) && (count($this->attr->meta['keywords']))) {
			$k = $this->attr->meta['keywords'];
		}
		if ((is_array($this->attr->meta['tags'])) && (count($this->attr->meta['tags']))) {
			$k = ($k) ? array_merge($k, $this->attr->meta['tags']) : $this->attr->meta['tags'];
		}
		if (is_array($k)) {
			for ($i=0; $i<count($k); $i++) {
				$k[$i] = trim(preg_replace('/\s+/', " ", $k[$i]));
				// drop oversized keywords
				if (strlen($k[$i]) > $this->max_tag_length) $k[$i] = "";
				// drop empty keywords
				else if (!preg_match('/[a-z]/i', $k[$i])) $k[$i] = "";
				else if (isset($this->properties['media'])) {
					// drop keywords containing media org name
					if ((stripos($k[$i], $this->properties['media']['media_en']) !== false)
					|| (stripos($k[$i], $this->properties['media']['media_nt']) !== false))
						$k[$i] = "";
				}
			}
			$k = array_unique($k);
			sort ($k);
			if ((count($k)) && (!$k[0])) array_shift ($k);
		}
		if ((is_array($k)) && (count($k))) return $k;
		return false;
	}

	private function ref_language() {
		// determine content language
		$candidates = array (
			'content-language', 'dc.language', 'language', 'lang'
		);
		foreach ($candidates as $c) if (isset($this->attr->meta[$c])) {
			$lng_en = get_language($this->attr->meta[$c]);
			if ($lng_en) {
				$this->properties['language'] = $lng_en;
				return trim(strtolower($this->attr->meta[$c]));
			}
		}
		// fallback: get language from media data
		if (isset($this->properties['media'])) {
			$this->properties['language'] = $this->properties['media']['lng_en'];
			return $this->properties['media']['lng_id'];
		}
		// default: english
		$this->properties['language'] = 'English';
		return 'en';
	}

	private function ref_description() {
		// determine content description
		$candidates = array (
			'description', 'dc.description', 'og:description'
		);
		foreach ($candidates as $c) if (isset($this->attr->meta[$c])) {
			return trim($this->attr->meta[$c]);
		}
		return false;
	}

	private function ref_image() {
		// determine related image
		$img = false;
		if (isset($this->attr->meta['og:image'])) {
			$img = $this->attr->meta['og:image'];
		}
		else if ((isset($this->attr->links))
		&& (isset($this->attr->links['image_src']))
		&& (isset($this->attr->links['image_src']['href']))) {
			$img = $this->attr->links['image_src']['href'];
		}
		if (!$img) return false;
		// accept jpeg images only (to avoid logos/icons)
		if ((strtolower(substr($img, -4)) != ".jpg") 
		&& (strtolower(substr($img, -5)) != ".jpeg")) return false;
		// extend relative urls
		if ($img[0] == '/') {
			$parts = parse_url($this->properties['url']);
			$img = $parts['scheme']."://".$parts['host'].$img;
		}
		else if (substr($img, 0, 4) != "http") return false;
		// get image dimensions
		if (!$size = getimagesize($img)) return false;
		return array('url' => $img, 'width' => $size[0], 'height' => $size[1]);
	}

	private function date_check ($str) {
		// subfunc of ref_date()
		// checks if $str contains a valid calendar date
		// returns ISO date (YYYYMMDD) or false
		if (preg_match($this->date_match, $str, $regs)) {
			$dx = preg_replace('/[^0-9]/', '', $regs[1]);
			$ts = strtotime($dx);
			if (($ts < (86400 + time())) && (date("Ymd", $ts) == $dx)) return $dx;
		}
		return false;
	}

} // article_parser

////////////////////////////////////////////////////////////////////////

class webget {
	public static $rawdata = null;
	public static $realurl = null;
	public $url       = null;
	public $perma_url = null;
	public $status    = null;
	public $errmsg    = null;
	public $content   = null;
	public $redirects = 0;
	
	// max. waiting time before timeout (seconds)
	private $timeout = 10;
	
	// max. number of accepted redirects
	private $max_redirects = 5;

	function get_contents ($url, $redirects = 0, $perma_url = false) {
		$this->url       = null;
		$this->status    = null;
		$this->errmsg    = null;
		$this->content   = null;
		$this->redirects = $redirects;
		webget::$rawdata = null;
		$body = "";
		$con = parse_url($url);
		// URL syntactically valid?
		if ((!$con) or (!count($con))) $url = false;
		else {
			foreach (array('scheme', 'host') as $c) if ((!isset($con[$c])) or (!$con[$c])) $url = false;
			else if (!in_array($con['scheme'], array('http', 'https'))) $url = false;
		}
		if (!$url) { $this->errmsg = "Invalid URL"; return false; }
		if ((!isset($con['path'])) or (!$con['path'])) $con['path'] = "/";
		$con['host'] = strtolower($con['host']);
		$con['port'] = ($con['scheme'] == "http") ? 80 : 443;
		$con['protocol'] = ($con['port'] != 80) ? "ssl://" : "";
		$fp = fsockopen($con['protocol'].$con['host'], $con['port'], $errno, $errstr);
		if ($fp) {
			$header = "";
			$request = "GET ".$con['path']." HTTP/1.1\r\n"
			."Host: ".$con['host']."\r\n"
			."User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:2.0.1) Gecko/20100101 Firefox/4.0.1\r\n"
			."Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"
			."Accept-Language: en\r\n"
			."Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\n"
			."Connection: Close\r\n"
			."Pragma: no-cache\r\n"
			."Cache-Control: no-cache\r\n\r\n";
			fputs ($fp, $request);
			stream_set_timeout($fp, $this->timeout);
			$fsstat = stream_get_meta_data($fp);
			do {
				$header.= fgets( $fp, 4096 ); 
				$fsstat = stream_get_meta_data($fp);
				if ($fsstat["timed_out"]) { $this->errmsg = "Timeout"; return false; }
			} while (strpos($header, "\r\n\r\n") === false );
			while (!feof($fp)) {
				$body.=fgets($fp, 4096);
				$fsstat = stream_get_meta_data($fp);
				if ($fsstat["timed_out"]) { $this->errmsg = "Timeout"; return false; } 
			}
			fclose($fp);
			$headers = $this->decode_header($header);
			$status = (isset($headers['status'])) ? $headers['status'][1] : 0;
			if (($status) && ($status != 200)) 	$this->errmsg = $headers['status'][1]." ".$headers['status'][2];
			if ((in_array($status, array(301, 302, 303)))
			&& (isset($headers['location'])) && ($redirects < $this->max_redirects)) {
				// follow redirects (301 Moved Permanently | 302 Found | 303 See Other)
				if ($status == 302) $perma_url = $url;
				return $this->get_contents($headers['location'], ++$redirects, $perma_url);
			}
			$body = ($status == 200) ? $this->decode_body($body, $headers) : false;
		}
		if (!$status) $this->errmsg = (!@checkdnsrr($host,"A")) ? "Server does not exist" : "Connection failure"; 
		else if ($body) {
			$this->url      = ($perma_url) ? $perma_url : $url;
			$this->perma_url = $url;
			$this->status   = $status;
			$this->content  = $header.$body;
			webget::$rawdata = $this->content;
			webget::$realurl  = $this->url;
		}
		return true;
	}
	
	private function decode_header ($data) {
		$part = preg_split("/\r?\n/", $data, -1, PREG_SPLIT_NO_EMPTY);
		$headers = array ();
		for ($h = 0; $h < sizeof($part); $h++ )	{
			if ($h != 0) {
				$pos = strpos ( $part[$h], ':' );
				$k = strtolower(str_replace(' ', '', substr($part[$h], 0, $pos)));
				$v = trim(substr($part[$h], ($pos + 1)));
			}
			else {
				$k = 'status';
				$v = explode(' ', $part[$h]);
				if (count($v) > 3) {
					$v[2] = implode(" ", array_slice($v, 2));
					$v = array_slice($v, 0, 3);
				}
			}
			if ($k == 'set-cookie')	$headers['cookies'][] = $v;
			else if ($k == 'content-type') {
				if (($cs = strpos($v, ';')) !== false) $headers[$k] = substr($v, 0, $cs);
				else $headers[$k] = $v;
			}
			else $headers[$k] = $v;
		}
		return $headers;
	}
	
	private function decode_body ($body, $headers) {
		$tmp = $body;
		$eol = "\r\n";
		$add = strlen($eol);
		$body = '';
		if ( isset($headers['transfer-encoding']) && $headers['transfer-encoding'] == 'chunked') do {
			$tmp = ltrim($tmp);
			$pos = strpos($tmp, $eol);
			$len = hexdec(substr($tmp, 0, $pos));
			if ((isset($headers['content-encoding'])) && ($headers['content-encoding'] == 'gzip')) {
				 $body .= gzinflate(substr($tmp, ($pos + $add + 10), $len));
			}
			else $body .= substr($tmp, ($pos + $add), $len);
			$tmp = substr($tmp, ($len + $pos + $add));
			$check = trim($tmp);
		} while (!empty($check));
		else if ((isset($headers['content-encoding'])) && ($headers['content-encoding'] == 'gzip')) {
			$body = gzinflate(substr($tmp, 10));
		}
		else $body = $tmp;
		return $body;
	} 

} // class webget

////////////////////////////////////////////////////////////////////////

class debug_info {

	// debug function: show variable values
	// usage: bool new debug_info (mixed VARDATA)
	// VARDATA:
	//    'GLOBALS'
	//    'CONSTANTS'
	//    $variable
	//    $objectdata
	//    get_defined_vars()

	function __construct ($data, $description = "") {
		$type = false;
		if (is_string($data)) switch (strtolower($data)) {
			case 'globals':
				$data = $GLOBALS;
				$description = "GLOBALS";
				break;
			case 'vars':
				$data = get_defined_vars();
				$description = "DEFINED VARS";
				break;
			case 'constants':
				$data = get_defined_constants(true);
				$description = "CONSTANTS";
				break;
			default: $type = "STRING";
		}
		else if (is_bool($data)) {
			$data = ($data) ? "true" : "false";
			$type = "BOOLEAN";
		}
		else if (is_object($data)) {
			// object data
			$class = get_class($data);
			$data = get_object_vars($data);
			if (!$description) $description = $class;
		}
		$iid = uniqid();
		print "\n<!-- debug_info $description -->
<style type=\"text/css\">
.debug_info { background-color: #408080; margin: 15px; padding: 0px; border: 1px solid #000; font: 10pt Arial, Helvetica, sans-serif; }
.debug_info .bar { height: 22px; margin:0px; padding:0px; background-color:#408080; }
.debug_info .bar1 { float:left; padding: 0px 0px 0px 5px; margin: 3px 0px 0px 0px; font-size: 13px; }
.debug_info .bar2 { text-align:right; float:right; padding: 0px 5px 0px 0px; margin: 3px 0px 0px 0px; font-size: 14px; }
.debug_info a { color: #FFF; line-height: 8px; padding: 0px 3px; }
.debug_info .bar1 a { font-weight: bold; border: 1px solid #408080; }
.debug_info .bar2 a { font-weight: bold; border: 1px solid #FFF; }
.debug_info a:link, .debug_info a:visited { text-decoration: none; }
.debug_info a:hover { background-color: red; border: 1px solid #FFF; }
.debug_info .main { color: #000; background-color: #FFF; margin: 0px 3px 3px 3px; padding: 0px 5px; border: 1px solid #000; font-family: Arial, Helvetica, sans-serif; font-size: 10pt;  clear: both; max-height:400px; overflow:auto; display: none; }
</style>
<div class=\"debug_info\" id=\"debug_info_".$iid."\">
<div class=\"bar\"><div class=\"bar1\"><a href=\"\" onclick=\"document.getElementById('debug_box_".$iid."').style.display=(document.getElementById('debug_box_".$iid."').style.display=='block')?'none':'block'; return false\";>$description</a></div><div class=\"bar2\"><a href=\"\" onclick=\"document.getElementById('debug_info_".$iid."').style.display='none';return false;\">x</a></div></div>
<div class=\"main\" id=\"debug_box_".$iid."\"><pre>\n";
		echo ($type) ? "[".$type."] " : $description.": ";
		echo htmlentities(print_r($data, true), ENT_COMPAT, 'UTF-8', false)
		."\n</pre></div></div>\n<!-- /debug_info $description -->\n";
	}
}

?>