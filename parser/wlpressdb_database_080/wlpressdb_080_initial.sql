------------------------------------------------------------------------
-- wlpressdb -- WikiLeaks Press news archive database -- version 0.80 --
------------------------------------------------------------------------

-- wlpressdb initial data data
-- version 0.80 for PostgreSQL 8.3
-- 2012-02-25
-- author: Cabledrummer <jack.rabbit@cabledrum.net>


SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET default_tablespace = '';
SET default_with_oids = false;


-- table users ---------------------------------------------------------

-- initial system users

INSERT INTO users (loginname, passwd, mailaddr, is_enabled) VALUES 
	('Cabledrummer', '', 'jack.rabbit@cabledrum.net', 1),
	('wlpress', '', 'wlpress@wikileaks-press.org', 1);


-- table session_cfg ---------------------------------------------------

-- defaults: 4 hours session TTL, 15 minutes idle time

UPDATE session_cfg SET max_ttl = 240, max_idle = 15;


-- table categories ----------------------------------------------------

INSERT INTO categories (cat_id, listpos, category) VALUES 
	('SPF', 10, 'The Spy Files'),
	('GNT', 12, 'The Guantánamo Files'),
	('CGT', 14, 'The State Department Cables'),
	('IWL', 16, 'The Iraq War Logs'),
	('AWL', 18, 'The Afghan War Logs'),
	('CLM', 20, 'Collateral Murder'),
	('IMP', 50, 'Impact of leaks'),
	('WBI', 60, 'Whistle-blower issues');


-- table domain_blacklist ----------------------------------------------

INSERT INTO domain_blacklist (domain) VALUES 
	('wikileaks-press.org');

-- ***
