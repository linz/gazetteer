-- Reference data used by the gazetteer import process

set search_path=gazetteer_import, gazetteer, public;
set search_path=gazetteer_import, gazetteer, public;

-- Table defining mapping of coord sys codes to EPSG code

drop table if exists crdsys_srid;
create table crdsys_srid( cscode varchar(20) not null primary key, srid int not null, isproj bool, minlat float, minlon float, maxlat float, maxlon float, extents geometry );
insert into crdsys_srid values
    ('NZGD2000',4167,'f',-48.0,163.0,-30.0,190.0,NULL),
    ('NZGD2001',4167,'f',-48.0,163.0,-30.0,190.0,NULL),
    ('RSRGD2000',4764,'f',-90.0,100.0,-60.0,280.0,NULL),
    ('NZTM',2193,'t',-48.0,165.0,-33.0,180.0,NULL),
    ('AKTM2000',3788,'t',-51.1,165.2,-47.5,167.0,NULL),
    ('NZTM2001',2193,'t',-48.0,165.0,-33.0,180.0,NULL),
    ('RITM2000',3791,'t',-30.7,179.7,-28.1,185,NULL),
    ('AITM2000',3790,'t',-50.2,177.45,-47.1,180.1,NULL),
    ('CATM2000',3789,'t',-52.7,168.8,-52.4,169.5,NULL),
    ('CITM2000',3793,'t',-44.6,182.7,-43.5,184.5,NULL),
    ('NZTM2000',2193,'t',-48.0,165.0,-33.0,180.0,NULL)
    ;

update crdsys_srid set extents = ST_Transform(St_SetSrid(St_MakeBox2d(ST_Point(minlon,minlat), ST_Point(maxlon,maxlat)),4167),srid);

--

drop table if exists cpa_type;
create table cpa_type( id serial, cpa_type varchar(50), description varchar(100));
insert into cpa_type (cpa_type, description ) values
    ('amenity area','a conservation area held under s 23(a) of the Conservation Act 1987'),
    ('conservation park','a conservation area held under s 19 of the Conservation Act 1987'),
    ('ecological area','a conservation area held under s 21 of the Conservation Act 1987'),
    ('sanctuary area','a conservation area held under s 22 of the Conservation Act 1987'),
    ('wilderness area','a conservation area held under s 20 of the Conservation Act 1987'),
    ('wildlife management area','a conservation area held under s 23(b) of the Conservation Act 1987'),
    ('national park','a conservation area held under s 4 of the National Parks Act 1980'),
    ('marine reserve','a reserve area held under s 4 of the Marine Reserves Act 1971'),
    ('historic reserve','a reserve area held under s 18 of the Reserves Act 1977'),
    ('nature reserve','a reserve area held under s 20 of the Reserves Act 1977'),
    ('recreation reserve','a reserve area held under s 17 of the Reserves Act 1977'),
    ('scientific reserve','a reserve area held under s 21 of the Reserves Act 1977'),
    ('scenic reserve','a reserve area held under s 19 of the Reserves Act 1977'),
    ('Government purpose reserve','a reserve area held under s 22 of the Reserves Act 1977');



drop table if exists undersea_type;
create table undersea_type( id serial, undersea_type varchar(50), description varchar(512));
insert into undersea_type ( undersea_type, description ) values

    ('Abyssal Hill','an isolated (or tract of) small elevation(s) on the deep seafloor'),
    ('Abyssal Plain','an extensive, flat, gently sloping, or nearly level region at abyssal depths'),
    ('Apron','a gently dipping surface, underlain primarily by sediment, at the base of any steeper slope'),
    ('Archipelagic Apron','a gentle slope with a generally smooth surface of the sea floor, characteristically found around groups of islands or seamounts'),
    ('Bank','an isolated (or group of) elevation(s) of the sea floor, over which the depth of water is relatively shallow, but sufficient for safe surface navigation'),
    ('Basin','a depression, in the sea floor, more or less equidimensional in plan and of variable extent'),
    ('Bench','a small terrace'),
    ('Borderland','a region adjacent to a continent, normally occupied by or bordering a shelf and sometimes emerging as islands, that is irregular or blocky in plan or profile, with depths well in excess of those typical of a shelf'),
    ('Caldera','a collapsed or partially-collapsed seamount, commonly of annular shape'),
    ('Canyon','an isolated (or group of) relatively narrow, deep depression(s) with steep sides, the bottom of which generally deepens continuously, developed characteristically on some continental slopes'),
    ('Cone','see fan'),
    ('Continental Margin','the zone, generally consisting of shelf, slope and continental rise, separating the continent from the deep sea floor or abyssal plain.  Occasionally a trench may be present in place of a continental rise'),
    ('Continental Rise','a gentle slope rising from the oceanic depths towards the foot of a continental slope'),
    ('Continental Shelf','see shelf'),
    ('Cordillera','an entire mountain system including the subordinate ranges, interior plateaus, and basins'),
    ('Deep','an isolated (or group of) localised deep area(s) within the confines of a larger feature, such as a trough, basin or trench'),
    ('Escarpment','an elongated, characteristically linear, steep slope separating horizontal or gently sloping sectors of the sea floor in non-shelf areas.  Also abbreviated to scarp'),
    ('Fan','a relatively smooth, fan-like, depositional feature normally sloping away from the outer termination of a canyon or canyon system.  Also called a cone'),
    ('Flat','a small level or nearly level area'),
    ('Fork','a branch(es) of a canyon(s) or valley(s)'),
    ('Fracture Zone','an extensive linear zone of irregular topography, mountainous or faulted, characterised by steep-sided or assymetrical ridges, clefts, troughs or escarpments'),
    ('Furrow','a closed, linear, narrow, shallow depression'),
    ('Gap','see passage'),
    ('Gully','a small valley-like feature'),
    ('Guyot','an isolated (or group of) seamount(s) having a comparatively smooth flat top.  Also called tablemount(s).  See also seamount(s)'),
    ('Hill','an isolated (or group of) elevation(s), smaller than a seamount.  See also abyssal hill(s) and knoll(s)'),
    ('Hole','a small local depression, often steep sided, in the sea floor'),
    ('Knoll','an elevation somewhat smaller than a seamount and of rounded profile, characteristically isolated or as a cluster on the sea floor. See also hill(s)'),
    ('Ledge','a rocky projection or outcrop, commonly linear and near shore'),
    ('Levee','a depositional natural embankment bordering a canyon, valley or seachannel on the ocean floor'),
    ('Median Valley','the axial depression of the mid-oceanic ridge system'),
    ('Mid-Oceanic Ridge','see ridge (c) and rise (b)'),
    ('Mesa','an isolated, extensive, flat-topped elevation on the shelf, with relatively steep sides'),
    ('Moat','an annular depression that may not be continuous located at the base of many seamounts, oceanic islands and other isolated elevations'),
    ('Mound','a low, isolated, rounded hill'),
    ('Mountain','a well-defined subdivision(s) of a large and complex positive feature(s)'),
    ('Passage','a narrow break in a ridge or a rise.  Also called gap'),
    ('Peak','an isolated (or group of) prominent elevation(s) either pointed or of a very limited extent across the summit'),
    ('Pinnacle','a discrete (or group of) high tower or spire-shaped pillar(s) of rock, or coral, isolated or cresting a summit'),
    ('Plain','a flat, gently sloping or nearly level region'),
    ('Plateau','a flat or nearly flat elevation of considerable areal extent, dropping off abruptly on one or more sides'),
    ('Platform','a flat or gently sloping underwater surface extending seaward from shore'),
    ('Promontory','a major spur-like protrusion of the continental slope extending to the deep seafloor.  Characteristically, the crest deepens seaward'),
    ('Province','a region identifiable by a number of shared physiographic characteristics that are markedly in contrast with those in the surrounding areas'),
    ('Ramp','a gentle slope connecting areas of different elevations'),
    ('Range','a series of associated ridges or seamounts'),
    ('Ravine','a small canyon'),
    ('Reef','a mass (or group) or rock(s) or other indurated material lying at or near the sea surface that may constitute a hazard to surface navigation'),
    ('Ridge','(a) an isolated (or group of) elongated narrow elevation(s) of varying complexity having steep sides'
      || E'\n' || '(b) an isolated (or group of) elongated narrow elevation(s), often separating ocean basins'
      || E'\n' || '(c) the linked major mid-oceanic mountain systems of global extent.  Also called mid-oceanic ridge'),
    ('Rise','(a) a broad elevation that rises gently and smoothly from the sea floor'
      || E'\n' || '(b) the linked major mid-oceanic mountain systems of global extent.  Also called mid-oceanic ridge'),
    ('Saddle','a broad pass or col, resembling in shape a riding saddle, in a ridge or between contiguous elevations'),
    ('Scarp','see escarpment'),
    ('Sea Valley','see valley(s)'),
    ('Seachannel','a continuously sloping elongated discrete (or group of) depression(s) found in fans or abyssal plains and customarily bordered by levees on one or both sides'),
    ('Seamount','a discrete (or group of) large isolated elevation(s), greater than 1,000m in relief above the sea floor, characteristically of conical form.  See also guyot'),
    ('Seamount Chain','a linear or arcuate alignment of discrete seamounts, with their bases clearly separated.  See also seamount(s)'),
    ('Shelf','a zone adjacent to a continent (or around an island) and extending from the low water line to a depth at which there is usually a marked increase of slope towards oceanic depths'),
    ('Shelf-Break','see shelf-edge'),
    ('Shelf-Edge','the line along which there is a marked increase of slope at the seaward margin of a continental (or island) shelf.  Also called shelf break'),
    ('Shelf-Valley','a valley on the shelf, generally the shoreward extension of a canyon'),
    ('Shoal','an isolated (or group of) offshore hazard(s) to surface navigation with substantially less clearance than the surrounding area and composed of unconsolidated material'),
    ('Sill','a sea floor barrier of relatively shallow depth restricting water movement between basins'),
    ('Slope','the deepening sea floor out from the shelf-edge to the upper limit of the continental rise, or to the point where there is a general decrease in steepness'),
    ('Spur','a subordinate elevation or ridge protruding from a larger feature, such as a plateau or island foundation'),
    ('Submarine Valley','see valley(s)'),
    ('Tablemount','see guyot(s)'),
    ('Terrace','an isolated (or group of) relatively flat horizontal or gently inclined surface(s), sometimes long and narrow, which is(are) bounded by a steeper descending slope on the opposite side.'),
    ('Tongue','an elongate (tongue-like) extension of a flat sea floor into an adjacent higher feature'),
    ('Trench','a long narrow, characteristically very deep and asymmetrical depression of the sea floor, with relatively steep sides'),
    ('Trough','a long depression of the sea floor characteristically flat bottomed and steep sided and normally shallower than a trench'),
    ('Valley','an isolated (or group of) relatively shallow, wide depression(s), the bottom of which usually has a continuous gradient.  This term is generally not used for features that have canyon-like characteristics for a significant portion of their extent.  Also called submarine valley(s) or sea valley(s)');


-- Create mapping of source and status to name status/event

DROP TABLE IF EXISTS status_mapping;
CREATE table status_mapping
(
    src CHAR(4),
    status VARCHAR(50),
    name_process CHAR(4),
    name_status CHAR(4),
    PRIMARY KEY (src, status)
);

GRANT SELECT, INSERT, UPDATE, DELETE ON status_mapping TO gazetteer_admin;
