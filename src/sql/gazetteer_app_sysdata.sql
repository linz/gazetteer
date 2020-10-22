-- ################################################################################
--
--  New Zealand Geographic Board gazetteer application,
--  Crown copyright (c) 2020, Land Information New Zealand on behalf of
--  the New Zealand Government.
--
--  This file is released under the MIT licence. See the LICENCE file found
--  in the top-level directory of this distribution for more information.
--
-- ################################################################################


SET search_path=gazetteer, public;

DELETE FROM system_code WHERE code_group='APSD';
DELETE FROM system_code WHERE code_group='CODE' AND code='APSD';

-- Order of displaying name annotations

INSERT INTO system_code (code_group, code, category, value, description ) VALUES
('CODE','APSD','USER','Application data',NULL),
('APSD','VRSN',NULL,'2.0.3-UAT','Current application version'),
('APSD','NAOR',NULL,'NPUB HORM FLRF NNOT CPAL SCID SCRB SCHT UFGT UFAC UFRG UFAD UFGP NTDC NTAR DOCC DOCR MGRS','Order in which to display name annotations'),
('APSD','FAOR',NULL,'NPUB LDIS ISLD FNOT','Order in which to display feature annotations');

-- Name event validation regular expressions for the event reference based on the event type.
-- Value is the regular expression
-- Description is the error message if not validated

DELETE FROM system_code WHERE code_group='APEV';
DELETE FROM system_code WHERE code_group='CODE' AND code='APEV';
INSERT INTO system_code (code_group, code, category, value, description ) VALUES
('CODE','APEV','USER','Event reference regular expression validators',NULL),
('APEV','NZGZ',NULL,E'^(19|20)\\d\\d\\s+\\(\\d+\\)\\s+p\\.\\d+$','Gazette references must be formatted as "1995 (94) p.213"'),
('APEV','NZGR',NULL,E'^(19|20)\\d\\d\\s+\\(\\d+\\)\\s+p\\.\\d+$','Gazette references must be formatted as "1995 (94) p.213"'),
('APEV','NZGH',NULL,E'^(19|20)\\d\\d\\s+\\(HON\\)\\s+p\\.\\d+$','Honorary board references must be formatted as "1995 (HON) p.213"'),
('APEV','NZGS',NULL,E'^(19|20)\\d\\d\\s+\\(HON\\)\\s+p\\.\\d+$','Honorary board references must be formatted as "1995 (HON) p.213"'),
('APEV','DOCG',NULL,E'^(19|20)\\d\\d\\s+\\(\\d+\\)\\s+p\\.\\d+$','DOC gazette references must be formatted as "1995 (94) p.213"'),
('APEV','TSLG',NULL,E'^Section\\s+\\d+\\s+\\S.*\\sAct\\s+(19|20)\\d\\d$','Treaty settlement references must be formatted as "Section 21 ... Act 2012"'),
('APEV','TSLR',NULL,E'^Section\\s+\\d+\\s+\\S.*\\sAct\\s+(19|20)\\d\\d$','Treaty settlement references must be formatted as "Section 21 ... Act 2012"');

-- Name annotation validation regular expressions for the annotation based
-- on the annotation type.
-- Value is the regular expression
-- Description is the error message if not validated

DELETE FROM system_code WHERE code_group='APNV';
DELETE FROM system_code WHERE code_group='CODE' AND code='APNV';
INSERT INTO system_code (code_group, code, category, value, description ) VALUES
('CODE','APNV','USER','Name annotation regular expression validators',NULL),
('APNV','MRIN',NULL,E'^(Yes|No|TBI)?$','Māori name flag must be one of "Yes", "No", "TBI"'),
('APNV','SCAR',NULL,E'^Y$','Must be Y to include in report, otherwise delete the record'),
('APNV','SCUF',NULL,E'^Y$','Must be Y to include in report, otherwise delete the record');

-- Feature annotation validation regular expressions for the annotation based
-- on the annotation type.
-- Value is the regular expression
-- Description is the error message if not validated

DELETE FROM system_code WHERE code_group='APFV';
DELETE FROM system_code WHERE code_group='CODE' AND code='APFV';
INSERT INTO system_code (code_group, code, category, value, description ) VALUES
('CODE','APFV','USER','Feature annotation regular expression validators',NULL);

-- Name event authorities - defines the valid authority codes for an event type

DELETE FROM system_code WHERE code_group='APEA';
DELETE FROM system_code WHERE code_group='CODE' AND code='APEA';
INSERT INTO system_code (code_group, code, category, value ) VALUES
('CODE','APEA','USER','Event type authorities'),
('APEA','NZGZ',NULL,'NZGB TOWS'),
('APEA','NZGR',NULL,'NZGB TOWS'),
('APEA','NZGH',NULL,'NZGH'),
('APEA','NZGS',NULL,'NZGH'),
('APEA','DOCG',NULL,'DOCG'),
('APEA','TSLG',NULL,'TOWS'),
('APEA','TSLR',NULL,'TOWS');
