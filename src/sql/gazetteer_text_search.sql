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
SET search_path=gazetteer, public;

DROP TEXT SEARCH CONFIGURATION IF EXISTS gazetteer.gaz_tsc CASCADE;
DROP TEXT SEARCH DICTIONARY IF EXISTS gazetteer.gaz_dict CASCADE;

CREATE TEXT SEARCH DICTIONARY gazetteer.gaz_dict ( TEMPLATE=pg_catalog.simple);
CREATE TEXT SEARCH CONFIGURATION gazetteer.gaz_tsc( COPY=english);
ALTER TEXT SEARCH CONFIGURATION gazetteer.gaz_tsc ALTER MAPPING FOR asciiword, asciihword, word, hword WITH gazetteer.gaz_dict;

CREATE INDEX gaz_name_ts_idx ON name USING gin(to_tsvector('gazetteer.gaz_tsc',gaz_plainText2(name::text)));
