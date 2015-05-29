SET search_path=gazetteer, public;

DELETE FROM system_code;
INSERT INTO system_code (code_group, code, category, value ) VALUES
('CODE','CODE','SYST','Description of system code groups'),
('CODE','CATE','SYST','Definition of category codes which apply to code groups'),
('CODE','CCAT','SYST','System code group categories'),
('CCAT','SYST',NULL,'System code group - maintained by system developers'),
('CCAT','USER',NULL,'User code group - maintained by users'),
('CATE','CATE','CODE','The CATE group category code defines the category code for the corresponding system code group'),
('CATE','CODE','CCAT','System codes are categorized using the CCAT group'),
('CODE','CUSG','SYST','Code usage - defines which tables/columns codes are used in');
