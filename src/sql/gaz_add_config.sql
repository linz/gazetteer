--------------------------------------------------------
-- Add a complete set of Configuration items to the gaz_web_config table
--------------------------------------------------------

set search_path=gazetteer_web, public;


-- Delete existing configuration items
DELETE FROM gaz_web_config;


----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('FMFM',
            NULL,
	    E'Only matching names in the area of the map are shown below - to see all matching names {0}zoom out.{1}',
            E'Text indicating that the map bounds does not show all Features');

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('FTRM',
            NULL,
	    E'The map does not display undersea names and Antarctic names',
            E'Permanent text to display beneath the map');

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('MXMS',
            NULL,
	    E'Your search has exceeded {0} records of a total {1}. Please refine your search to reduce the record size.',
            E'Text to display when maximum exceeded (html)');

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('MXSR',
            50,
            NULL,
           E'Value representing maximmum results to return from a Feature Search');

-----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('HOWT',
            NULL,
            E'<table style="margin: 0"><tr>
                               <td class="headerText" width="100%">About</td>
                               <td class="headerText" style="text-align:right; text-align-last: right; text-decoration: underline;" onclick="document.getElementById(\'tid\').scrollTop = document.getElementById(\'Glossary\').offsetTop-40">Glossary</td></tr>
                       </table>
                   

                   <h4>Search by Name</h4>
		           Enter a name in the AutoComplete assisted textbox to the left,
                   and press Enter.
                   Any relevant results will be shown in the <em>Matches Found</em>
                   panel that will become visible. 

                   <h4>Search by Location</h4>
		           Drag the map to the approximate location of choice, and zoom to see more detail.
                   As Points of interest become visible in the map, the <em>Results Found</em> panel
                   will be updated with information for those points.

                   <h4>More Detail</h4>
                   Click any visible point of interest for more details.
                   <h4 id="Glossary" style="color: blue;font-style: italic; text-align: left;">Glossary</h4>
                   <em>Official Name</em> The name of a geographic feature deemed as such by the NZGB.
                   <p><em>Geographic Feature</em> A physical or cultural object to which a name can be given. The jurisdiction of the NZGB is restricted to:</p>
                   <ul>
                   <li>natural features(such as a mountain, peak, valley, glen, forest, lagoon, swamp, creek, stream, river, ford, lake, glacier or ice feature, bay, island
                   or harbour [including man-made features of the same type])</li>    
                   <li>railways or railway stations, but not railway features(such as marshalling yards, transfer sites or track point locations)</li>
                   <li>places</li>
                   <li>undersea features.</li>
                   </ul>
                   <p><em>Place</em> A city, town, village, site, area, locality, suburb or similar place. It excludes CPAs, and districts, regions and wards of local authorities.</p>
                   <p><em>Statutory Reference</em> The Act of Parliament under which:</p>
                   <ul>
                   <li>A Treaty name became official (pre NZGBA)</li>
                   <li>The Deed of Settlement listing a treaty name to be enacted</li>
                   <li>A CPA is held</li>
                   <li>An official name is discontinued (if not by determination of the NZGB)</li>
                   </ul>                      
		',
	    E'Content of How to Use Panel');
		
----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('MZSA',
            7,
            NULL,
           E'The minimum zoom level that is required for the system to allow a blank search term to be searched for (excluding the default extent/zoom level).');		
		   
----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('MZMG',
            NULL,
	    E'No matches have been found but you can either enter search text or zoom in on the area of interest to find names.',
            E'The message that will be displayed when 0 matches have been found and the current zoom level is less than the minimum zoom level (MZSA) and the search textbox is blank');		   

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('MFNM',
            NULL,
           E'<span style=''font-size: 0.75em;margin:0px;''>* Feature not within the bounds of the map.</span>',
           E'Message displayed on the summaries view when a feature is not within the bounds of the map');


-----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('MAPC',
            NULL,
            E' mapDiv: "map",
    proxyHost: "/cgi-bin/LdsWfsProxy.cgi?url=",
    mapProjection: "EPSG:3857",
    displayProjection: "EPSG:4326",
    backgroundColor: "#D0E6F4",
    basemapUrl: "http://topobasemap.koordinates.co.nz/v2/gazetteer_basemap/${z}/${x}/${y}.png", 
    labelWfsUrl: "http://wfs.data.linz.govt.nz/3e78150f9b2645228602e113fbc2a586/v/x1154/wfs",
    labelWfsFeatureNS: "http://data.linz.govt.nz/ns/v",
    labelWfsFeatureType: "x1154",
    
    mapCentre: [173,-41],
    mapRestrictedExtent: [[165.5,-48],[179.5,-33.5]],
    mapMinZoom: 5,
    mapMaxZoom: 14,

    basemapOptions: 
    {
        // attribution: "Tiles &copy; LINZ",
        sphericalMercator: true,
        wrapDateLine: false,
        transitionEffect: "resize",
        buffer: 1,
        numZoomLevels: 15
    },

    labelBaseStyle:
    {
        label : "${label}",
        fontColor: "black",
        fontSize: "12px",
        fontFamily: "Arial, helvetica, sans",
        fontWeight: "normal",
        labelOutlineColor: "white",
        labelOutlineWidth: 1
    },

    labelStyleLookup: 
    {
        TWN1: {fontSize: "12px"},
        TWN2: {fontSize: "14px"},
        TWN3: {fontSize: "16px"},
        HYD1: {fontColor: "blue", fontSize: "12px"},
        HYD2: {fontColor: "blue", fontSize: "14px"},
        HYD3: {fontColor: "blue", fontSize: "16px"}
    }
		',
	    E'Configuration of the Base Map');

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('SRDS',
            4167,
            NULL,
           E'The source SRID.');		

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('SRDT',
            3785,
            NULL,
           E'The target SRID.');	

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('TTNV',
            NULL,
           E'Click the top ''hand'' button to pan when dragging the mouse over the map.\n\nClick the bottom ''magnifying glass'' to zoom the map by drawing a rectangle on the area to be zoomed.',
           E'The navtoolbar tooltip title, ie the hand/spatial zoom + sybol at the bottom left corner');	

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('TTPZ',
            NULL,
           E'To pan the map in the north, east, south, west directions, use the corresponding arrows at the top left.\n\nTo zoom the map to the desired scale, click the ''-'', ''+'' or anywhere in between to change the zoom level.',
           E'The panzoombar tooltip title, ie the top two pan and zoom controls');	

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('TTZM',
            NULL,
           E'Zoom to the maximum extent.',
           E'The zoomtomaxextent tooltip title, ie the world control');	

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('TTHP',
            NULL,
           E'Go to previous map position.',
           E'The NavigationHistory previous tooltip title');	

----------------------------------------------------------
INSERT INTO gaz_web_config(
            code, intval, value, description)
    VALUES ('TTHN',
            NULL,
           E'Go to next map position.',
           E'The NavigationHistory next tooltip title');	

