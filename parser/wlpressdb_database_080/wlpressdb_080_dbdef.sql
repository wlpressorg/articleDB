------------------------------------------------------------------------
-- wlpressdb -- WikiLeaks Press news archive database -- version 0.80 --
------------------------------------------------------------------------

-- wlpressdb database structure
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


------------------------------------------------------------------------
-- stored procedures ---------------------------------------------------
------------------------------------------------------------------------

-- CREATE LANGUAGE plpgsql;

-- function set_timestamps ---------------------------------------------

-- sets 'created' and/or 'modified' timestamps (trigger)

CREATE FUNCTION set_timestamps() RETURNS TRIGGER AS '
BEGIN
	IF (TG_OP = ''INSERT'') THEN
		NEW.created := CAST (EXTRACT(EPOCH FROM NOW()) AS INTEGER);
		IF (TG_TABLE_NAME = ''users'') OR (TG_TABLE_NAME = ''media'') 
		OR (TG_TABLE_NAME = ''articles'') THEN
			NEW.modified := NEW.created;
		END IF;
	ELSIF (TG_OP = ''UPDATE'') THEN
		NEW.created := OLD.created;
		NEW.modified := CAST (EXTRACT(EPOCH FROM NOW()) AS INTEGER);
	END IF;
	RETURN NEW;
END;'
LANGUAGE 'plpgsql';

COMMENT ON FUNCTION set_timestamps() 
	IS 'sets ''created'' and/or ''modified'' timestamps (trigger)';


-- function compact ----------------------------------------------------

-- converts a string to a compacted format for comparison:
-- > converts to lower case
-- > converts html entities to characters
-- > converts accented characters to basic form
-- > resolves ligature characters into two characters
-- > removes all characters except a-z

CREATE FUNCTION compact (VARCHAR) RETURNS VARCHAR AS '
DECLARE
	str         VARCHAR;
BEGIN
	str = lower($1);
	IF strpos(str, ''&'') > 0 THEN
		str = replace(str, ''&aacute;'', ''a'');
		str = replace(str, ''&atilde;'', ''a'');
		str = replace(str, ''&aring;'',  ''a'');
		str = replace(str, ''&agrave;'', ''a'');
		str = replace(str, ''&acirc;'',  ''a'');
		str = replace(str, ''&auml;'',   ''ae'');
		str = replace(str, ''&aelig;'',  ''ae'');
		str = replace(str, ''&ccedil;'', ''c'');
		str = replace(str, ''&eacute;'', ''e'');
		str = replace(str, ''&euml;'',   ''e'');
		str = replace(str, ''&egrave;'', ''e'');
		str = replace(str, ''&ecirc;'',  ''e'');
		str = replace(str, ''&iacute;'', ''i'');
		str = replace(str, ''&iuml;'',   ''i'');
		str = replace(str, ''&igrave;'', ''i'');
		str = replace(str, ''&icirc;'',  ''i'');
		str = replace(str, ''&ntilde;'', ''n'');
		str = replace(str, ''&oacute;'', ''o'');
		str = replace(str, ''&otilde;'', ''o'');
		str = replace(str, ''&eth;'',    ''o'');
		str = replace(str, ''&ograve;'', ''o'');
		str = replace(str, ''&ocirc;'',  ''o'');
		str = replace(str, ''&ouml;'',   ''oe'');
		str = replace(str, ''&oslash;'', ''oe'');
		str = replace(str, ''&szlig;'',  ''ss'');
		str = replace(str, ''&ugrave;'', ''u'');
		str = replace(str, ''&ucirc;'',  ''u'');
		str = replace(str, ''&uacute;'', ''u'');
		str = replace(str, ''&uuml;'',   ''ue'');
		str = replace(str, ''&yacute;'', ''y'');
		str = replace(str, ''&yuml;'',   ''y'');
	END IF;
	str = translate(
		str,
		''æǽøœǿàáâãåāăąǎǻạảấầẩẫậắằẳẵặçćĉċčďđèéêëēĕėęěẹẻẽếềểễệƒĝğġģĥħìíîï''
		|| ''ĩīĭįıǐỉịĵķĸĺļľŀłñńņňŉŋðòóôõōŏőơǒọỏốồổỗộớờởỡợŕŗřśŝşšţťŧùúûũū''
		|| ''ŭůűųưǔǖǘǚǜụủứừửữựŵẁẃẅýÿŷỳỵỷỹźżž'', 
		''ääöööaaaaaaaaaaaaaaaaaaaaaacccccddeeeeeeeeeeeeeeeeefgggghhiiii''
		|| ''iiiiiiiijkklllllnnnnnnoooooooooooooooooooooorrrsssstttuuuuu''
		|| ''uuuuuuuuuuuuuuuuuwwwwyyyyyyyzzz''
	);
	str = replace(str, ''ä'', ''ae'');
	str = replace(str, ''ö'', ''oe'');
	str = replace(str, ''ü'', ''ue'');
	str = replace(str, ''ß'', ''ss'');
	RETURN regexp_replace(str, ''[^a-z]'', '''', ''g'');
END;'
LANGUAGE 'plpgsql';

COMMENT ON FUNCTION compact (VARCHAR)
	IS 'converts a string to a compacted format for comparison';


-- function set_category -----------------------------------------------

-- assigns a category to an article
-- returns 1 on success, 0 on error

CREATE FUNCTION set_category (_art_id  NUMERIC, _cat_id CHAR) 
RETURNS SMALLINT AS '
DECLARE
	buffer      NUMERIC;
BEGIN
	SELECT 1 INTO buffer FROM articles WHERE art_id = _art_id;
	IF NOT FOUND THEN
		RETURN 0;
	END IF;
	SELECT 1 INTO buffer FROM categories WHERE cat_id = _cat_id;
	IF NOT FOUND THEN
		RETURN 0;
	END IF;
	SELECT 1 INTO buffer FROM cat_cross 
	WHERE art_id = _art_id AND cat_id = _cat_id;
	IF FOUND THEN
		-- category already assigned
		RETURN 1;
	END IF;
	-- insert new assignment
	INSERT INTO cat_cross (art_id, cat_id) VALUES (_art_id, _cat_id);
	RETURN 1;
END;'
LANGUAGE 'plpgsql';

COMMENT ON FUNCTION set_category (NUMERIC, CHAR)
	IS 'assigns a category to an article';


-- function set_tag ----------------------------------------------------

-- assigns a tag to an article
-- creates the tag if it does not exist
-- returns 1 on success, 0 on error

CREATE FUNCTION set_tag (_art_id  NUMERIC, _tag VARCHAR) 
RETURNS SMALLINT AS '
DECLARE
	buffer      NUMERIC;
	_tag_id     NUMERIC;
	_tag_match  VARCHAR;
BEGIN
	SELECT 1 INTO buffer FROM articles WHERE art_id = _art_id;
	IF NOT FOUND THEN
		RETURN 0;
	END IF;
	IF LENGTH(_tag) > 40 THEN
		RETURN 0;
	END IF;
	_tag_match = compact(_tag);
	IF LENGTH(_tag_match) = 0 THEN
		RETURN 0;
	END IF;
	SELECT tag_id INTO _tag_id FROM tags WHERE tag_match = _tag_match;
	IF FOUND THEN
		SELECT 1 INTO buffer FROM tag_cross 
		WHERE _art_id = _art_id AND tag_id = _tag_id;
		IF FOUND THEN
			-- tag already assigned
			RETURN 1;
		END IF;
	ELSE
		-- insert new tag
		INSERT INTO tags (tag, tag_match) VALUES (_tag, _tag_match);
		SELECT tag_id INTO _tag_id FROM tags WHERE tag_match = _tag_match;
	END IF;
	-- insert new assignment
	INSERT INTO tag_cross (art_id, tag_id) VALUES (_art_id, _tag_id);
	RETURN 1;
END;'
LANGUAGE 'plpgsql';

COMMENT ON FUNCTION set_tag (NUMERIC, VARCHAR)
	IS 'assigns a tag to an article, creates the tag if required';


-- function set_tag_match ----------------------------------------------

-- sets ''tag_match'' to compact(tag), trigger

CREATE FUNCTION set_tag_match() RETURNS TRIGGER AS '
BEGIN
	NEW.tag_match := compact(NEW.tag);
	RETURN NEW;
END;'
LANGUAGE 'plpgsql';

COMMENT ON FUNCTION set_tag_match() 
	IS 'sets ''tag_match'' to compact(tag), trigger';


-- function login ------------------------------------------------------

-- checks credentials, creates new session for valid user
-- updates users.lastaccess and users.sessions
-- returns session id on success or NULL on error
--
-- usage: SELECT login (loginname, md5(password), ip_addr)

CREATE FUNCTION login (usr  VARCHAR, pwd VARCHAR, ipaddr INET) 
RETURNS VARCHAR AS '
DECLARE
	usr_id      NUMERIC;
	counter     NUMERIC;
	session_id  CHAR(32);
	unixtime    INTEGER;
BEGIN
	SELECT uid, sessions INTO usr_id, counter FROM users 
		WHERE compact(loginname) = compact(usr) 
		AND passwd = pwd AND is_enabled = 1;
	IF NOT FOUND THEN
		RETURN NULL;
	END IF;
	session_id = md5(to_char(random(), ''V999999999999999''));
	unixtime = CAST (EXTRACT(EPOCH FROM NOW()) AS INTEGER);
	INSERT INTO sessions (sid, uid, ip_addr, created, lastaccess) VALUES 
		(session_id, usr_id, ipaddr, unixtime, unixtime);
	UPDATE users SET sessions = counter + 1, lastaccess = unixtime
		WHERE uid = usr_id;
	RETURN session_id;
END;'
LANGUAGE 'plpgsql';

COMMENT ON FUNCTION login (VARCHAR, VARCHAR, INET) 
	IS 'checks credentials, creates new session for valid user';


-- function logout -----------------------------------------------------

-- terminates current session
-- usage: SELECT logout (session_id)

CREATE FUNCTION logout (session_id CHAR(32)) RETURNS BOOLEAN AS '
BEGIN
	DELETE FROM sessions WHERE sid = session_id;
	RETURN true;
END;'
LANGUAGE 'plpgsql';

COMMENT ON FUNCTION logout (CHAR(32)) IS 'terminates current session';


-- function check_session ----------------------------------------------

-- checks for valid session, returns session data on existing sessions
-- terminates expired and idle sessions
-- updates lastaccess entries
--
-- usage: SELECT * FROM check_session (session_id, ip_addr)

CREATE FUNCTION check_session (session_id CHAR(32), ipaddr INET) 
RETURNS NUMERIC AS '
DECLARE
	unixtime    INTEGER;
	maxttl      INTEGER;
	maxidle     INTEGER;
	usr_id      NUMERIC;
BEGIN
	usr_id = 0;
	unixtime = CAST (EXTRACT(EPOCH FROM NOW()) AS INTEGER);
	SELECT max_ttl, max_idle INTO maxttl, maxidle FROM session_cfg;
	DELETE FROM sessions WHERE created + (maxttl * 60) < unixtime;
	DELETE FROM sessions WHERE lastaccess + (maxidle * 60) < unixtime;
	SELECT uid INTO usr_id FROM sessions JOIN users USING (uid) 
		WHERE sid = session_id AND ip_addr = ipaddr AND is_enabled = 1;
	IF FOUND THEN
		UPDATE sessions SET lastaccess = unixtime WHERE sid = session_id;
		UPDATE users SET lastaccess = unixtime WHERE uid = usr_id;
		RETURN usr_id;
	END IF;
	RETURN 0;
END;'
LANGUAGE plpgsql;

COMMENT ON FUNCTION check_session (CHAR(32), INET) 
	IS 'checks session, returns user id for valid session';


------------------------------------------------------------------------
-- table definitions ---------------------------------------------------
------------------------------------------------------------------------

-- table users ---------------------------------------------------------

CREATE TABLE users (
	uid         SERIAL       NOT NULL PRIMARY KEY,
	loginname   VARCHAR(16)  NOT NULL UNIQUE,
	passwd      CHAR(32)     NOT NULL,
	mailaddr    VARCHAR(40)  NOT NULL UNIQUE,
	is_enabled  SMALLINT     DEFAULT '0' CHECK (is_enabled IN ('0','1')),
	permissions SMALLINT     NOT NULL DEFAULT '0',
	lastaccess  INTEGER      NOT NULL DEFAULT '0',
	sessions    INTEGER      NOT NULL DEFAULT '0',
	created     INTEGER      NOT NULL,
	modified    INTEGER      NOT NULL
);

CREATE TRIGGER users_timestamps BEFORE INSERT OR UPDATE ON users 
	FOR EACH ROW EXECUTE PROCEDURE set_timestamps();

COMMENT ON TABLE users IS 'permitted system users';
COMMENT ON COLUMN users.uid IS 'numeric id, serial (PK)';
COMMENT ON COLUMN users.loginname IS 'login name, plain text';
COMMENT ON COLUMN users.passwd IS 'password, MD5';
COMMENT ON COLUMN users.is_enabled IS 'xboolean, 1 = enabled';
COMMENT ON COLUMN users.permissions IS 'additional permissions';
COMMENT ON COLUMN users.lastaccess IS 'timestamp of last access';
COMMENT ON COLUMN users.sessions IS 'login counter';
COMMENT ON COLUMN users.created IS 'creation timestamp (auto-filled)';
COMMENT ON COLUMN users.modified IS 'timestamp of last modification (auto-filled)';


-- table sessions ------------------------------------------------------

CREATE TABLE sessions (
	sid         CHAR(32)     PRIMARY KEY,
	uid         INTEGER      NOT NULL REFERENCES users
	                         ON DELETE CASCADE,
	ip_addr     INET         NOT NULL,
	created     INTEGER      NOT NULL,
	lastaccess  INTEGER      NOT NULL
);

COMMENT ON TABLE sessions IS 'user sessions, generated by login()';
COMMENT ON COLUMN sessions.sid IS 'session id, random key, MD5 (PK)';
COMMENT ON COLUMN sessions.uid IS 'user id (FK)';
COMMENT ON COLUMN sessions.ip_addr IS 'client IP address';
COMMENT ON COLUMN sessions.created IS 'creation timestamp';
COMMENT ON COLUMN sessions.lastaccess IS 'timestamp of last access';


-- table session_cfg ---------------------------------------------------

CREATE TABLE session_cfg (
	max_ttl     INTEGER NOT NULL,
	max_idle    INTEGER NOT NULL
);

INSERT INTO session_cfg VALUES (0, 0);

CREATE RULE session_cfg_ins AS ON INSERT TO session_cfg DO INSTEAD NOTHING;
CREATE RULE session_cfg_del AS ON DELETE TO session_cfg DO INSTEAD NOTHING;

COMMENT ON TABLE session_cfg IS 'session settings';
COMMENT ON COLUMN session_cfg.max_ttl IS 'max. session ttl (minutes)';
COMMENT ON COLUMN session_cfg.max_idle IS 'max. idle time (minutes)';


-- table ip_blacklist --------------------------------------------------

CREATE TABLE ip_blacklist (
	ip_addr     INET         NOT NULL PRIMARY KEY,
	created     INTEGER      NOT NULL
);

CREATE TRIGGER ip_blacklist_timestamps 	BEFORE INSERT ON ip_blacklist 
	FOR EACH ROW EXECUTE PROCEDURE set_timestamps();

COMMENT ON TABLE ip_blacklist IS 'disallowed web user ip addresses';
COMMENT ON COLUMN ip_blacklist.created IS 'IP address (PK)';
COMMENT ON COLUMN ip_blacklist.created IS 'creation timestamp (auto-filled)';


-- table regions -------------------------------------------------------

-- data source: wlpressdb_080_geodata.sql

CREATE TABLE regions (
	region_id    CHAR(3)     NOT NULL PRIMARY KEY,
	continent_id CHAR(3)     REFERENCES regions (region_id),
	listpos      SMALLINT    NOT NULL UNIQUE,
	region       VARCHAR(30) NOT NULL UNIQUE
);

COMMENT ON TABLE regions IS 'regions by UN code';
COMMENT ON COLUMN regions.region_id IS 'geoscheme code, UN M.49 (PK)';
COMMENT ON COLUMN regions.continent_id IS 'continent (recursive FK) or NULL';
COMMENT ON COLUMN regions.listpos IS 'list order for web forms';
COMMENT ON COLUMN regions.region IS 'plain text';


-- table countries -----------------------------------------------------

-- data source: wlpressdb_080_geodata.sql

CREATE TABLE countries (
	country_id  CHAR(2)      NOT NULL PRIMARY KEY,
	region_id   CHAR(3)      NOT NULL REFERENCES regions,
	country     VARCHAR(40)  NOT NULL UNIQUE
);

COMMENT ON table countries IS 'countries by ISO code';
COMMENT ON COLUMN countries.country_id IS 'country code, ISO 3166-1 ALPHA-2 (PK)';
COMMENT ON COLUMN countries.region_id IS 'geoscheme code, UN M.49 (FK)';
COMMENT ON COLUMN countries.country IS 'plain text';


-- table languages -----------------------------------------------------

-- data source: wlpressdb_080_geodata.sql

CREATE TABLE languages (
	lng_id      CHAR(2)      NOT NULL PRIMARY KEY,
	lng_en      VARCHAR(20)  NOT NULL UNIQUE,
	lng_nt      VARCHAR(20)  NOT NULL UNIQUE
);

COMMENT ON table languages IS 'languages by ISO code';
COMMENT ON COLUMN languages.lng_id IS 'language code, ISO 639-1 (PK)';
COMMENT ON COLUMN languages.lng_en IS 'plain text, english';
COMMENT ON COLUMN languages.lng_nt IS 'plain text, native language';


-- table domain_blacklist ----------------------------------------------

CREATE TABLE domain_blacklist (
	domain      VARCHAR(40)  NOT NULL PRIMARY KEY,
	created     INTEGER      NOT NULL
);

ALTER TABLE ONLY domain_blacklist ADD CONSTRAINT domain_blacklist_lowercase
	CHECK (domain = LOWER(domain));

CREATE TRIGGER domain_blacklist_timestamps BEFORE INSERT ON domain_blacklist 
	FOR EACH ROW EXECUTE PROCEDURE set_timestamps();

COMMENT ON TABLE domain_blacklist IS 'disallowed article domains';
COMMENT ON COLUMN domain_blacklist.domain IS 'domain name, lower case (PK)';
COMMENT ON COLUMN domain_blacklist.created IS 'creation timestamp (auto-filled)';


-- table media ----------------------------------------------------

-- initial data source: wlpressdb_080_media.sql

CREATE TABLE media (
	media_id    SERIAL       NOT NULL PRIMARY KEY,
	media_key   CHAR(3)      UNIQUE,
	media_en    VARCHAR(30),
	media_nt    VARCHAR(30),
	sort_en     VARCHAR(30)  UNIQUE,
	country_id  CHAR(2)      NOT NULL DEFAULT 'XX' REFERENCES countries,
	lng_id      CHAR(2)      NOT NULL DEFAULT 'xx' REFERENCES languages,
	url         VARCHAR(60)  NOT NULL DEFAULT '',
	domain      VARCHAR(40)  NOT NULL UNIQUE,
	created     INTEGER      NOT NULL,
	modified    INTEGER      NOT NULL,
	mod_user    INTEGER      REFERENCES users (uid),
	confirmed   SMALLINT     DEFAULT '0' CHECK (confirmed IN ('0','1')),
	conf_user   INTEGER      REFERENCES users (uid),
	chk_time    INTEGER      NOT NULL DEFAULT '0',
	chk_erros   SMALLINT     NOT NULL DEFAULT '0',
	chk_status  SMALLINT     NOT NULL DEFAULT '0',
	chk_msg     VARCHAR      NOT NULL DEFAULT ''
);

ALTER TABLE ONLY media ADD CONSTRAINT media_domain_lowercase
	CHECK (domain = LOWER(domain));

ALTER TABLE ONLY media
	ADD CONSTRAINT media_media_en_key UNIQUE (media_en, country_id);

ALTER TABLE ONLY media
	ADD CONSTRAINT media_mediant_key UNIQUE (media_nt, country_id);

CREATE TRIGGER media_timestamps BEFORE INSERT OR UPDATE ON media 
	FOR EACH ROW EXECUTE PROCEDURE set_timestamps();

CREATE INDEX media_country_id_index ON media (country_id);
CREATE INDEX media_lng_id_index ON media (lng_id);
CREATE INDEX media_domain_index ON media (domain);
CREATE INDEX media_chk_time_index ON media (chk_time);
CREATE INDEX media_chk_erros_index ON media (chk_erros);
CREATE INDEX media_chk_status_index ON media (chk_status);

COMMENT ON TABLE media IS 'publishing media';
COMMENT ON COLUMN media.media_id IS 'numeric id, serial (PK)';
COMMENT ON COLUMN media.media_key IS 'media key for data exchange, arbitrary ';
COMMENT ON COLUMN media.media_en IS 'plain text name, english';
COMMENT ON COLUMN media.media_nt IS 'plain text name, native language';
COMMENT ON COLUMN media.sort_en IS 'alphabetic sort order, english';
COMMENT ON COLUMN media.country_id IS 'country code (FK)';
COMMENT ON COLUMN media.lng_id IS 'language code (FK)';
COMMENT ON COLUMN media.url IS 'homepage url';
COMMENT ON COLUMN media.domain IS 'default domain, w/o host and protocol';
COMMENT ON COLUMN media.created IS 'creation timestamp (auto-filled)';
COMMENT ON COLUMN media.modified IS 'timestamp of last modification (auto-filled)';
COMMENT ON COLUMN media.mod_user IS 'last editing system user (FK)';
COMMENT ON COLUMN media.confirmed IS 'xboolean, 1 = confirmed';
COMMENT ON COLUMN media.conf_user IS 'confirming system user (FK)';
COMMENT ON COLUMN media.chk_time IS 'Timestamp of last link check';
COMMENT ON COLUMN media.chk_erros IS 'link check error counter';
COMMENT ON COLUMN media.chk_status IS 'result of last linkcheck (code)';
COMMENT ON COLUMN media.chk_msg IS 'result of last linkcheck (text)';


-- table articles ------------------------------------------------------

CREATE TABLE articles (
	art_id      SERIAL       NOT NULL PRIMARY KEY,
	media_id    INTEGER      NOT NULL REFERENCES media,
	pubdate     INTEGER      NOT NULL DEFAULT 0,
	title       TEXT         NOT NULL DEFAULT '',
	description TEXT         NOT NULL DEFAULT '',
	citation    TEXT         NOT NULL DEFAULT '',
	author      VARCHAR      NOT NULL DEFAULT '',
	url         VARCHAR      NOT NULL UNIQUE,
	img_url     VARCHAR      NOT NULL DEFAULT '',
	lng_id      CHAR(2)      REFERENCES languages,
	submit_ip   INET         NOT NULL,
	created     INTEGER      NOT NULL,
	modified    INTEGER      NOT NULL,
	mod_user    INTEGER      REFERENCES users (uid),
	confirmed   SMALLINT     DEFAULT '0' CHECK (confirmed IN ('0','1')),
	conf_user   INTEGER      REFERENCES users (uid),
	chk_time    INTEGER      NOT NULL DEFAULT '0',
	chk_erros   SMALLINT     NOT NULL DEFAULT '0',
	chk_status  SMALLINT     NOT NULL DEFAULT '0',
	chk_msg     VARCHAR      NOT NULL DEFAULT ''
);

CREATE TRIGGER articles_timestamps BEFORE INSERT OR UPDATE ON articles 
	FOR EACH ROW EXECUTE PROCEDURE set_timestamps();

CREATE INDEX articles_media_id_index ON articles (media_id);
CREATE INDEX articles_pubdate_index ON articles (pubdate);
CREATE INDEX articles_lng_id_index ON articles (lng_id);
CREATE INDEX articles_submit_ip_index ON articles (submit_ip);
CREATE INDEX articles_chk_time_index ON articles (chk_time);
CREATE INDEX articles_chk_erros_index ON articles (chk_erros);
CREATE INDEX articles_chk_status_index ON articles (chk_status);

COMMENT ON TABLE articles IS 'articles';
COMMENT ON COLUMN articles.art_id IS 'alphanumeric id, media_id || 9999';
COMMENT ON COLUMN articles.media_id IS 'publishing media (FK)';
COMMENT ON COLUMN articles.pubdate IS 'publication date, YYYYMMDD';
COMMENT ON COLUMN articles.title IS 'article headline';
COMMENT ON COLUMN articles.description IS 'plain text';
COMMENT ON COLUMN articles.citation IS 'plain text';
COMMENT ON COLUMN articles.author IS 'plain text';
COMMENT ON COLUMN articles.url IS 'article source url';
COMMENT ON COLUMN articles.img_url IS 'url of related image';
COMMENT ON COLUMN articles.lng_id IS 'language code (FK) or NULL';
COMMENT ON COLUMN articles.submit_ip IS 'IP address of submitter';
COMMENT ON COLUMN articles.created IS 'creation timestamp (auto-filled)';
COMMENT ON COLUMN articles.modified IS 'timestamp of last modification (auto-filled)';
COMMENT ON COLUMN articles.mod_user IS 'last editing system user (FK)';
COMMENT ON COLUMN articles.confirmed IS 'xboolean, 1 = confirmed';
COMMENT ON COLUMN articles.conf_user IS 'confirming system user (FK)';
COMMENT ON COLUMN articles.chk_time IS 'Timestamp of last link check';
COMMENT ON COLUMN articles.chk_erros IS 'link check error counter';
COMMENT ON COLUMN articles.chk_status IS 'result of last linkcheck (code)';
COMMENT ON COLUMN articles.chk_msg IS 'result of last linkcheck (text)';


-- table links -----------------*---------------------------------------

CREATE TABLE links (
	link_id     SERIAL       NOT NULL PRIMARY KEY,
	art_id      INTEGER      NOT NULL REFERENCES articles ON DELETE CASCADE,
	link        VARCHAR      NOT NULL,
	created     INTEGER      NOT NULL,
	chk_time    INTEGER      NOT NULL DEFAULT '0',
	chk_erros   SMALLINT     NOT NULL DEFAULT '0',
	chk_status  SMALLINT     NOT NULL DEFAULT '0',
	chk_msg     VARCHAR      NOT NULL DEFAULT ''
);

CREATE TRIGGER links_timestamps BEFORE INSERT ON links 
	FOR EACH ROW EXECUTE PROCEDURE set_timestamps();

COMMENT ON TABLE links IS 'links to article related sources';
COMMENT ON COLUMN links.link_id IS 'numeric id, serial (PK)';
COMMENT ON COLUMN links.art_id IS 'article id (FK)';
COMMENT ON COLUMN links.link IS 'related url';
COMMENT ON COLUMN links.created IS 'creation timestamp (auto-filled)';
COMMENT ON COLUMN links.chk_time IS 'Timestamp of last link check';
COMMENT ON COLUMN links.chk_erros IS 'link check error counter';
COMMENT ON COLUMN links.chk_status IS 'result of last linkcheck (code)';
COMMENT ON COLUMN links.chk_msg IS 'result of last linkcheck (text)';


-- table categories ----------------------------------------------------

-- initial data source: wlpressdb_080_initial.sql

CREATE TABLE categories (
	cat_id      CHAR(3)      NOT NULL PRIMARY KEY,
	listpos     SMALLINT     NOT NULL UNIQUE,
	category    VARCHAR(30)  NOT NULL UNIQUE
);

COMMENT ON TABLE categories IS 'article categories';
COMMENT ON COLUMN categories.cat_id IS 'category key, arbitrary (PK)';
COMMENT ON COLUMN categories.listpos IS 'list order for web forms';
COMMENT ON COLUMN categories.category IS 'plain text';


-- table cat_cross -----------------------------------------------------

CREATE TABLE cat_cross (
	art_id      INTEGER      NOT NULL REFERENCES articles ON DELETE CASCADE,
	cat_id      CHAR(3)      NOT NULL REFERENCES categories ON DELETE CASCADE
);

ALTER TABLE ONLY cat_cross
	ADD CONSTRAINT cat_cross_pkey PRIMARY KEY (art_id, cat_id);

CREATE INDEX cat_cross_art_id_index ON cat_cross (art_id);
CREATE INDEX cat_cross_cat_id_index ON cat_cross (cat_id);

COMMENT ON TABLE cat_cross IS 'category allocations, cross table';


-- table tags ----------------------------------------------------------

CREATE TABLE tags (
	tag_id      SERIAL       NOT NULL PRIMARY KEY,
	tag         VARCHAR(40)  NOT NULL UNIQUE,
	tag_match   VARCHAR(40)  NOT NULL UNIQUE,
	created     INTEGER      NOT NULL
);

CREATE TRIGGER tags_match BEFORE INSERT OR UPDATE ON tags 
	FOR EACH ROW EXECUTE PROCEDURE set_tag_match();

CREATE TRIGGER tags_timestamps BEFORE INSERT ON tags 
	FOR EACH ROW EXECUTE PROCEDURE set_timestamps();

COMMENT ON TABLE tags IS 'article tags';
COMMENT ON COLUMN tags.tag_id IS 'numeric id, serial (PK)';
COMMENT ON COLUMN tags.tag IS 'plain text';
COMMENT ON COLUMN tags.tag_match IS 'compacted text for comparison (auto-filled)';
COMMENT ON COLUMN tags.created IS 'creation timestamp (auto-filled)';


-- table tag_cross -----------------------------------------------------

CREATE TABLE tag_cross (
	art_id      INTEGER      NOT NULL REFERENCES articles ON DELETE CASCADE,
	tag_id      INTEGER      NOT NULL REFERENCES tags ON DELETE CASCADE
);

ALTER TABLE ONLY tag_cross
	ADD CONSTRAINT tag_cross_pkey PRIMARY KEY (art_id, tag_id);

CREATE INDEX tag_cross_art_id_index ON tag_cross (art_id);
CREATE INDEX tag_cross_tag_id_index ON tag_cross (tag_id);

COMMENT ON TABLE tag_cross IS 'tag allocations, cross table';


-- ***

