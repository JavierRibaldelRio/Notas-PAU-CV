PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE subjects(
id INTEGER PRIMARY KEY,
code TEXT(6) NOT NULL UNIQUE,
name TEXT NOT NULL,
other_names TEXT);
INSERT INTO subjects VALUES(1,'ALEM','Alemán','ALE, ALEM');
INSERT INTO subjects VALUES(2,'ANMU','Análisis Musical','AMU, ANMU');
INSERT INTO subjects VALUES(3,'BIOL','Biología','BIO, BIOL');
INSERT INTO subjects VALUES(4,'CAST','Castellano','CAS, CAST');
INSERT INTO subjects VALUES(5,'CTM','Ciencias de la Tierra y Medio ambientales','CTM');
INSERT INTO subjects VALUES(6,'DART','Dibujo artístico','DAR, DART');
INSERT INTO subjects VALUES(7,'DISE','Diseño','DIS, DISE');
INSERT INTO subjects VALUES(8,'DITE','Dibujo Técnico','DTE, DITE');
INSERT INTO subjects VALUES(9,'ECO','Economía','ECO');
INSERT INTO subjects VALUES(10,'ELE','Electrotecnia','ELE');
INSERT INTO subjects VALUES(11,'FISI','Física','FIS, FISI');
INSERT INTO subjects VALUES(12,'FRAN','Francés','FRA, FRAN');
INSERT INTO subjects VALUES(13,'GEOG','Geografía','GEO, GEOG');
INSERT INTO subjects VALUES(14,'GRIE','Griego','GRI, GRIE');
INSERT INTO subjects VALUES(15,'HART','Historia del Arte','HAR, HART');
INSERT INTO subjects VALUES(16,'HESP','Historia de España','HES, HESP');
INSERT INTO subjects VALUES(17,'HFIL','Historia de la Filosofía','HFI, HFIL');
INSERT INTO subjects VALUES(18,'HMUS','Historia de la Música y la Danza','HMD, HMUS');
INSERT INTO subjects VALUES(19,'INGL','Inglés','ING, INGL');
INSERT INTO subjects VALUES(20,'ITAL','Italiano','ITA, ITAL');
INSERT INTO subjects VALUES(21,'LATI','Latín','LAT, LATI');
INSERT INTO subjects VALUES(22,'LIT','Literatura Universal','LIT');
INSERT INTO subjects VALUES(23,'LPM','Lenguaje y práctica musical','LPM');
INSERT INTO subjects VALUES(24,'MATE','Matemática','MAT, MATE');
INSERT INTO subjects VALUES(25,'MACS','Matemática Aplicadas a las Ciencias Social','MCS, MACS');
INSERT INTO subjects VALUES(26,'POR','Portugués','POR');
INSERT INTO subjects VALUES(27,'QUIM','Química','QUI, QUIM');
INSERT INTO subjects VALUES(28,'TEXP','Técnica de Expresión Graf-Plásticas','TEG, TEXP');
INSERT INTO subjects VALUES(29,'TIN','Tecnología','TIN');
INSERT INTO subjects VALUES(30,'VALE','Valenciano','VAL, VALE');
INSERT INTO subjects VALUES(31,'FAR','Fundamentos del Arte II/Fonaments de l''Art II','FAR');
INSERT INTO subjects VALUES(32,'ARES','Artes Escénicas','ARE, ARES');
INSERT INTO subjects VALUES(33,'CUA','Cultura audiovisual','CUA');
INSERT INTO subjects VALUES(34,'COTE','Coro y técnica vocal','COTE');
INSERT INTO subjects VALUES(35,'DTAP','Dibujo técnico aplicado a las artes plásticas y al diseño II','DTAP');
INSERT INTO subjects VALUES(36,'EMDI','Empresa y diseño de modelos de negocia','EMDI');
INSERT INTO subjects VALUES(37,'FUAR','Fundamentos Artísticos','FUAR');
INSERT INTO subjects VALUES(38,'GECA','Geologia','GEL, GECA');
INSERT INTO subjects VALUES(39,'LITE','Literatura dramática','LITE');
INSERT INTO subjects VALUES(40,'TEIN','Tecnología e ingeniería II','TEIN');
CREATE TABLE marks(
id INTEGER PRIMARY KEY,
subject_id INTEGER NOT NULL,
year INTEGER NOT NULL,
call INTEGER NOT NULL,
enrolled_total INTEGER NOT NULL,
candidates INTEGER NOT NULL,
pass INTEGER NOT NULL,
pass_percentatge REAL NOT NULL,
average REAL NOT NULL,
standard_dev REAL NOT NULL,
candidates_compulsory INTEGER NOT NULL,
pass_compulsory INTEGER NOT NULL,
candidates_optional INTEGER NOT NULL,
pass_optional INTEGER NOT NULL,
FOREIGN KEY(subject_id) REFERENCES subjects(id)
);
CREATE TABLE high_school_types(
    id INTEGER PRIMARY KEY,
    type TEXT NOT NULL UNIQUE
);
INSERT INTO high_school_types VALUES(0,'público');
INSERT INTO high_school_types VALUES(1,'privado-concertado');
INSERT INTO high_school_types VALUES(2,'privado');
CREATE TABLE provinces(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    provincial_capital INTEGER,

    FOREIGN KEY (provincial_capital) REFERENCES municipalities(id)
);
INSERT INTO provinces VALUES(1,'valencia',526);
INSERT INTO provinces VALUES(2,'castellón',177);
INSERT INTO provinces VALUES(3,'alicante',14);
CREATE TABLE high_school_marks(
    id INTEGER PRIMARY KEY,
    high_school_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    call INTEGER NOT NULL,

   
    enrolled_total INTEGER,
    candidates INTEGER,
    pass INTEGER,
    pass_percentatge REAL,
    average_bach REAL,
    standard_dev_bach REAL,


    average_compulsory_pau REAL,
    standard_dev_pau REAL,

    diference_average_bach_pau REAL,

    FOREIGN KEY (high_school_id) REFERENCES high_schools(id)

);
CREATE TABLE municipalities(
    id INTEGER PRIMARY KEY,
    ine_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL UNIQUE,
    other_names TEXT,
    region INTEGER,
    province INTEGER,

    FOREIGN KEY(region) REFERENCES regions(id),
    FOREIGN KEY(province) REFERENCES provinces(id)
);
INSERT INTO municipalities VALUES(1,'03001','atzúbia, l''','atzúbia, l''',1,3);
INSERT INTO municipalities VALUES(2,'03002','agost','agost',2,3);
INSERT INTO municipalities VALUES(3,'03003','agres','agres',3,3);
INSERT INTO municipalities VALUES(4,'03004','aigües','aigües',2,3);
INSERT INTO municipalities VALUES(5,'03005','albatera','albatera',4,3);
INSERT INTO municipalities VALUES(6,'03006','alcalalí','alcalalí',1,3);
INSERT INTO municipalities VALUES(7,'03007','alcosser','alcosser',3,3);
INSERT INTO municipalities VALUES(8,'03008','alcoleja','alcoleja',3,3);
INSERT INTO municipalities VALUES(9,'03009','alcoy','alcoi/alcoy',5,3);
INSERT INTO municipalities VALUES(10,'03010','alfafara','alfafara',3,3);
INSERT INTO municipalities VALUES(11,'03011','alfàs del pi, l''','alfàs del pi, l''',6,3);
INSERT INTO municipalities VALUES(12,'03012','algorfa','algorfa',4,3);
INSERT INTO municipalities VALUES(13,'03013','algueña','algueña',7,3);
INSERT INTO municipalities VALUES(14,'03014','alicante','alacant/alicante',2,3);
INSERT INTO municipalities VALUES(15,'03015','almoradí','almoradí',4,3);
INSERT INTO municipalities VALUES(16,'03016','almudaina','almudaina',3,3);
INSERT INTO municipalities VALUES(17,'03017','alqueria d''asnar, l''','alqueria d''asnar, l''',3,3);
INSERT INTO municipalities VALUES(18,'03018','altea','altea',6,3);
INSERT INTO municipalities VALUES(19,'03019','aspe','aspe',7,3);
INSERT INTO municipalities VALUES(20,'03020','balones','balones',3,3);
INSERT INTO municipalities VALUES(21,'03021','banyeres de mariola','banyeres de mariola',5,3);
INSERT INTO municipalities VALUES(22,'03022','benasau','benasau',3,3);
INSERT INTO municipalities VALUES(23,'03023','beneixama','beneixama',8,3);
INSERT INTO municipalities VALUES(24,'03024','benejúzar','benejúzar',4,3);
INSERT INTO municipalities VALUES(25,'03025','benferri','benferri',4,3);
INSERT INTO municipalities VALUES(26,'03026','beniarbeig','beniarbeig',1,3);
INSERT INTO municipalities VALUES(27,'03027','beniardà','beniardà',6,3);
INSERT INTO municipalities VALUES(28,'03028','beniarrés','beniarrés',3,3);
INSERT INTO municipalities VALUES(29,'03029','benigembla','benigembla',1,3);
INSERT INTO municipalities VALUES(30,'03030','benidoleig','benidoleig',1,3);
INSERT INTO municipalities VALUES(31,'03031','benidorm','benidorm',6,3);
INSERT INTO municipalities VALUES(32,'03032','benifallim','benifallim',5,3);
INSERT INTO municipalities VALUES(33,'03033','benifato','benifato',6,3);
INSERT INTO municipalities VALUES(34,'03034','benijófar','benijófar',4,3);
INSERT INTO municipalities VALUES(35,'03035','benilloba','benilloba',3,3);
INSERT INTO municipalities VALUES(36,'03036','benillup','benillup',3,3);
INSERT INTO municipalities VALUES(37,'03037','benimantell','benimantell',6,3);
INSERT INTO municipalities VALUES(38,'03038','benimarfull','benimarfull',3,3);
INSERT INTO municipalities VALUES(39,'03039','benimassot','benimassot',3,3);
INSERT INTO municipalities VALUES(40,'03040','benimeli','benimeli',1,3);
INSERT INTO municipalities VALUES(41,'03041','benissa','benissa',1,3);
INSERT INTO municipalities VALUES(42,'03042','benitachell','poble nou de benitatxell, el/benitachell',1,3);
INSERT INTO municipalities VALUES(43,'03043','biar','biar',8,3);
INSERT INTO municipalities VALUES(44,'03044','bigastro','bigastro',4,3);
INSERT INTO municipalities VALUES(45,'03045','bolulla','bolulla',6,3);
INSERT INTO municipalities VALUES(46,'03046','busot','busot',2,3);
INSERT INTO municipalities VALUES(47,'03047','calp','calp',1,3);
INSERT INTO municipalities VALUES(48,'03048','callosa d''en sarrià','callosa d''en sarrià',6,3);
INSERT INTO municipalities VALUES(49,'03049','callosa de segura','callosa de segura',4,3);
INSERT INTO municipalities VALUES(50,'03050','campello, el','campello, el',2,3);
INSERT INTO municipalities VALUES(51,'03051','campo de mirra','camp de mirra, el/campo de mirra',8,3);
INSERT INTO municipalities VALUES(52,'03052','cañada','cañada',8,3);
INSERT INTO municipalities VALUES(53,'03053','castalla','castalla',5,3);
INSERT INTO municipalities VALUES(54,'03054','castell de castells','castell de castells',1,3);
INSERT INTO municipalities VALUES(55,'03055','catral','catral',4,3);
INSERT INTO municipalities VALUES(56,'03056','cocentaina','cocentaina',3,3);
INSERT INTO municipalities VALUES(57,'03057','confrides','confrides',6,3);
INSERT INTO municipalities VALUES(58,'03058','cox','cox',4,3);
INSERT INTO municipalities VALUES(59,'03059','crevillent','crevillent',9,3);
INSERT INTO municipalities VALUES(60,'03060','quatretondeta','quatretondeta',3,3);
INSERT INTO municipalities VALUES(61,'03061','daya nueva','daya nueva',4,3);
INSERT INTO municipalities VALUES(62,'03062','daya vieja','daya vieja',4,3);
INSERT INTO municipalities VALUES(63,'03063','dénia','dénia',1,3);
INSERT INTO municipalities VALUES(64,'03064','dolores','dolores',4,3);
INSERT INTO municipalities VALUES(65,'03065','elche','elx/elche',9,3);
INSERT INTO municipalities VALUES(66,'03066','elda','elda',7,3);
INSERT INTO municipalities VALUES(67,'03067','fageca','fageca',3,3);
INSERT INTO municipalities VALUES(68,'03068','famorca','famorca',3,3);
INSERT INTO municipalities VALUES(69,'03069','finestrat','finestrat',6,3);
INSERT INTO municipalities VALUES(70,'03070','formentera del segura','formentera del segura',4,3);
INSERT INTO municipalities VALUES(71,'03071','gata de gorgos','gata de gorgos',1,3);
INSERT INTO municipalities VALUES(72,'03072','gaianes','gaianes',3,3);
INSERT INTO municipalities VALUES(73,'03073','gorga','gorga',3,3);
INSERT INTO municipalities VALUES(74,'03074','granja de rocamora','granja de rocamora',4,3);
INSERT INTO municipalities VALUES(75,'03075','castell de guadalest, el','castell de guadalest, el',6,3);
INSERT INTO municipalities VALUES(76,'03076','guardamar del segura','guardamar del segura',4,3);
INSERT INTO municipalities VALUES(77,'03077','hondón de las nieves','fondó de les neus, el/hondón de las nieves',7,3);
INSERT INTO municipalities VALUES(78,'03078','hondón de los frailes','hondón de los frailes',7,3);
INSERT INTO municipalities VALUES(79,'03079','ibi','ibi',5,3);
INSERT INTO municipalities VALUES(80,'03080','jacarilla','jacarilla',4,3);
INSERT INTO municipalities VALUES(81,'03081','xaló','xaló',1,3);
INSERT INTO municipalities VALUES(82,'03082','jávea','xàbia/jávea',1,3);
INSERT INTO municipalities VALUES(83,'03083','jijona','xixona/jijona',2,3);
INSERT INTO municipalities VALUES(84,'03084','lorcha','orxa, l''/lorcha',3,3);
INSERT INTO municipalities VALUES(85,'03085','llíber','llíber',1,3);
INSERT INTO municipalities VALUES(86,'03086','millena','millena',3,3);
INSERT INTO municipalities VALUES(87,'03088','monforte del cid','monforte del cid',7,3);
INSERT INTO municipalities VALUES(88,'03089','monóvar','monòver/monóvar',7,3);
INSERT INTO municipalities VALUES(89,'03090','mutxamel','mutxamel',2,3);
INSERT INTO municipalities VALUES(90,'03091','murla','murla',1,3);
INSERT INTO municipalities VALUES(91,'03092','muro de alcoy','muro de alcoy',3,3);
INSERT INTO municipalities VALUES(92,'03093','novelda','novelda',7,3);
INSERT INTO municipalities VALUES(93,'03094','nucia, la','nucia, la',6,3);
INSERT INTO municipalities VALUES(94,'03095','ondara','ondara',1,3);
INSERT INTO municipalities VALUES(95,'03096','onil','onil',5,3);
INSERT INTO municipalities VALUES(96,'03097','orba','orba',1,3);
INSERT INTO municipalities VALUES(97,'03098','orxeta','orxeta',6,3);
INSERT INTO municipalities VALUES(98,'03099','orihuela','orihuela',4,3);
INSERT INTO municipalities VALUES(99,'03100','parcent','parcent',1,3);
INSERT INTO municipalities VALUES(100,'03101','pedreguer','pedreguer',1,3);
INSERT INTO municipalities VALUES(101,'03102','pego','pego',1,3);
INSERT INTO municipalities VALUES(102,'03103','penàguila','penàguila',5,3);
INSERT INTO municipalities VALUES(103,'03104','petrer','petrer',7,3);
INSERT INTO municipalities VALUES(104,'03105','pinoso','pinós, el/pinoso',7,3);
INSERT INTO municipalities VALUES(105,'03106','planes','planes',3,3);
INSERT INTO municipalities VALUES(106,'03107','polop','polop',6,3);
INSERT INTO municipalities VALUES(107,'03109','rafal','rafal',4,3);
INSERT INTO municipalities VALUES(108,'03110','ràfol d''almúnia, el','ràfol d''almúnia, el',1,3);
INSERT INTO municipalities VALUES(109,'03111','redován','redován',4,3);
INSERT INTO municipalities VALUES(110,'03112','relleu','relleu',6,3);
INSERT INTO municipalities VALUES(111,'03113','rojales','rojales',4,3);
INSERT INTO municipalities VALUES(112,'03114','romana, la','romana, la',7,3);
INSERT INTO municipalities VALUES(113,'03115','sagra','sagra',1,3);
INSERT INTO municipalities VALUES(114,'03116','salinas','salinas',8,3);
INSERT INTO municipalities VALUES(115,'03117','sanet y negrals','sanet y negrals',1,3);
INSERT INTO municipalities VALUES(116,'03118','san fulgencio','san fulgencio',4,3);
INSERT INTO municipalities VALUES(117,'03119','sant joan d''alacant','sant joan d''alacant',2,3);
INSERT INTO municipalities VALUES(118,'03120','san miguel de salinas','san miguel de salinas',4,3);
INSERT INTO municipalities VALUES(119,'03121','santa pola','santa pola',9,3);
INSERT INTO municipalities VALUES(120,'03122','san vicente del raspeig','sant vicent del raspeig/san vicente del raspeig',2,3);
INSERT INTO municipalities VALUES(121,'03123','sax','sax',8,3);
INSERT INTO municipalities VALUES(122,'03124','sella','sella',6,3);
INSERT INTO municipalities VALUES(123,'03125','senija','senija',1,3);
INSERT INTO municipalities VALUES(124,'03127','tàrbena','tàrbena',6,3);
INSERT INTO municipalities VALUES(125,'03128','teulada','teulada',1,3);
INSERT INTO municipalities VALUES(126,'03129','tibi','tibi',5,3);
INSERT INTO municipalities VALUES(127,'03130','tollos','tollos',3,3);
INSERT INTO municipalities VALUES(128,'03131','tormos','tormos',1,3);
INSERT INTO municipalities VALUES(129,'03132','torremanzanas','torre de les maçanes, la/torremanzanas',2,3);
INSERT INTO municipalities VALUES(130,'03133','torrevieja','torrevieja',4,3);
INSERT INTO municipalities VALUES(131,'03134','vall d''alcalà, la','vall d''alcalà, la',1,3);
INSERT INTO municipalities VALUES(132,'03135','vall d''ebo, la','vall d''ebo, la',1,3);
INSERT INTO municipalities VALUES(133,'03136','vall de gallinera, la','vall de gallinera, la',1,3);
INSERT INTO municipalities VALUES(134,'03137','vall de laguar, la','vall de laguar, la',1,3);
INSERT INTO municipalities VALUES(135,'03138','verger, el','verger, el',1,3);
INSERT INTO municipalities VALUES(136,'03139','villajoyosa','vila joiosa, la/villajoyosa',6,3);
INSERT INTO municipalities VALUES(137,'03140','villena','villena',8,3);
INSERT INTO municipalities VALUES(138,'03901','poblets, els','poblets, els',1,3);
INSERT INTO municipalities VALUES(139,'03902','pilar de la horadada','pilar de la horadada',4,3);
INSERT INTO municipalities VALUES(140,'03903','montesinos, los','montesinos, los',4,3);
INSERT INTO municipalities VALUES(141,'03904','san isidro','san isidro',4,3);
INSERT INTO municipalities VALUES(142,'12001','atzeneta del maestrat','atzeneta del maestrat',10,2);
INSERT INTO municipalities VALUES(143,'12002','aín','aín',11,2);
INSERT INTO municipalities VALUES(144,'12003','albocàsser','albocàsser',10,2);
INSERT INTO municipalities VALUES(145,'12004','alcalà de xivert','alcalà de xivert',12,2);
INSERT INTO municipalities VALUES(146,'12005','alcora, l''','alcora, l''',13,2);
INSERT INTO municipalities VALUES(147,'12006','alcudia de veo','alcudia de veo',11,2);
INSERT INTO municipalities VALUES(148,'12007','alfondeguilla','alfondeguilla',11,2);
INSERT INTO municipalities VALUES(149,'12008','algimia de almonacid','algimia de almonacid',14,2);
INSERT INTO municipalities VALUES(150,'12009','almassora','almassora',15,2);
INSERT INTO municipalities VALUES(151,'12010','almedíjar','almedíjar',14,2);
INSERT INTO municipalities VALUES(152,'12011','almenara','almenara',11,2);
INSERT INTO municipalities VALUES(153,'12012','altura','altura',14,2);
INSERT INTO municipalities VALUES(154,'12013','arañuel','arañuel',16,2);
INSERT INTO municipalities VALUES(155,'12014','ares del maestrat','ares del maestrat',10,2);
INSERT INTO municipalities VALUES(156,'12015','argelita','argelita',16,2);
INSERT INTO municipalities VALUES(157,'12016','artana','artana',11,2);
INSERT INTO municipalities VALUES(158,'12017','ayódar','ayódar',16,2);
INSERT INTO municipalities VALUES(159,'12018','azuébar','azuébar',14,2);
INSERT INTO municipalities VALUES(160,'12020','barracas','barracas',14,2);
INSERT INTO municipalities VALUES(161,'12021','betxí','betxí',11,2);
INSERT INTO municipalities VALUES(162,'12022','bejís','bejís',14,2);
INSERT INTO municipalities VALUES(163,'12024','benafer','benafer',14,2);
INSERT INTO municipalities VALUES(164,'12025','benafigos','benafigos',10,2);
INSERT INTO municipalities VALUES(165,'12026','benassal','benassal',10,2);
INSERT INTO municipalities VALUES(166,'12027','benicarló','benicarló',12,2);
INSERT INTO municipalities VALUES(167,'12028','benicasim','benicàssim/benicasim',15,2);
INSERT INTO municipalities VALUES(168,'12029','benlloc','benlloc',15,2);
INSERT INTO municipalities VALUES(169,'12031','borriol','borriol',15,2);
INSERT INTO municipalities VALUES(170,'12032','burriana','borriana/burriana',11,2);
INSERT INTO municipalities VALUES(171,'12033','cabanes','cabanes',15,2);
INSERT INTO municipalities VALUES(172,'12034','càlig','càlig',12,2);
INSERT INTO municipalities VALUES(173,'12036','canet lo roig','canet lo roig',12,2);
INSERT INTO municipalities VALUES(174,'12037','castell de cabres','castell de cabres',12,2);
INSERT INTO municipalities VALUES(175,'12038','castellfort','castellfort',17,2);
INSERT INTO municipalities VALUES(176,'12039','castellnovo','castellnovo',14,2);
INSERT INTO municipalities VALUES(177,'12040','castelló de la plana','castelló de la plana',15,2);
INSERT INTO municipalities VALUES(178,'12041','castillo de villamalefa','castillo de villamalefa',16,2);
INSERT INTO municipalities VALUES(179,'12042','catí','catí',10,2);
INSERT INTO municipalities VALUES(180,'12043','caudiel','caudiel',14,2);
INSERT INTO municipalities VALUES(181,'12044','cervera del maestre','cervera del maestre',12,2);
INSERT INTO municipalities VALUES(182,'12045','cinctorres','cinctorres',17,2);
INSERT INTO municipalities VALUES(183,'12046','cirat','cirat',16,2);
INSERT INTO municipalities VALUES(184,'12048','cortes de arenoso','cortes de arenoso',16,2);
INSERT INTO municipalities VALUES(185,'12049','costur','costur',13,2);
INSERT INTO municipalities VALUES(186,'12050','coves de vinromà, les','coves de vinromà, les',15,2);
INSERT INTO municipalities VALUES(187,'12051','culla','culla',10,2);
INSERT INTO municipalities VALUES(188,'12052','xert','xert',12,2);
INSERT INTO municipalities VALUES(189,'12053','xilxes','chilches/xilxes',11,2);
INSERT INTO municipalities VALUES(190,'12055','chodos','xodos/chodos',13,2);
INSERT INTO municipalities VALUES(191,'12056','chóvar','chóvar',14,2);
INSERT INTO municipalities VALUES(192,'12057','eslida','eslida',11,2);
INSERT INTO municipalities VALUES(193,'12058','espadilla','espadilla',16,2);
INSERT INTO municipalities VALUES(194,'12059','fanzara','fanzara',16,2);
INSERT INTO municipalities VALUES(195,'12060','figueroles','figueroles',13,2);
INSERT INTO municipalities VALUES(196,'12061','forcall','forcall',17,2);
INSERT INTO municipalities VALUES(197,'12063','fuente la reina','fuente la reina',16,2);
INSERT INTO municipalities VALUES(198,'12064','fuentes de ayódar','fuentes de ayódar',16,2);
INSERT INTO municipalities VALUES(199,'12065','gaibiel','gaibiel',14,2);
INSERT INTO municipalities VALUES(200,'12067','geldo','geldo',14,2);
INSERT INTO municipalities VALUES(201,'12068','herbers','herbers',17,2);
INSERT INTO municipalities VALUES(202,'12069','higueras','higueras',14,2);
INSERT INTO municipalities VALUES(203,'12070','jana, la','jana, la',12,2);
INSERT INTO municipalities VALUES(204,'12071','jérica','jérica',14,2);
INSERT INTO municipalities VALUES(205,'12072','lucena del cid','llucena/lucena del cid',13,2);
INSERT INTO municipalities VALUES(206,'12073','ludiente','ludiente',16,2);
INSERT INTO municipalities VALUES(207,'12074','llosa, la','llosa, la',11,2);
INSERT INTO municipalities VALUES(208,'12075','mata de morella, la','mata de morella, la',17,2);
INSERT INTO municipalities VALUES(209,'12076','matet','matet',14,2);
INSERT INTO municipalities VALUES(210,'12077','moncofa','moncofa',11,2);
INSERT INTO municipalities VALUES(211,'12078','montán','montán',16,2);
INSERT INTO municipalities VALUES(212,'12079','montanejos','montanejos',16,2);
INSERT INTO municipalities VALUES(213,'12080','morella','morella',17,2);
INSERT INTO municipalities VALUES(214,'12081','navajas','navajas',14,2);
INSERT INTO municipalities VALUES(215,'12082','nules','nules',11,2);
INSERT INTO municipalities VALUES(216,'12083','olocau del rey','olocau del rey',17,2);
INSERT INTO municipalities VALUES(217,'12084','onda','onda',11,2);
INSERT INTO municipalities VALUES(218,'12085','oropesa del mar','orpesa/oropesa del mar',15,2);
INSERT INTO municipalities VALUES(219,'12087','palanques','palanques',17,2);
INSERT INTO municipalities VALUES(220,'12088','pavías','pavías',14,2);
INSERT INTO municipalities VALUES(221,'12089','peñíscola','peníscola/peñíscola',12,2);
INSERT INTO municipalities VALUES(222,'12090','pina de montalgrao','pina de montalgrao',14,2);
INSERT INTO municipalities VALUES(223,'12091','portell de morella','portell de morella',17,2);
INSERT INTO municipalities VALUES(224,'12092','puebla de arenoso','puebla de arenoso',16,2);
INSERT INTO municipalities VALUES(225,'12093','pobla de benifassà, la','pobla de benifassà, la',12,2);
INSERT INTO municipalities VALUES(226,'12094','pobla tornesa, la','pobla tornesa, la',15,2);
INSERT INTO municipalities VALUES(227,'12095','ribesalbes','ribesalbes',11,2);
INSERT INTO municipalities VALUES(228,'12096','rossell','rossell',12,2);
INSERT INTO municipalities VALUES(229,'12097','sacañet','sacañet',14,2);
INSERT INTO municipalities VALUES(230,'12098','salzadella, la','salzadella, la',12,2);
INSERT INTO municipalities VALUES(231,'12099','san jorge','sant jordi/san jorge',12,2);
INSERT INTO municipalities VALUES(232,'12100','sant mateu','sant mateu',12,2);
INSERT INTO municipalities VALUES(233,'12101','san rafael del río','san rafael del río',12,2);
INSERT INTO municipalities VALUES(234,'12102','santa magdalena de pulpis','santa magdalena de pulpis',12,2);
INSERT INTO municipalities VALUES(235,'12103','serratella, la','serratella, la',10,2);
INSERT INTO municipalities VALUES(236,'12104','segorbe','segorbe',14,2);
INSERT INTO municipalities VALUES(237,'12105','sierra engarcerán','sierra engarcerán',15,2);
INSERT INTO municipalities VALUES(238,'12106','soneja','soneja',14,2);
INSERT INTO municipalities VALUES(239,'12107','sot de ferrer','sot de ferrer',14,2);
INSERT INTO municipalities VALUES(240,'12108','sueras','suera/sueras',11,2);
INSERT INTO municipalities VALUES(241,'12109','tales','tales',11,2);
INSERT INTO municipalities VALUES(242,'12110','teresa','teresa',14,2);
INSERT INTO municipalities VALUES(243,'12111','tírig','tírig',10,2);
INSERT INTO municipalities VALUES(244,'12112','todolella','todolella',17,2);
INSERT INTO municipalities VALUES(245,'12113','toga','toga',16,2);
INSERT INTO municipalities VALUES(246,'12114','torás','torás',14,2);
INSERT INTO municipalities VALUES(247,'12115','toro, el','toro, el',14,2);
INSERT INTO municipalities VALUES(248,'12116','torralba del pinar','torralba del pinar',16,2);
INSERT INTO municipalities VALUES(249,'12117','torreblanca','torreblanca',15,2);
INSERT INTO municipalities VALUES(250,'12118','torrechiva','torrechiva',16,2);
INSERT INTO municipalities VALUES(251,'12119','torre d''en besora, la','torre d''en besora, la',10,2);
INSERT INTO municipalities VALUES(252,'12120','torre d''en doménec, la','torre d''en doménec, la',15,2);
INSERT INTO municipalities VALUES(253,'12121','traiguera','traiguera',12,2);
INSERT INTO municipalities VALUES(254,'12122','useras','useres, les/useras',13,2);
INSERT INTO municipalities VALUES(255,'12123','vallat','vallat',16,2);
INSERT INTO municipalities VALUES(256,'12124','vall d''alba','vall d''alba',15,2);
INSERT INTO municipalities VALUES(257,'12125','vall de almonacid','vall de almonacid',14,2);
INSERT INTO municipalities VALUES(258,'12126','vall d''uixó, la','vall d''uixó, la',11,2);
INSERT INTO municipalities VALUES(259,'12127','vallibona','vallibona',17,2);
INSERT INTO municipalities VALUES(260,'12128','vilafamés','vilafamés',15,2);
INSERT INTO municipalities VALUES(261,'12129','villafranca del cid','vilafranca/villafranca del cid',17,2);
INSERT INTO municipalities VALUES(262,'12130','villahermosa del río','villahermosa del río',16,2);
INSERT INTO municipalities VALUES(263,'12131','villamalur','villamalur',16,2);
INSERT INTO municipalities VALUES(264,'12132','vilanova d''alcolea','vilanova d''alcolea',15,2);
INSERT INTO municipalities VALUES(265,'12133','villanueva de viver','villanueva de viver',16,2);
INSERT INTO municipalities VALUES(266,'12134','vilar de canes','vilar de canes',10,2);
INSERT INTO municipalities VALUES(267,'12135','vila-real','vila-real',11,2);
INSERT INTO municipalities VALUES(268,'12136','vilavella, la','vilavella, la',11,2);
INSERT INTO municipalities VALUES(269,'12137','villores','villores',17,2);
INSERT INTO municipalities VALUES(270,'12138','vinaròs','vinaròs',12,2);
INSERT INTO municipalities VALUES(271,'12139','vistabella del maestrat','vistabella del maestrat',10,2);
INSERT INTO municipalities VALUES(272,'12140','viver','viver',14,2);
INSERT INTO municipalities VALUES(273,'12141','zorita del maestrazgo','zorita del maestrazgo',17,2);
INSERT INTO municipalities VALUES(274,'12142','zucaina','zucaina',16,2);
INSERT INTO municipalities VALUES(275,'12901','alquerías del niño perdido','alqueries, les/alquerías del niño perdido',11,2);
INSERT INTO municipalities VALUES(276,'12902','sant joan de moró','sant joan de moró',15,2);
INSERT INTO municipalities VALUES(277,'46001','ademuz','ademuz',18,1);
INSERT INTO municipalities VALUES(278,'46002','ador','ador',19,1);
INSERT INTO municipalities VALUES(279,'46003','atzeneta d''albaida','atzeneta d''albaida',20,1);
INSERT INTO municipalities VALUES(280,'46004','agullent','agullent',20,1);
INSERT INTO municipalities VALUES(281,'46005','alaquàs','alaquàs',21,1);
INSERT INTO municipalities VALUES(282,'46006','albaida','albaida',20,1);
INSERT INTO municipalities VALUES(283,'46007','albal','albal',21,1);
INSERT INTO municipalities VALUES(284,'46008','albalat de la ribera','albalat de la ribera',22,1);
INSERT INTO municipalities VALUES(285,'46009','albalat dels sorells','albalat dels sorells',23,1);
INSERT INTO municipalities VALUES(286,'46010','albalat dels tarongers','albalat dels tarongers',24,1);
INSERT INTO municipalities VALUES(287,'46011','alberic','alberic',25,1);
INSERT INTO municipalities VALUES(288,'46012','alborache','alborache',26,1);
INSERT INTO municipalities VALUES(289,'46013','alboraya','alboraia/alboraya',23,1);
INSERT INTO municipalities VALUES(290,'46014','albuixech','albuixech',23,1);
INSERT INTO municipalities VALUES(291,'46015','alcàsser','alcàsser',21,1);
INSERT INTO municipalities VALUES(292,'46016','alcàntera de xúquer','alcàntera de xúquer',25,1);
INSERT INTO municipalities VALUES(293,'46017','alzira','alzira',25,1);
INSERT INTO municipalities VALUES(294,'46018','alcublas','alcublas',27,1);
INSERT INTO municipalities VALUES(295,'46019','alcúdia, l''','alcúdia, l''',25,1);
INSERT INTO municipalities VALUES(296,'46020','alcúdia de crespins, l''','alcúdia de crespins, l''',28,1);
INSERT INTO municipalities VALUES(297,'46021','aldaia','aldaia',21,1);
INSERT INTO municipalities VALUES(298,'46022','alfafar','alfafar',21,1);
INSERT INTO municipalities VALUES(299,'46023','alfauir','alfauir',19,1);
INSERT INTO municipalities VALUES(300,'46024','alfara de la baronia','alfara de la baronia',24,1);
INSERT INTO municipalities VALUES(301,'46025','alfara del patriarca','alfara del patriarca',23,1);
INSERT INTO municipalities VALUES(302,'46026','alfarb','alfarb',25,1);
INSERT INTO municipalities VALUES(303,'46027','alfarrasí','alfarrasí',20,1);
INSERT INTO municipalities VALUES(304,'46028','algar de palància','algar de palància',24,1);
INSERT INTO municipalities VALUES(305,'46029','algemesí','algemesí',25,1);
INSERT INTO municipalities VALUES(306,'46030','algímia d''alfara','algímia d''alfara',24,1);
INSERT INTO municipalities VALUES(307,'46031','alginet','alginet',25,1);
INSERT INTO municipalities VALUES(308,'46032','almàssera','almàssera',23,1);
INSERT INTO municipalities VALUES(309,'46033','almiserà','almiserà',19,1);
INSERT INTO municipalities VALUES(310,'46034','almoines','almoines',19,1);
INSERT INTO municipalities VALUES(311,'46035','almussafes','almussafes',22,1);
INSERT INTO municipalities VALUES(312,'46036','alpuente','alpuente',27,1);
INSERT INTO municipalities VALUES(313,'46037','alqueria de la comtessa, l''','alqueria de la comtessa, l''',19,1);
INSERT INTO municipalities VALUES(314,'46038','andilla','andilla',27,1);
INSERT INTO municipalities VALUES(315,'46039','anna','anna',29,1);
INSERT INTO municipalities VALUES(316,'46040','antella','antella',25,1);
INSERT INTO municipalities VALUES(317,'46041','aras de los olmos','aras de los olmos',27,1);
INSERT INTO municipalities VALUES(318,'46042','aielo de malferit','aielo de malferit',20,1);
INSERT INTO municipalities VALUES(319,'46043','aielo de rugat','aielo de rugat',20,1);
INSERT INTO municipalities VALUES(320,'46044','ayora','ayora',30,1);
INSERT INTO municipalities VALUES(321,'46045','barxeta','barxeta',28,1);
INSERT INTO municipalities VALUES(322,'46046','barx','barx',19,1);
INSERT INTO municipalities VALUES(323,'46047','bèlgida','bèlgida',20,1);
INSERT INTO municipalities VALUES(324,'46048','bellreguard','bellreguard',19,1);
INSERT INTO municipalities VALUES(325,'46049','bellús','bellús',20,1);
INSERT INTO municipalities VALUES(326,'46050','benagéber','benagéber',27,1);
INSERT INTO municipalities VALUES(327,'46051','benaguasil','benaguasil',31,1);
INSERT INTO municipalities VALUES(328,'46052','benavites','benavites',24,1);
INSERT INTO municipalities VALUES(329,'46053','beneixida','beneixida',25,1);
INSERT INTO municipalities VALUES(330,'46054','benetússer','benetússer',21,1);
INSERT INTO municipalities VALUES(331,'46055','beniarjó','beniarjó',19,1);
INSERT INTO municipalities VALUES(332,'46056','beniatjar','beniatjar',20,1);
INSERT INTO municipalities VALUES(333,'46057','benicolet','benicolet',20,1);
INSERT INTO municipalities VALUES(334,'46058','benifairó de les valls','benifairó de les valls',24,1);
INSERT INTO municipalities VALUES(335,'46059','benifairó de la valldigna','benifairó de la valldigna',19,1);
INSERT INTO municipalities VALUES(336,'46060','benifaió','benifaió',25,1);
INSERT INTO municipalities VALUES(337,'46061','beniflá','beniflá',19,1);
INSERT INTO municipalities VALUES(338,'46062','benigànim','benigànim',20,1);
INSERT INTO municipalities VALUES(339,'46063','benimodo','benimodo',25,1);
INSERT INTO municipalities VALUES(340,'46064','benimuslem','benimuslem',25,1);
INSERT INTO municipalities VALUES(341,'46065','beniparrell','beniparrell',21,1);
INSERT INTO municipalities VALUES(342,'46066','benirredrà','benirredrà',19,1);
INSERT INTO municipalities VALUES(343,'46067','benissanó','benissanó',31,1);
INSERT INTO municipalities VALUES(344,'46068','benissoda','benissoda',20,1);
INSERT INTO municipalities VALUES(345,'46069','benissuera','benissuera',20,1);
INSERT INTO municipalities VALUES(346,'46070','bétera','bétera',31,1);
INSERT INTO municipalities VALUES(347,'46071','bicorp','bicorp',29,1);
INSERT INTO municipalities VALUES(348,'46072','bocairent','bocairent',20,1);
INSERT INTO municipalities VALUES(349,'46073','bolbaite','bolbaite',29,1);
INSERT INTO municipalities VALUES(350,'46074','bonrepòs i mirambell','bonrepòs i mirambell',23,1);
INSERT INTO municipalities VALUES(351,'46075','bufali','bufali',20,1);
INSERT INTO municipalities VALUES(352,'46076','bugarra','bugarra',27,1);
INSERT INTO municipalities VALUES(353,'46077','buñol','buñol',26,1);
INSERT INTO municipalities VALUES(354,'46078','burjassot','burjassot',23,1);
INSERT INTO municipalities VALUES(355,'46079','calles','calles',27,1);
INSERT INTO municipalities VALUES(356,'46080','camporrobles','camporrobles',32,1);
INSERT INTO municipalities VALUES(357,'46081','canals','canals',28,1);
INSERT INTO municipalities VALUES(358,'46082','canet d''en berenguer','canet d''en berenguer',24,1);
INSERT INTO municipalities VALUES(359,'46083','carcaixent','carcaixent',25,1);
INSERT INTO municipalities VALUES(360,'46084','càrcer','càrcer',25,1);
INSERT INTO municipalities VALUES(361,'46085','carlet','carlet',25,1);
INSERT INTO municipalities VALUES(362,'46086','carrícola','carrícola',20,1);
INSERT INTO municipalities VALUES(363,'46087','casas altas','casas altas',18,1);
INSERT INTO municipalities VALUES(364,'46088','casas bajas','casas bajas',18,1);
INSERT INTO municipalities VALUES(365,'46089','casinos','casinos',31,1);
INSERT INTO municipalities VALUES(366,'46090','castelló de rugat','castelló de rugat',20,1);
INSERT INTO municipalities VALUES(367,'46091','castellonet de la conquesta','castellonet de la conquesta',19,1);
INSERT INTO municipalities VALUES(368,'46092','castielfabib','castielfabib',18,1);
INSERT INTO municipalities VALUES(369,'46093','catadau','catadau',25,1);
INSERT INTO municipalities VALUES(370,'46094','catarroja','catarroja',21,1);
INSERT INTO municipalities VALUES(371,'46095','caudete de las fuentes','caudete de las fuentes',32,1);
INSERT INTO municipalities VALUES(372,'46096','cerdà','cerdà',28,1);
INSERT INTO municipalities VALUES(373,'46097','cofrentes','cofrentes',30,1);
INSERT INTO municipalities VALUES(374,'46098','corbera','corbera',22,1);
INSERT INTO municipalities VALUES(375,'46099','cortes de pallás','cortes de pallás',30,1);
INSERT INTO municipalities VALUES(376,'46100','cotes','cotes',25,1);
INSERT INTO municipalities VALUES(377,'46101','quart de les valls','quart de les valls',24,1);
INSERT INTO municipalities VALUES(378,'46102','quart de poblet','quart de poblet',21,1);
INSERT INTO municipalities VALUES(379,'46103','quartell','quartell',24,1);
INSERT INTO municipalities VALUES(380,'46104','quatretonda','quatretonda',20,1);
INSERT INTO municipalities VALUES(381,'46105','cullera','cullera',22,1);
INSERT INTO municipalities VALUES(382,'46106','chelva','chelva',27,1);
INSERT INTO municipalities VALUES(383,'46107','chella','chella',29,1);
INSERT INTO municipalities VALUES(384,'46108','chera','chera',32,1);
INSERT INTO municipalities VALUES(385,'46109','cheste','cheste',26,1);
INSERT INTO municipalities VALUES(386,'46110','xirivella','xirivella',21,1);
INSERT INTO municipalities VALUES(387,'46111','chiva','chiva',26,1);
INSERT INTO municipalities VALUES(388,'46112','chulilla','chulilla',27,1);
INSERT INTO municipalities VALUES(389,'46113','daimús','daimús',19,1);
INSERT INTO municipalities VALUES(390,'46114','domeño','domeño',27,1);
INSERT INTO municipalities VALUES(391,'46115','dos aguas','dos aguas',26,1);
INSERT INTO municipalities VALUES(392,'46116','eliana, l''','eliana, l''',31,1);
INSERT INTO municipalities VALUES(393,'46117','emperador','emperador',23,1);
INSERT INTO municipalities VALUES(394,'46118','enguera','enguera',29,1);
INSERT INTO municipalities VALUES(395,'46119','énova, l''','énova, l''',25,1);
INSERT INTO municipalities VALUES(396,'46120','estivella','estivella',24,1);
INSERT INTO municipalities VALUES(397,'46121','estubeny','estubeny',28,1);
INSERT INTO municipalities VALUES(398,'46122','faura','faura',24,1);
INSERT INTO municipalities VALUES(399,'46123','favara','favara',22,1);
INSERT INTO municipalities VALUES(400,'46124','fontanars dels alforins','fontanars dels alforins',20,1);
INSERT INTO municipalities VALUES(401,'46125','fortaleny','fortaleny',22,1);
INSERT INTO municipalities VALUES(402,'46126','foios','foios',23,1);
INSERT INTO municipalities VALUES(403,'46127','font d''en carròs, la','font d''en carròs, la',19,1);
INSERT INTO municipalities VALUES(404,'46128','font de la figuera, la','font de la figuera, la',28,1);
INSERT INTO municipalities VALUES(405,'46129','fuenterrobles','fuenterrobles',32,1);
INSERT INTO municipalities VALUES(406,'46130','gavarda','gavarda',25,1);
INSERT INTO municipalities VALUES(407,'46131','gandia','gandia',19,1);
INSERT INTO municipalities VALUES(408,'46132','genovés, el','genovés, el',28,1);
INSERT INTO municipalities VALUES(409,'46133','gestalgar','gestalgar',27,1);
INSERT INTO municipalities VALUES(410,'46134','gilet','gilet',24,1);
INSERT INTO municipalities VALUES(411,'46135','godella','godella',23,1);
INSERT INTO municipalities VALUES(412,'46136','godelleta','godelleta',26,1);
INSERT INTO municipalities VALUES(413,'46137','granja de la costera, la','granja de la costera, la',28,1);
INSERT INTO municipalities VALUES(414,'46138','guadasséquies','guadasséquies',20,1);
INSERT INTO municipalities VALUES(415,'46139','guadassuar','guadassuar',25,1);
INSERT INTO municipalities VALUES(416,'46140','guardamar de la safor','guardamar de la safor',19,1);
INSERT INTO municipalities VALUES(417,'46141','higueruelas','higueruelas',27,1);
INSERT INTO municipalities VALUES(418,'46142','jalance','jalance',30,1);
INSERT INTO municipalities VALUES(419,'46143','xeraco','xeraco',19,1);
INSERT INTO municipalities VALUES(420,'46144','jarafuel','jarafuel',30,1);
INSERT INTO municipalities VALUES(421,'46145','xàtiva','xàtiva',28,1);
INSERT INTO municipalities VALUES(422,'46146','xeresa','xeresa',19,1);
INSERT INTO municipalities VALUES(423,'46147','llíria','llíria',31,1);
INSERT INTO municipalities VALUES(424,'46148','loriguilla','loriguilla',31,1);
INSERT INTO municipalities VALUES(425,'46149','losa del obispo','losa del obispo',27,1);
INSERT INTO municipalities VALUES(426,'46150','llutxent','llutxent',20,1);
INSERT INTO municipalities VALUES(427,'46151','llocnou d''en fenollet','llocnou d''en fenollet',28,1);
INSERT INTO municipalities VALUES(428,'46152','llocnou de la corona','llocnou de la corona',21,1);
INSERT INTO municipalities VALUES(429,'46153','llocnou de sant jeroni','llocnou de sant jeroni',19,1);
INSERT INTO municipalities VALUES(430,'46154','llanera de ranes','llanera de ranes',28,1);
INSERT INTO municipalities VALUES(431,'46155','llaurí','llaurí',22,1);
INSERT INTO municipalities VALUES(432,'46156','llombai','llombai',25,1);
INSERT INTO municipalities VALUES(433,'46157','llosa de ranes, la','llosa de ranes, la',28,1);
INSERT INTO municipalities VALUES(434,'46158','macastre','macastre',26,1);
INSERT INTO municipalities VALUES(435,'46159','manises','manises',21,1);
INSERT INTO municipalities VALUES(436,'46160','manuel','manuel',25,1);
INSERT INTO municipalities VALUES(437,'46161','marines','marines',31,1);
INSERT INTO municipalities VALUES(438,'46162','massalavés','massalavés',25,1);
INSERT INTO municipalities VALUES(439,'46163','massalfassar','massalfassar',23,1);
INSERT INTO municipalities VALUES(440,'46164','massamagrell','massamagrell',23,1);
INSERT INTO municipalities VALUES(441,'46165','massanassa','massanassa',21,1);
INSERT INTO municipalities VALUES(442,'46166','meliana','meliana',23,1);
INSERT INTO municipalities VALUES(443,'46167','millares','millares',29,1);
INSERT INTO municipalities VALUES(444,'46168','miramar','miramar',19,1);
INSERT INTO municipalities VALUES(445,'46169','mislata','mislata',21,1);
INSERT INTO municipalities VALUES(446,'46170','mogente','moixent/mogente',28,1);
INSERT INTO municipalities VALUES(447,'46171','moncada','moncada',23,1);
INSERT INTO municipalities VALUES(448,'46172','montserrat','montserrat',25,1);
INSERT INTO municipalities VALUES(449,'46173','montaverner','montaverner',20,1);
INSERT INTO municipalities VALUES(450,'46174','montesa','montesa',28,1);
INSERT INTO municipalities VALUES(451,'46175','montichelvo','montitxelvo/montichelvo',20,1);
INSERT INTO municipalities VALUES(452,'46176','montroy','montroi/montroy',25,1);
INSERT INTO municipalities VALUES(453,'46177','museros','museros',23,1);
INSERT INTO municipalities VALUES(454,'46178','nàquera','nàquera/náquera',31,1);
INSERT INTO municipalities VALUES(455,'46179','navarrés','navarrés',29,1);
INSERT INTO municipalities VALUES(456,'46180','novetlè','novetlè',28,1);
INSERT INTO municipalities VALUES(457,'46181','oliva','oliva',19,1);
INSERT INTO municipalities VALUES(458,'46182','olocau','olocau',31,1);
INSERT INTO municipalities VALUES(459,'46183','olleria, l''','olleria, l''',20,1);
INSERT INTO municipalities VALUES(460,'46184','ontinyent','ontinyent',20,1);
INSERT INTO municipalities VALUES(461,'46185','otos','otos',20,1);
INSERT INTO municipalities VALUES(462,'46186','paiporta','paiporta',21,1);
INSERT INTO municipalities VALUES(463,'46187','palma de gandía','palma de gandía',19,1);
INSERT INTO municipalities VALUES(464,'46188','palmera','palmera',19,1);
INSERT INTO municipalities VALUES(465,'46189','palomar, el','palomar, el',20,1);
INSERT INTO municipalities VALUES(466,'46190','paterna','paterna',23,1);
INSERT INTO municipalities VALUES(467,'46191','pedralba','pedralba',27,1);
INSERT INTO municipalities VALUES(468,'46192','petrés','petrés',24,1);
INSERT INTO municipalities VALUES(469,'46193','picanya','picanya',21,1);
INSERT INTO municipalities VALUES(470,'46194','picassent','picassent',21,1);
INSERT INTO municipalities VALUES(471,'46195','piles','piles',19,1);
INSERT INTO municipalities VALUES(472,'46196','pinet','pinet',20,1);
INSERT INTO municipalities VALUES(473,'46197','polinyà de xúquer','polinyà de xúquer',22,1);
INSERT INTO municipalities VALUES(474,'46198','potries','potries',19,1);
INSERT INTO municipalities VALUES(475,'46199','pobla de farnals, la','pobla de farnals, la',23,1);
INSERT INTO municipalities VALUES(476,'46200','pobla del duc, la','pobla del duc, la',20,1);
INSERT INTO municipalities VALUES(477,'46201','puebla de san miguel','puebla de san miguel',18,1);
INSERT INTO municipalities VALUES(478,'46202','pobla de vallbona, la','pobla de vallbona, la',31,1);
INSERT INTO municipalities VALUES(479,'46203','pobla llarga, la','pobla llarga, la',25,1);
INSERT INTO municipalities VALUES(480,'46204','puig de santa maria, el','puig de santa maria, el',23,1);
INSERT INTO municipalities VALUES(481,'46205','puçol','puçol',23,1);
INSERT INTO municipalities VALUES(482,'46206','quesa','quesa',29,1);
INSERT INTO municipalities VALUES(483,'46207','rafelbunyol','rafelbunyol',23,1);
INSERT INTO municipalities VALUES(484,'46208','rafelcofer','rafelcofer',19,1);
INSERT INTO municipalities VALUES(485,'46209','rafelguaraf','rafelguaraf',25,1);
INSERT INTO municipalities VALUES(486,'46210','ráfol de salem','ráfol de salem',20,1);
INSERT INTO municipalities VALUES(487,'46211','real de gandia, el','real de gandia, el',19,1);
INSERT INTO municipalities VALUES(488,'46212','real','real',25,1);
INSERT INTO municipalities VALUES(489,'46213','requena','requena',32,1);
INSERT INTO municipalities VALUES(490,'46214','riba-roja de túria','riba-roja de túria',31,1);
INSERT INTO municipalities VALUES(491,'46215','riola','riola',22,1);
INSERT INTO municipalities VALUES(492,'46216','rocafort','rocafort',23,1);
INSERT INTO municipalities VALUES(493,'46217','rotglà i corberà','rotglà i corberà',28,1);
INSERT INTO municipalities VALUES(494,'46218','ròtova','ròtova',19,1);
INSERT INTO municipalities VALUES(495,'46219','rugat','rugat',20,1);
INSERT INTO municipalities VALUES(496,'46220','sagunto','sagunt/sagunto',24,1);
INSERT INTO municipalities VALUES(497,'46221','salem','salem',20,1);
INSERT INTO municipalities VALUES(498,'46222','sant joanet','sant joanet',25,1);
INSERT INTO municipalities VALUES(499,'46223','sedaví','sedaví',21,1);
INSERT INTO municipalities VALUES(500,'46224','segart','segart',24,1);
INSERT INTO municipalities VALUES(501,'46225','sellent','sellent',25,1);
INSERT INTO municipalities VALUES(502,'46226','sempere','sempere',20,1);
INSERT INTO municipalities VALUES(503,'46227','senyera','senyera',25,1);
INSERT INTO municipalities VALUES(504,'46228','serra','serra',31,1);
INSERT INTO municipalities VALUES(505,'46229','siete aguas','siete aguas',26,1);
INSERT INTO municipalities VALUES(506,'46230','silla','silla',21,1);
INSERT INTO municipalities VALUES(507,'46231','simat de la valldigna','simat de la valldigna',19,1);
INSERT INTO municipalities VALUES(508,'46232','sinarcas','sinarcas',32,1);
INSERT INTO municipalities VALUES(509,'46233','sollana','sollana',22,1);
INSERT INTO municipalities VALUES(510,'46234','sot de chera','sot de chera',27,1);
INSERT INTO municipalities VALUES(511,'46235','sueca','sueca',22,1);
INSERT INTO municipalities VALUES(512,'46236','sumacàrcer','sumacàrcer',25,1);
INSERT INTO municipalities VALUES(513,'46237','tavernes blanques','tavernes blanques',23,1);
INSERT INTO municipalities VALUES(514,'46238','tavernes de la valldigna','tavernes de la valldigna',19,1);
INSERT INTO municipalities VALUES(515,'46239','teresa de cofrentes','teresa de cofrentes',30,1);
INSERT INTO municipalities VALUES(516,'46240','terrateig','terrateig',20,1);
INSERT INTO municipalities VALUES(517,'46241','titaguas','titaguas',27,1);
INSERT INTO municipalities VALUES(518,'46242','torrebaja','torrebaja',18,1);
INSERT INTO municipalities VALUES(519,'46243','torrella','torrella',28,1);
INSERT INTO municipalities VALUES(520,'46244','torrent','torrent',21,1);
INSERT INTO municipalities VALUES(521,'46245','torres torres','torres torres',24,1);
INSERT INTO municipalities VALUES(522,'46246','tous','tous',25,1);
INSERT INTO municipalities VALUES(523,'46247','tuéjar','tuéjar',27,1);
INSERT INTO municipalities VALUES(524,'46248','turís','turís',25,1);
INSERT INTO municipalities VALUES(525,'46249','utiel','utiel',32,1);
INSERT INTO municipalities VALUES(526,'46250','valència','valència',33,1);
INSERT INTO municipalities VALUES(527,'46251','vallada','vallada',28,1);
INSERT INTO municipalities VALUES(528,'46252','vallanca','vallanca',18,1);
INSERT INTO municipalities VALUES(529,'46253','vallés','vallés',28,1);
INSERT INTO municipalities VALUES(530,'46254','venta del moro','venta del moro',32,1);
INSERT INTO municipalities VALUES(531,'46255','villalonga','vilallonga/villalonga',19,1);
INSERT INTO municipalities VALUES(532,'46256','vilamarxant','vilamarxant',31,1);
INSERT INTO municipalities VALUES(533,'46257','castelló','castelló',25,1);
INSERT INTO municipalities VALUES(534,'46258','villar del arzobispo','villar del arzobispo',27,1);
INSERT INTO municipalities VALUES(535,'46259','villargordo del cabriel','villargordo del cabriel',32,1);
INSERT INTO municipalities VALUES(536,'46260','vinalesa','vinalesa',23,1);
INSERT INTO municipalities VALUES(537,'46261','yátova','yátova',26,1);
INSERT INTO municipalities VALUES(538,'46262','yesa, la','yesa, la',27,1);
INSERT INTO municipalities VALUES(539,'46263','zarra','zarra',30,1);
INSERT INTO municipalities VALUES(540,'46902','gátova','gátova',31,1);
INSERT INTO municipalities VALUES(541,'46903','san antonio de benagéber','san antonio de benagéber',31,1);
INSERT INTO municipalities VALUES(542,'46904','benicull de xúquer','benicull de xúquer',22,1);
CREATE TABLE regions(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    province INTEGER,

    FOREIGN KEY (province) REFERENCES provinces(id)

);
INSERT INTO regions VALUES(1,'la marina alta',3);
INSERT INTO regions VALUES(2,'l''alacantí',3);
INSERT INTO regions VALUES(3,'el comtat',3);
INSERT INTO regions VALUES(4,'la vega baja',3);
INSERT INTO regions VALUES(5,'l''alcoià',3);
INSERT INTO regions VALUES(6,'la marina baixa',3);
INSERT INTO regions VALUES(7,'el vinalopó medio',3);
INSERT INTO regions VALUES(8,'alto vinalopó',3);
INSERT INTO regions VALUES(9,'el baix vinalopó',3);
INSERT INTO regions VALUES(10,'l''alt maestrat',2);
INSERT INTO regions VALUES(11,'la plana baixa',2);
INSERT INTO regions VALUES(12,'el baix maestrat',2);
INSERT INTO regions VALUES(13,'l''alcalatén',2);
INSERT INTO regions VALUES(14,'el alto palancia',2);
INSERT INTO regions VALUES(15,'la plana alta',2);
INSERT INTO regions VALUES(16,'el alto mijares',2);
INSERT INTO regions VALUES(17,'els ports',2);
INSERT INTO regions VALUES(18,'el rincón de ademuz',1);
INSERT INTO regions VALUES(19,'la safor',1);
INSERT INTO regions VALUES(20,'la vall d''albaida',1);
INSERT INTO regions VALUES(21,'l''horta sud',1);
INSERT INTO regions VALUES(22,'la ribera baixa',1);
INSERT INTO regions VALUES(23,'l''horta nord',1);
INSERT INTO regions VALUES(24,'el camp de morvedre',1);
INSERT INTO regions VALUES(25,'la ribera alta',1);
INSERT INTO regions VALUES(26,'la hoya de buñol',1);
INSERT INTO regions VALUES(27,'los serranos',1);
INSERT INTO regions VALUES(28,'la costera',1);
INSERT INTO regions VALUES(29,'la canal de navarrés',1);
INSERT INTO regions VALUES(30,'el valle de cofrentes-ayora',1);
INSERT INTO regions VALUES(31,'el camp de túria',1);
INSERT INTO regions VALUES(32,'la plana de utiel-requena',1);
INSERT INTO regions VALUES(33,'valència',1);
CREATE TABLE high_schools(

    id INTEGER PRIMARY KEY,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    type_id INTEGER,
    cif TEXT,
    
    address TEXT,
    postal_code TEXT,
    municipality_id INTEGER NOT NULL,
    latitude REAL,
    longitude REAL,


    
    email TEXT,
    phone_number TEXT,
    fax TEXT,

    website TEXT,
    
    owner TEXT,

    image BLOB,

    FOREIGN KEY (type_id) REFERENCES high_school_types(id),
    FOREIGN KEY (municipality_id) REFERENCES municipalities(id)

);
COMMIT;
