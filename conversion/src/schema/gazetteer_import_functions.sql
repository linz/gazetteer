
-- Functions for the gazetteer_import schema to support 
-- the import processes.

SET SEARCH_PATH TO gazetteer_import, gazetteer, public;

-- select distinct crd_projection  from data;
-- select distinct crd_datum from data;

CREATE OR REPLACE FUNCTION latlon_angle( string VARCHAR )
RETURNS FLOAT
AS
$body$
DECLARE
   match TEXT[];
   angle FLOAT;
BEGIN
   match = regexp_matches(
      regexp_replace(string,E'[^\\x21-\\x7f]+',' ','g'), 
      E'^(\\d\\d?\\d?)(?:(?:\\xb0|\\xba|\\s)\\s*(?:(\\d\\d)\\s+)?(\\d?\\d(?:\\.\\d+)?)\\u2032?)?\\s*([NSEW])\\s*$');
   IF match IS NULL THEN RETURN NULL; END IF;
   angle = 0.0;
   IF MATCH[3] <> '' THEN
      angle = match[3]::FLOAT;
   END IF;
   IF MATCH[2] <> '' THEN
      angle = angle/60.0 + match[2]::FLOAT;
   END IF;
   angle = angle/60.0 + match[1]::FLOAT;
   IF match[4] = 'S' THEN
      angle = - angle;
   ELSIF match[4] = 'W' THEN
      angle = 360.0 - angle;
   END IF;

   RETURN angle;
END
$body$ 
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION latlon_geometry( geom_type VARCHAR, longitude VARCHAR, latitude VARCHAR )
RETURNS GEOMETRY
AS
$body$
DECLARE
   parts TEXT[];
   angle FLOAT;
   crd_lat FLOAT[];
   points GEOMETRY[];
   result GEOMETRY;
   i INTEGER;

BEGIN
    IF geom_type <> 'polygon' AND geom_type <> 'line' AND geom_type <> 'point' THEN
        RETURN NULL;
    END IF;

    parts = regexp_split_to_array(btrim(latitude,' '),E'\\s+');
    IF array_length( parts, 1 ) < 2 THEN
        RETURN NULL;
    END IF;
    crd_lat=ARRAY[]::FLOAT[];
    FOR i IN 1 .. array_length(parts,1) LOOP
        angle = latlon_angle( parts[i] );
        IF angle IS NULL THEN
            RETURN NULL;
        END IF;
        crd_lat = array_append( crd_lat, angle );
    END LOOP;

    parts = regexp_split_to_array(btrim(longitude,' '),E'\\s+');
    IF array_length(parts,1) <> array_length( crd_lat,1) THEN
        RETURN NULL;
    END IF;

    points=ARRAY[]::GEOMETRY[];
    FOR i IN 1 .. array_length(parts,1) LOOP
        angle = latlon_angle( parts[i] );
        IF angle IS NULL THEN
            RETURN NULL;
        END IF;
        points = array_append( points, ST_MakePoint(angle,crd_lat[i]) );
    END LOOP;

    IF geom_type = 'point' THEN
	IF array_length(points,1) = 1 THEN
	    result = points[1];
	ELSE
	    result = ST_Collect( points );
	END IF;
    ELSE
	    IF geom_type = 'polygon' THEN
		points = array_append( points, points[1] );
	    END IF;

	    result = ST_MakeLine( points );
	    IF geom_type = 'polygon' THEN
		result = ST_MakePolygon( result );
	    END IF;
    END IF;

    RETURN result;
END
$body$ 
LANGUAGE PLPGSQL;

-- select distinct crd_projection  from data;
-- select distinct crd_datum from data;

CREATE OR REPLACE FUNCTION make_syscode( p_string VARCHAR )
RETURNS VARCHAR(4)
AS
$body$
DECLARE
   string VARCHAR;
   string1 VARCHAR;

BEGIN
   string = initcap(gaz_plaintext(lower(p_string)));
   -- Hard coded useful fixes
   string = regexp_replace(string,E'^Railway\\s+','RY ','g');
   string = regexp_replace(string,E'^Ice\\s+','I ','g');
   
   string = regexp_replace(string,E'[^a-zA-Z]','','g');
   -- Remove vowels until a match, starting at the end ..
   WHILE length(string) > 4 LOOP
       string1 = regexp_replace(string,E'[aeiouy]([^aeiouy]*)$',E'\\1');
       EXIT WHEN string1 = string;
       string = string1;
   END LOOP;
   -- Remove duplicate letters...
   WHILE length(string) > 4 LOOP
       string1 = regexp_replace(string,E'(.)\\1',E'\\1');
       EXIT WHEN string1 = string;
       string = string1;
   END LOOP;   
   -- Remove non word starting or second letters starting at the end
   WHILE length(string) > 4 LOOP
       string1 = regexp_replace(string,E'([a-z])[a-z]((?:[^a-z][a-z]?)*)$',E'\\1\\2');
       EXIT WHEN string1 = string;
       string = string1;
   END LOOP;   
   -- Remove non word starting letters starting at the end
   WHILE length(string) > 4 LOOP
       string1 = regexp_replace(string,E'[a-z]([^a-z]*)$',E'\\1');
       EXIT WHEN string1 = string;
       string = string1;
   END LOOP;   
      
   RETURN upper(substring((string || '0000') FROM 1 FOR 4));
END
$body$ 
LANGUAGE PLPGSQL;
