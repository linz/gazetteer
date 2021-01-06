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

-- Functions to support the gazetteer application

SET search_path=gazetteer, public;

-- Add or remove a name from a list of favourites

CREATE OR REPLACE FUNCTION gapp_is_favourite( p_name_id INTEGER )
RETURNS BOOLEAN
AS
$body$
    SELECT EXISTS(SELECT * FROM app_favourites WHERE userid=current_user AND name_id=$1);
$body$
LANGUAGE sql STABLE SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION gapp_is_favourite( INTEGER ) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gapp_set_favourite( p_name_id INTEGER )
RETURNS INTEGER
AS
$body$
BEGIN
    IF NOT EXISTS (SELECT * FROM app_favourites WHERE userid=current_user AND name_id=p_name_id) THEN
       INSERT INTO app_favourites (userid, name_id) VALUES (current_user, p_name_id );
    END IF;
    RETURN NULL;
END
$body$
LANGUAGE plpgsql SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION gapp_set_favourite( INTEGER ) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gapp_clear_favourite( p_name_id INTEGER )
RETURNS INTEGER
AS
$body$
BEGIN
    DELETE FROM app_favourites WHERE userid=current_user AND name_id=$1;
    RETURN NULL;
END
$body$
LANGUAGE plpgsql SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION gapp_clear_favourite( INTEGER ) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gapp_get_favourites()
RETURNS TABLE (
    name_id INT,
    name VARCHAR,
    name_status CHAR(4),
    feat_type CHAR(4)
    )
AS
$body$
SELECT
   name.name_id,
   name.name,
   name.status,
   feature.feat_type
FROM
   name
   JOIN feature ON name.feat_id = feature.feat_id
   JOIN app_favourites fav ON fav.name_id = name.name_id
WHERE
   fav.userid = current_user AND
   name.status != 'UDEL';
$body$
LANGUAGE sql STABLE SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION gapp_get_favourites() TO gazetteer_user;


-- Record name viewed

CREATE OR REPLACE FUNCTION gapp_record_viewed( p_name_id INTEGER )
RETURNS INTEGER
AS
$body$
DECLARE
    v_usage_id INTEGER;
BEGIN
    SELECT usage_id INTO v_usage_id FROM app_usage WHERE userid=current_user AND name_id=p_name_id;
    IF v_usage_id IS NULL THEN
        INSERT INTO app_usage( userid, name_id, last_view )
        VALUES (current_user, p_name_id, current_timestamp);
    ELSE
        UPDATE app_usage SET last_view=current_timestamp WHERE usage_id=v_usage_id;
    END IF;
    RETURN NULL;
END
$body$
LANGUAGE plpgsql SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION gapp_record_viewed( INTEGER ) TO gazetteer_user;

-- Record name edited


CREATE OR REPLACE FUNCTION gapp_record_edited( p_name_id INTEGER )
RETURNS INTEGER
AS
$body$
DECLARE
    v_usage_id INTEGER;
BEGIN
    SELECT usage_id INTO v_usage_id FROM app_usage WHERE userid=current_user AND name_id=p_name_id;
    IF v_usage_id IS NULL THEN
        INSERT INTO app_usage( userid, name_id, last_view, last_edit )
        VALUES (current_user, p_name_id, current_timestamp, current_timestamp);
    ELSE
        UPDATE app_usage SET last_view=current_timestamp, last_edit=current_timestamp WHERE usage_id=v_usage_id;
    END IF;
    RETURN NULL;
END
$body$
LANGUAGE plpgsql SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION gapp_record_edited( INTEGER ) TO gazetteer_user;

--drop function gapp_get_recent_names( boolean, boolean, int );
CREATE OR REPLACE FUNCTION gapp_get_recent_names( p_all_users BOOLEAN, p_edit_only BOOLEAN, p_max INT )
RETURNS TABLE (
    name_id INT,
    name VARCHAR,
    name_status CHAR(4),
    feat_type CHAR(4),
    use_date timestamp
    )
AS
$body$
WITH rn( name_id, use_date ) AS
(
SELECT
   name.name_id,
   max(CASE WHEN $2 THEN usg.last_edit ELSE usg.last_view END) as use_date
FROM
   name
   JOIN app_usage usg ON  usg.name_id = name.name_id
WHERE
    (usg.userid = current_user OR $1) AND
    (usg.last_edit IS NOT NULL OR NOT $2)
GROUP BY
    name.name_id
ORDER BY
    use_date DESC
LIMIT
    $3
)
SELECT
   name.name_id,
   name.name,
   name.status,
   feature.feat_type,
   rn.use_date
FROM
   name
   JOIN feature ON name.feat_id = feature.feat_id
   JOIN rn ON rn.name_id = name.name_id
WHERE
   $2 OR name.status <> 'UDEL'
ORDER BY
    use_date DESC;
$body$
LANGUAGE sql STABLE SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION  gapp_get_recent_names( BOOLEAN, BOOLEAN, INT ) TO gazetteer_user;

