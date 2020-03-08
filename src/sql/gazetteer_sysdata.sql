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

DELETE FROM system_code WHERE code_group='FSTS';
DELETE FROM system_code WHERE code_group='CODE' AND code='FSTS';
DELETE FROM system_code WHERE code_group='CUSG' AND code='FSTS';
INSERT INTO system_code (code_group, code, category, value ) VALUES
('CODE','FSTS','USER','Feature status'),
('CUSG','FSTS',NULL,'feature.status'),
('FSTS','CURR',NULL,'Current'),
('FSTS','HIST',NULL,'Historic');

DELETE FROM system_code WHERE code_group='NPRO';
DELETE FROM system_code WHERE code_group='NSTS';
DELETE FROM system_code WHERE code_group='NSTG';
DELETE FROM system_code WHERE code_group='NSTO';
DELETE FROM system_code WHERE code_group='NPST';
DELETE FROM system_code WHERE code_group='CODE' AND code IN ('NPRO','NSTS','NSTG','NSTO','NPST');
DELETE FROM system_code WHERE code_group='CATE' AND code='NSTS';
DELETE FROM system_code WHERE code_group='CUSG' AND code IN ('NSTS','NPRO');
INSERT INTO system_code (code_group, code, category, value ) VALUES
('CODE','NPRO','USER','Name process - legislation/process under which name is managed'),
('CODE','NSTS','USER','Name status - see also NSTO code group'),
('CODE','NSTO','USER','Name status order - integer values define sort order of name status'),
('CODE','NSTG','USER','Name status group categories'),
('CODE','NPST','USER','Valid status values for each process'),
('CATE','NSTS','NSTG','Name status values are categorized using the NSTG group'),
('CUSG','NPRO',NULL,'name.process'),
('CUSG','NSTS',NULL,'name.status'),
('NSTG','OFFC',NULL,'Official names'),
('NSTG','UOFC',NULL,'Published unofficial names'),
('NSTG','NPUB',NULL,'Unpublished unofficial names'),
('NSTS','UNEW','NPUB','New name'),
('NSTS','UDEL','NPUB','Deleted name')
;

DELETE FROM system_code WHERE code_group='NEVT';
DELETE FROM system_code WHERE code_group='CODE' AND code='NEVT';
DELETE FROM system_code WHERE code_group='CUSG' AND code='NEVT';
INSERT INTO system_code (code_group, code, category, value ) VALUES
('CODE','NEVT','USER','Name event'),
('CUSG','NEVT',NULL,'name_event.event_type'),
('NEVT','NZGZ',NULL,'NZGB gazettal'),
('NEVT','NZGR',NULL,'NZGB revocation'),
('NEVT','NZGH',NULL,'NZGB honorary board gazettal'),
('NEVT','NZGS',NULL,'NZGB honorary board revocation'),
('NEVT','TSLG',NULL,'Treaty settlement legislation'),
('NEVT','TSLR',NULL,'Treaty settlement legislation revocation'),
('NEVT','DOCG',NULL,'DOC gazettal'),
('NEVT','STRF',NULL,'NZ legislation'),
('NEVT','SCGZ',NULL,'SCAR gazettal'),
('NEVT','RECN',NULL,'Recorded'),
('NEVT','CLCT',NULL,'Collected');
-- ('NEVT','ADPT',NULL,'Adopted'),
-- ('NEVT','ALTR',NULL,'Altered'),
-- ('NEVT','APRV',NULL,'Approved'),
-- ('NEVT','ASGN',NULL,'Assigned'),
-- ('NEVT','CLCT',NULL,'Collected'),
-- ('NEVT','CURR',NULL,'Current'),
-- ('NEVT','DCLN',NULL,'Declined'),
-- ('NEVT','DSCN',NULL,'Discontinued'),
-- ('NEVT','HIST',NULL,'Historic'),
-- ('NEVT','OMRN',NULL,'Original Māori name'),
-- ('NEVT','PROP',NULL,'Proposed'),
-- ('NEVT','RCRD',NULL,'Recorded'),
-- ('NEVT','RPLC',NULL,'Replaced'),
-- ('NEVT','VLDT',NULL,'Validated'),
-- ('NEVT','WTHD',NULL,'Withdrawn');

DELETE FROM system_code WHERE code_group='AUTH';
DELETE FROM system_code WHERE code_group='CODE' AND code='AUTH';
DELETE FROM system_code WHERE code_group='CUSG' AND code='AUTH';
INSERT INTO system_code (code_group, code, category, value ) VALUES
('CODE','AUTH','USER','Name authority'),
('CUSG','AUTH',NULL,'name_event.authority'),
('AUTH','STAT',NULL,'Legislation'),
('AUTH','OFFD',NULL,'Official document'),
('AUTH','TOWS',NULL,'Treaty of Waitangi Settlement'),
('AUTH','TOPO',NULL,'Topographic or survey mapping'),
('AUTH','NZGB',NULL,'New Zealand Geographic Board'),
('AUTH','NZGH',NULL,'New Zealand Geographic Honorary Board'),
('AUTH','APGZ',NULL,'Antarctic provisional gazetteer'),
('AUTH','DOCG',NULL,'Department of Conservation gazetteer'),
('AUTH','APNC',NULL,'Antarctic Naming Committee'),
('AUTH','USEA',NULL,'Undersea naming authority');

DELETE FROM system_code WHERE code_group='CODE' AND code IN ('FCLS','FTYP','NANT','FANT','NAST','FAST','ASST','XNPF');
DELETE FROM system_code WHERE code_group='CATE' AND code IN ('FTYP','NAST','FAST');
DELETE FROM system_code WHERE code_group='CUSG' AND code IN ('FTYP','NANT','FANT','NAST','FAST');
DELETE FROM system_code WHERE code_group='ASST';

INSERT INTO gazetteer.system_code(code_group,code,category,value) VALUES
('CODE','FCLS','USER','Feature type classification'),
('CODE','FTYP','USER','Feature type'),
('CODE','XNPF','USER','Feature types not to be published'),
('CATE','FTYP','FCLS','Classification of feature type'),
('CUSG','FTYP',NULL,'feature.feat_type'),
('CODE','NANT','USER','Name annotation type'),
('CUSG','NANT',NULL,'name_annotation.annotation_type'),
('CODE','FANT','USER','Feature annotation type'),
('CUSG','FANT',NULL,'feature_annotation.annotation_type'),
('CODE','NAST','USER','Name association type'),
('CODE','FAST','USER','Feature association type'),
('CODE','ASST','SYST','Name association order significance'),
('CATE','FAST','ASST','Feature association order significance'),
('CATE','NAST','ASST','Name association order significance'),
('ASST','SYMM',NULL,'Association is symmetric - direction is not significant'),
('ASST','ASYM',NULL,'Association is asymmetric - direction is significant'),
('ASST','ONEW',NULL,'Association is one way - reverse association is not displayed'),
('CUSG','FAST',NULL,'feature_association.assoc_type'),
('CUSG','NAST',NULL,'name_association.assoc_type');

DELETE FROM system_code WHERE code_group='NANT';
INSERT INTO gazetteer.system_code(code_group,code,category,value) VALUES
('NANT','HORM',NULL,'History/origin/meaning'),
('NANT','FLRF',NULL,'Reference information'),
('NANT','NNOT',NULL,'Note'),
('NANT','MRIN',NULL,'Māori Name'),
('NANT','CPAL',NULL,'Crown protected area legislation'),
('NANT','SCAR',NULL,'Include in SCAR reports'),
('NANT','SCID',NULL,'SCAR id'),
('NANT','SCRB',NULL,'SCAR recorder'),
('NANT','SCHT',NULL,'SCAR height'),
('NANT','SCUF',NULL,'Include in SCUFN reports'),
('NANT','UFGT',NULL,'SCUFN geometry type'),
('NANT','UFAC',NULL,'SCUFN accuracy'),
('NANT','UFRG',NULL,'SCUFN region'),
('NANT','UFAD',NULL,'SCUFN accreditation date'),
('NANT','UFGP',NULL,'Shown on GEBCO products'),
('NANT','NTDC',NULL,'NZ topo database description code'),
('NANT','NTAR',NULL,'NZ topo accuracy rating'),
('NANT','DOCC',NULL,'DOC conservancy'),
('NANT','DOCR',NULL,'DOC conservancy unit number'),
('NANT','NPUB',NULL,'No publish reason'),
('NANT','MGRS',NULL,'Data migration source'),
('NANT','MERR',NULL,'Data migration error');

DELETE FROM system_code WHERE code_group='FANT';
INSERT INTO gazetteer.system_code(code_group,code,category,value) VALUES
('FANT','ISLD',NULL,'Island'),
('FANT','LDIS',NULL,'Land district'),
('FANT','FNOT',NULL,'Note'),
('FANT','MERR',NULL,'Data migration error'),
('FANT','NPUB',NULL,'No publish reason');

DELETE FROM system_code WHERE code_group in ('FAST','NAST');
INSERT INTO gazetteer.system_code(code_group,code,category,value) VALUES
('NAST','ASSC','SYMM','is associated with'),
('FAST','SBRB','ASYM','is a suburb of|has suburb'),
('FAST','LDIS','ONEW','is in land district');

DELETE FROM system_code WHERE code_group='SYSI';
DELETE FROM system_code WHERE code_group='CODE' AND code='SYSI';
INSERT INTO system_code (code_group, code, category, value, description ) VALUES
('CODE','SYSI','SYST','System information', NULL),
('SYSI','WEBU',NULL,'','Web database last update');
