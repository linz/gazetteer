CREATE OR REPLACE VIEW gazetteer.name_export_for_lol AS 
SELECT 
	name_id, 
	name, 
	status, 
	feat_type, 
	CASE 
		WHEN ST_X(ref_point) < -176 -- ***-176 is east of the Chatham Islands***
			THEN ST_ASTEXT(ST_SetSRID(ST_Point(ST_X(ref_point)+200,ST_Y(ref_point)),4326))
		WHEN ST_X(ref_point) > 166 -- ***166 is west of NZ mainland***
			THEN ST_ASTEXT(ST_SetSRID(ST_Point(ST_X(ref_point)-160,ST_Y(ref_point)),4326))
	END AS ref_point
FROM name_export
	WHERE
	feat_type_code IN ('RYST','HSTE','PLAC','SITE','SBRB','TOWN','VLLG','CITY','AREA','LCLT')
	AND ST_Y(ref_point) > -53 -- ***-53 is south of Campbell Island***
	;


