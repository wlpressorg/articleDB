------------------------------------------------------------------------
-- wlpressdb -- WikiLeaks Press news archive database -- version 0.80 --
------------------------------------------------------------------------

-- wlpressdb geoscheme data
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


-- table regions -------------------------------------------------------

-- geoscheme codes according UN M.49

INSERT INTO regions (region_id, continent_id, listpos, region) VALUES 
	('001', NULL,    0, 'World'),
	('002', NULL,   10, 'Africa'),
	('019', NULL,   11, 'Americas'),
	('142', NULL,   12, 'Asia'),
	('150', NULL,   13, 'Europe'),
	('009', NULL,   14, 'Oceania'),
	('015', '002',  20, 'Northern Africa'),
	('011', '002',  21, 'Western Africa'),
	('017', '002',  22, 'Middle Africa'),
	('014', '002',  23, 'Eastern Africa'),
	('018', '002',  24, 'Southern Africa'),
	('021', '019',  30, 'Northern America'),
	('013', '019',  31, 'Central America'),
	('029', '019',  32, 'Caribbean'),
	('005', '019',  33, 'South America'),
	('145', '142',  40, 'Western Asia'),
	('143', '142',  41, 'Central Asia'),
	('030', '142',  42, 'Eastern Asia'),
	('034', '142',  43, 'Southern Asia'),
	('035', '142',  44, 'South-Eastern Asia'),
	('154', '150',  50, 'Northern Europe'),
	('155', '150',  51, 'Western Europe'),
	('151', '150',  52, 'Eastern Europe'),
	('039', '150',  53, 'Southern Europe'),
	('053', '009',  60, 'Australia and New Zealand'),
	('054', '009',  61, 'Melanesia'),
	('057', '009',  62, 'Micronesia'),
	('061', '009',  63, 'Polynesia');


-- table countries -----------------------------------------------------

-- country codes according ISO 3166-1 ALPHA-2

INSERT INTO countries (country_id, region_id, country) VALUES 
	('AD', '039', 'Andorra'),
	('AE', '145', 'United Arab Emirates'),
	('AF', '034', 'Afghanistan'),
	('AG', '029', 'Antigua and Barbuda'),
	('AI', '029', 'Anguilla'),
	('AL', '039', 'Albania'),
	('AM', '145', 'Armenia'),
	('AO', '017', 'Angola'),
	('AR', '005', 'Argentina'),
	('AT', '155', 'Austria'),
	('AU', '053', 'Australia'),
	('AW', '029', 'Aruba'),
	('AZ', '145', 'Azerbaijan'),
	('BA', '039', 'Bosnia Herzegovina'),
	('BB', '029', 'Barbados'),
	('BD', '034', 'Bangladesh'),
	('BE', '155', 'Belgium'),
	('BF', '011', 'Burkina Faso'),
	('BG', '151', 'Bulgaria'),
	('BH', '145', 'Bahrain'),
	('BI', '014', 'Burundi'),
	('BJ', '011', 'Benin'),
	('BM', '021', 'Bermuda'),
	('BN', '035', 'Brunei'),
	('BO', '005', 'Bolivia'),
	('BR', '005', 'Brazil'),
	('BS', '029', 'Bahamas'),
	('BT', '034', 'Bhutan'),
	('BW', '018', 'Botswana'),
	('BY', '151', 'Belarus'),
	('BZ', '013', 'Belize'),
	('CA', '021', 'Canada'),
	('CD', '017', 'Congo (Dem. Rep.)'),
	('CF', '017', 'Central African Republic'),
	('CG', '017', 'Congo'),
	('CH', '155', 'Switzerland'),
	('CI', '011', 'Ivory Coast'),
	('CL', '005', 'Chile'),
	('CM', '017', 'Cameroon'),
	('CN', '030', 'China'),
	('CO', '005', 'Colombia'),
	('CR', '013', 'Costa Rica'),
	('CU', '029', 'Cuba'),
	('CV', '011', 'Cape Verde'),
	('CW', '029', 'Curacao'),
	('CY', '145', 'Cyprus'),
	('CZ', '151', 'Czechia'),
	('DE', '155', 'Germany'),
	('DJ', '014', 'Djibouti'),
	('DK', '154', 'Denmark'),
	('DM', '029', 'Dominica'),
	('DO', '029', 'Dominican Republic'),
	('DZ', '015', 'Algeria'),
	('EC', '005', 'Ecuador'),
	('EE', '154', 'Estonia'),
	('EG', '015', 'Egypt'),
	('EH', '015', 'Western Sahara'),
	('ER', '014', 'Eritrea'),
	('ES', '039', 'Spain'),
	('ET', '014', 'Ethiopia'),
	('FI', '154', 'Finland'),
	('FJ', '054', 'Fiji'),
	('FK', '005', 'Falkland Islands'),
	('FM', '057', 'Micronesia'),
	('FO', '154', 'Faroe Islands'),
	('FR', '155', 'France'),
	('GA', '017', 'Gabon'),
	('GB', '154', 'United Kingdom'),
	('GD', '029', 'Grenada'),
	('GE', '145', 'Georgia'),
	('GF', '005', 'French Guyana'),
	('GH', '011', 'Ghana'),
	('GI', '039', 'Gibraltar'),
	('GL', '021', 'Greenland'),
	('GM', '011', 'Gambia'),
	('GN', '011', 'Guinea'),
	('GP', '029', 'Guadeloupe'),
	('GQ', '017', 'Equatorial Guinea'),
	('GR', '039', 'Greece'),
	('GT', '013', 'Guatemala'),
	('GU', '057', 'Guam'),
	('GW', '011', 'Guinea Bissau'),
	('GY', '005', 'Guyana'),
	('HK', '030', 'Hong Kong'),
	('HN', '013', 'Honduras'),
	('HR', '039', 'Croatia'),
	('HT', '029', 'Haiti'),
	('HU', '151', 'Hungary'),
	('ID', '035', 'Indonesia'),
	('IE', '154', 'Ireland'),
	('IL', '145', 'Israel'),
	('IN', '034', 'India'),
	('IQ', '145', 'Iraq'),
	('IR', '034', 'Iran'),
	('IS', '154', 'Iceland'),
	('IT', '039', 'Italy'),
	('JM', '029', 'Jamaica'),
	('JO', '145', 'Jordan'),
	('JP', '030', 'Japan'),
	('KE', '014', 'Kenya'),
	('KG', '143', 'Kyrgyzstan'),
	('KH', '035', 'Cambodia'),
	('KI', '057', 'Kiribati'),
	('KM', '014', 'Comoros'),
	('KP', '030', 'North Korea'),
	('KR', '030', 'South Korea'),
	('KW', '145', 'Kuwait'),
	('KY', '029', 'Cayman Islands'),
	('KZ', '143', 'Kazakhstan'),
	('LA', '035', 'Laos'),
	('LB', '145', 'Lebanon'),
	('LC', '029', 'Saint Lucia'),
	('LI', '155', 'Liechtenstein'),
	('LK', '034', 'Sri Lanka'),
	('LR', '011', 'Liberia'),
	('LS', '018', 'Lesotho'),
	('LT', '154', 'Lithuania'),
	('LU', '155', 'Luxembourg'),
	('LV', '154', 'Latvia'),
	('LY', '015', 'Libya'),
	('MA', '015', 'Morocco'),
	('MC', '155', 'Monaco'),
	('MD', '151', 'Moldova'),
	('ME', '039', 'Montenegro'),
	('MG', '014', 'Madagascar'),
	('MH', '057', 'Marshall Islands'),
	('MK', '039', 'Macedonia'),
	('ML', '011', 'Mali'),
	('MM', '035', 'Myanmar'),
	('MN', '030', 'Mongolia'),
	('MO', '030', 'Macau'),
	('MQ', '029', 'Martinique'),
	('MR', '011', 'Mauritania'),
	('MS', '029', 'Montserrat'),
	('MT', '039', 'Malta'),
	('MU', '014', 'Mauritius'),
	('MV', '034', 'Maldives'),
	('MW', '014', 'Malawi'),
	('MX', '013', 'Mexico'),
	('MY', '035', 'Malaysia'),
	('MZ', '014', 'Mozambique'),
	('NA', '018', 'Namibia'),
	('NE', '011', 'Niger'),
	('NG', '011', 'Nigeria'),
	('NI', '013', 'Nicaragua'),
	('NL', '155', 'Netherlands'),
	('NO', '154', 'Norway'),
	('NP', '034', 'Nepal'),
	('NR', '057', 'Nauru'),
	('NZ', '053', 'New Zealand'),
	('OM', '145', 'Oman'),
	('PA', '013', 'Panama'),
	('PE', '005', 'Peru'),
	('PG', '054', 'Papua New Guinea'),
	('PH', '035', 'Philippines'),
	('PK', '034', 'Pakistan'),
	('PL', '151', 'Poland'),
	('PR', '029', 'Puerto Rico'),
	('PS', '145', 'Palastine (PNA)'),
	('PT', '039', 'Portugal'),
	('PW', '057', 'Palau'),
	('PY', '005', 'Paraguay'),
	('QA', '145', 'Qatar'),
	('RE', '014', 'Reunion'),
	('RO', '151', 'Romania'),
	('RS', '039', 'Serbia'),
	('RU', '151', 'Russia'),
	('RW', '014', 'Rwanda'),
	('SA', '145', 'Saudi Arabia'),
	('SB', '054', 'Solomon Islands'),
	('SC', '014', 'Seychelles'),
	('SD', '015', 'Sudan'),
	('SE', '154', 'Sweden'),
	('SG', '035', 'Singapore'),
	('SI', '039', 'Slovenia'),
	('SK', '151', 'Slovakia'),
	('SL', '011', 'Sierra Leone'),
	('SM', '039', 'San Marino'),
	('SN', '011', 'Senegal'),
	('SO', '014', 'Somalia'),
	('SR', '005', 'Suriname'),
	('SV', '013', 'El Salvador'),
	('SY', '145', 'Syria'),
	('SZ', '018', 'Swaziland'),
	('TD', '017', 'Chad'),
	('TG', '011', 'Togo'),
	('TH', '035', 'Thailand'),
	('TJ', '143', 'Tajikistan'),
	('TL', '035', 'East Timor'),
	('TM', '143', 'Turkmenistan'),
	('TN', '015', 'Tunisia'),
	('TO', '061', 'Tonga'),
	('TR', '145', 'Turkey'),
	('TT', '029', 'Trinidad and Tobago'),
	('TV', '061', 'Tuvalu'),
	('TW', '030', 'Taiwan'),
	('TZ', '014', 'Tanzania'),
	('UA', '151', 'Ukraine'),
	('UG', '014', 'Uganda'),
	('US', '021', 'USA'),
	('UY', '005', 'Uruguay'),
	('UZ', '143', 'Uzbekistan'),
	('VA', '039', 'Vatican'),
	('VC', '029', 'Saint Vincent and Grenadines'),
	('VE', '005', 'Venezuela'),
	('VN', '035', 'Vietnam'),
	('VU', '054', 'Vanuatu'),
	('WS', '061', 'Samoa'),
	('XK', '039', 'Kosovo'),
	('YT', '014', 'Mayotte'),
	('ZA', '018', 'South Africa'),
	('ZM', '014', 'Zambia'),
	('ZW', '014', 'Zimbabwe'),
	('XX', '001', 'undefined');


-- table languages -----------------------------------------------------

-- language codes according ISO 639-1

INSERT INTO languages (lng_id, lng_en, lng_nt) VALUES 
	('aa', 'Afar',           'Afaraf'),
	('ab', 'Abkhaz',         'Аҧсуа'),
	('af', 'Afrikaans',      'Afrikaans'),
	('am', 'Amharic',        'አማርኛ'),
	('ar', 'Arabic',         'العربية'),
	('as', 'Assamese',       'অসমীয়া'),
	('ay', 'Aymara',         'Aymar aru'),
	('az', 'Azerbaijani',    'Azərbaycanca'),
	('ba', 'Bashkir',        'Башҡортса'),
	('be', 'Belarusian',     'Беларуская'),
	('bg', 'Bulgarian',      'Български'),
	('bi', 'Bislama',        'Bislama'),
	('bn', 'Bengali',        'বাংলা'),
	('bo', 'Tibetan',        'བོད་ཡིག'),
	('br', 'Breton',         'Brezhoneg'),
	('bs', 'Bosnian',        'Bosanski'),
	('ca', 'Catalan',        'Català'),
	('co', 'Corsican',       'Corsu'),
	('cs', 'Czech',          'Ceština'),
	('cy', 'Welsh',          'Cymraeg'),
	('da', 'Danish',         'Dansk'),
	('de', 'German',         'Deutsch'),
	('dz', 'Dzongkha',       'རྫོང་ཁ'),
	('el', 'Greek',          'Ελληνικά'),
	('en', 'English',        'English'),
	('eo', 'Esperanto',      'Esperanto'),
	('es', 'Spanish',        'Español'),
	('et', 'Estonian',       'Eesti'),
	('eu', 'Basque',         'Euskara'),
	('fa', 'Persian',        'فارسی'),
	('fi', 'Finnish',        'Suomi'),
	('fo', 'Faroese',        'Føroyskt'),
	('fr', 'French',         'Français'),
	('fy', 'Frisian',        'Frysk'),
	('ga', 'Irish',          'Gaeilge'),
	('gd', 'Gaelic',         'Gàidhlig'),
	('gl', 'Galician',       'Galego'),
	('gn', 'Guaraní',        'Avañe''ẽ'),
	('gu', 'Gujarati',       'ગુજરાતી'),
	('ha', 'Hausa',          'هَوْسَ'),
	('he', 'Hebrew',         'עברית'),
	('hi', 'Hindi',          'हिन्दी'),
	('hr', 'Croatian',       'Hrvatski'),
	('hu', 'Hungarian',      'Magyar'),
	('hy', 'Armenian',       'Հայերեն'),
	('id', 'Indonesian',     'Bahasa Indonesia'),
	('ik', 'Inupiaq',        'Iñupiaq'),
	('is', 'Icelandic',      'Íslenska'),
	('it', 'Italian',        'Italiano'),
	('iu', 'Inuktitut',      'ᐃᓄᒃᑎᑐᑦ'),
	('ja', 'Japanese',       '日本語'),
	('jv', 'Javanese',       'Basa Jawa'),
	('ka', 'Georgian',       'ქართული'),
	('kg', 'Kongo',          'KiKongo'),
	('kk', 'Kazakh',         'қазақ тілі'),
	('kl', 'Kalaallisut',    'Kalaallisut'),
	('km', 'Khmer',          'ខ្មែរ'),
	('kn', 'Kannada',        'ಕನ್ನಡ'),
	('ko', 'Korean',         '한국어'),
	('ks', 'Kashmiri',       'कॉशुर'),
	('ku', 'Kurdish',        'Kurdî'),
	('ky', 'Kirghiz',        'Кыргызча'),
	('ln', 'Lingala',        'Lingála'),
	('lo', 'Lao',            'ພາສາລາວ'),
	('lt', 'Lithuanian',     'Lietuvių'),
	('lv', 'Latvian',        'Latviešu'),
	('mg', 'Malagasy',       'Malagasy'),
	('mi', 'Maori',          'Māori'),
	('mk', 'Macedonian',     'Македонски'),
	('ml', 'Malayalam',      'മലയാളം'),
	('mn', 'Mongolian',      'монгол'),
	('ms', 'Malay',          'Bahasa Melayu'),
	('mt', 'Maltese',        'Malti'),
	('my', 'Burmese',        'ဗမာစာ'),
	('na', 'Nauru',          'Dorerin Naoero'),
	('ne', 'Nepali',         'नेपाली'),
	('nl', 'Dutch',          'Nederlands'),
	('no', 'Norwegian',      'Norsk'),
	('oc', 'Occitan',        'occitan'),
	('om', 'Oromo',          'Afaan Oromoo'),
	('or', 'Oriya',          'ଓଡ଼ିଆ'),
	('pa', 'Panjabi',        'ਪੰਜਾਬੀ'),
	('pl', 'Polish',         'Polski'),
	('ps', 'Pashto',         'پښتو'),
	('pt', 'Portuguese',     'Português'),
	('qu', 'Quechua',        'Runa Simi'),
	('rm', 'Romansh',        'Rumantsch'),
	('rn', 'Kirundi',        'Ikirundi'),
	('ro', 'Romanian',       'Română'),
	('ru', 'Russian',        'Русский'),
	('rw', 'Kinyarwanda',    'Ikinyarwanda'),
	('sd', 'Sindhi',         'सिन्धी'),
	('sg', 'Sango',          'Sängö'),
	('si', 'Sinhala',        'සිංහල'),
	('sk', 'Slovak',         'Slovenčina'),
	('sl', 'Slovene',        'Slovenščina'),
	('sm', 'Samoan',         'Gagana Samoa'),
	('sn', 'Shona',          'chiShona'),
	('so', 'Somali',         'Soomaaliga'),
	('sq', 'Albanian',       'Shqip'),
	('sr', 'Serbian',        'Српски'),
	('ss', 'Swati',          'SiSwati'),
	('st', 'Southern Sotho', 'Sesotho'),
	('su', 'Sundanese',      'Basa Sunda'),
	('sv', 'Swedish',        'Svenska'),
	('sw', 'Swahili',        'Kiswahili'),
	('ta', 'Tamil',          'தமிழ்'),
	('te', 'Telugu',         'తెలుగు'),
	('tg', 'Tajik',          'тоҷикӣ'),
	('th', 'Thai',           'ไทย'),
	('ti', 'Tigrinya',       'ትግርኛ'),
	('tk', 'Turkmen',        'Türkmençe'),
	('tl', 'Tagalog',        'Tagalog'),
	('tn', 'Tswana',         'Setswana'),
	('to', 'Tonga',          'lea faka-Tonga'),
	('tr', 'Turkish',        'Türkçe'),
	('ts', 'Tsonga',         'Xitsonga'),
	('tt', 'Tatar',          'Татарча'),
	('tw', 'Twi',            'Twi'),
	('ug', 'Uighur, Uyghur', 'ئۇيغۇرچە'),
	('uk', 'Ukrainian',      'Українська'),
	('ur', 'Urdu',           'اردو'),
	('uz', 'Uzbek',          'O''zbek'),
	('vi', 'Vietnamese',     'Tiếng Việt'),
	('vo', 'Volapuk',        'Volapük'),
	('wo', 'Wolof',          'Wollof'),
	('xh', 'Xhosa',          'isiXhosa'),
	('yi', 'Yiddish',        'ייִדיש'),
	('yo', 'Yoruba',         'Yorùbá'),
	('za', 'Zhuang',         'Vahcuengh'),
	('zh', 'Chinese',        '中文'),
	('zu', 'Zulu',           'isiZulu'),
	('xx', 'undefined',      'undefined');

-- ***
