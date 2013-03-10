------------------------------------------------------------------------
--  cabledrum  -  Full Text Index for US Embassy Cables on WikiLeaks  --
------------------------------------------------------------------------

-- GIFiles news archive
-- version 1.00 for PostgreSQL 8.3
-- 2012-03-01
-- author: Cabledrummer <jack.rabbit@cabledrum.net>


SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;
SET default_tablespace = '';
SET default_with_oids = false;


-- table gif_topics ----------------------------------------------------

CREATE TABLE gif_topics (
	topic_id    INTEGER      NOT NULL PRIMARY KEY,
	topic       VARCHAR      NOT NULL UNIQUE
);

COMMENT ON TABLE gif_topics IS 'GIFiles: Top 20 topics';


-- table gif_media -----------------------------------------------------

CREATE TABLE gif_media (
	media_id    CHAR(3)      NOT NULL PRIMARY KEY,
	media_en    VARCHAR(30),
	media_nt    VARCHAR(30),
	sort_en     VARCHAR(30)  UNIQUE,
	country_id  CHAR(2)      NOT NULL DEFAULT 'XX' REFERENCES countries,
	lng_id      CHAR(2)      NOT NULL DEFAULT 'xx' REFERENCES languages,
	partner     SMALLINT     NOT NULL DEFAULT '0' CHECK (partner IN ('0','1')),
	web_only    SMALLINT     NOT NULL DEFAULT '0' CHECK (web_only IN ('0','1')),
	domain      VARCHAR(40)  NOT NULL UNIQUE,
	homepage    VARCHAR(40)  NOT NULL
);

ALTER TABLE ONLY gif_media ADD CONSTRAINT media_domain_lowercase
	CHECK (domain = LOWER(domain));

CREATE INDEX gif_media_country_id_index ON gif_media (country_id);
CREATE INDEX gif_media_lng_id_index ON gif_media (lng_id);

COMMENT ON TABLE gif_media IS 'GIFiles: publishing media';
COMMENT ON COLUMN gif_media.media_id IS 'media key (PK)';
COMMENT ON COLUMN gif_media.media_en IS 'plain text name, english';
COMMENT ON COLUMN gif_media.media_nt IS 'plain text name, native language';
COMMENT ON COLUMN gif_media.sort_en IS 'alphabetic sort order, english';
COMMENT ON COLUMN gif_media.country_id IS 'country code (FK)';
COMMENT ON COLUMN gif_media.lng_id IS 'language code (FK)';
COMMENT ON COLUMN gif_media.partner IS 'WikiLeaks’ media partner, xboolean';
COMMENT ON COLUMN gif_media.web_only IS 'online publication only, xboolean';
COMMENT ON COLUMN gif_media.domain IS 'default domain, w/o host and protocol';
COMMENT ON COLUMN gif_media.homepage IS 'homepage url';


-- table gif_articles --------------------------------------------------

CREATE TABLE gif_articles (
	art_id      INTEGER      NOT NULL PRIMARY KEY,
	media_id    CHAR(3)      NOT NULL REFERENCES gif_media,
	topic_id    INTEGER      REFERENCES gif_topics,
	pubdate     INTEGER      NOT NULL DEFAULT 0,
	art_title   TEXT         NOT NULL DEFAULT '',
	art_url     VARCHAR      NOT NULL UNIQUE,
	lng_id      CHAR(2)      NOT NULL REFERENCES languages,
	gif_title   TEXT         NOT NULL DEFAULT '',
	gif_url     VARCHAR      NOT NULL DEFAULT '',
	wlf_url     VARCHAR      NOT NULL DEFAULT '',
	created     INTEGER      NOT NULL
);

CREATE INDEX gif_articles_media_id_index ON gif_articles (media_id);
CREATE INDEX gif_articles_pubdate_index ON gif_articles (pubdate);
CREATE INDEX gif_articles_art_title_index ON gif_articles (art_title);
CREATE INDEX gif_articles_lng_id_index ON gif_articles (lng_id);

COMMENT ON TABLE gif_articles IS 'GIFiles: articles';
COMMENT ON COLUMN gif_articles.art_id IS 'numeric id (PK)';
COMMENT ON COLUMN gif_articles.topic_id IS 'related topic for ranking (FK)';
COMMENT ON COLUMN gif_articles.media_id IS 'publishing media (FK)';
COMMENT ON COLUMN gif_articles.pubdate IS 'publication date, YYYYMMDD';
COMMENT ON COLUMN gif_articles.art_title IS 'article headline';
COMMENT ON COLUMN gif_articles.art_url IS 'article source url';
COMMENT ON COLUMN gif_articles.lng_id IS 'language code (FK)';
COMMENT ON COLUMN gif_articles.gif_title IS 'related GIF release headline';
COMMENT ON COLUMN gif_articles.gif_url IS 'related GIF release url';
COMMENT ON COLUMN gif_articles.wlf_url IS 'related WLF thread url';
COMMENT ON COLUMN gif_articles.created IS 'creation timestamp (auto-filled)';


-- table gif_tags ------------------------------------------------------

CREATE TABLE gif_tags (
	tag_id      INTEGER     NOT NULL PRIMARY KEY,
	tag         VARCHAR(30) NOT NULL UNIQUE
);

COMMENT ON TABLE gif_tags IS 'GIFiles: tags';


-- table gif_tag_aliases -----------------------------------------------

CREATE TABLE gif_tag_aliases (
	alias_id    INTEGER     NOT NULL PRIMARY KEY,
	tag_id      INTEGER     NOT NULL REFERENCES gif_tags,
	alias       VARCHAR(30) NOT NULL UNIQUE
);

COMMENT ON TABLE gif_tag_aliases IS 'GIFiles: tag aliases';


-- table gif_tag_cross -------------------------------------------------

CREATE TABLE gif_tag_cross (
	art_id      INTEGER     NOT NULL REFERENCES gif_articles ON DELETE CASCADE,
	tag_id      INTEGER     NOT NULL REFERENCES gif_tags ON DELETE CASCADE
);

ALTER TABLE ONLY gif_tag_cross
	ADD CONSTRAINT gif_tag_cross_pkey PRIMARY KEY (art_id, tag_id);

CREATE INDEX gif_tag_cross_art_id_index ON gif_tag_cross (art_id);
CREATE INDEX gif_tag_cross_tag_id_index ON gif_tag_cross (tag_id);

COMMENT ON TABLE gif_tag_cross IS 'GIFiles: tag allocations, cross table';


-- ***

