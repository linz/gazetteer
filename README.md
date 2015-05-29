Gazetteer
=========

The main components of the applications are

- The postgres database hosting the data and providing functions for searching. Also stores some application data, such as field validation regular expressions, lists of users favourite names, etc

- The python interface to the database, which uses the sqlalchemy ORM (object relational mapping) for the main entities in the data (names, features, annotations, system codes). The objects are built using database reflection. The database interface is set up by Database.py, and the model components in Model.py

- The python Qt4 application, which has as its main components an AdminWidget, for administering the database, a search component (NameSearchWidget), and a name viewer/editor NameWebView. The application uses the Controller.py module for most communications between components. This is also used by the Quantum GIS plugin to interface with the application. Note that several gui modules can be used as standalone applications, for example Editor.py and AdminWidget.py.

- The names web view uses an HTML representation of the data to display name information, coupled with a javascript functions to manage the user interaction with the data (such as switching to edit mode, saving edits, and so on). The javascript interfaces with the NameWebView python code using JSON formatted data - as such it could readily be migrated to a true web client with a Python backend. The HTML is generated using a public domain templating engine - pyratemp. The template is help in the template directory (name_template.html). The javascript is in the html/js directory (name.js, name_validator.js). It uses the jquery API (1.7.2), also in that directory.

The javascript interface
------------------------

The javascript communicates with the Python using JSON. All objects and object attributes are given a unique id, which is managed by some mapping functions in the Model.py module. The interface is by a qcontroller object inserted into the javascript window object by the Qt WebView API.

The javascript interfaces with the web page principally using HTML object classes to identify objecs and elements. The classes used by the javascript are:

- edit-value, within a visible edit-update item. Identifies a potentially updatable item by the id attribute. Each element is tested with an initial value held in an map (gazetteer.editdata) to see whether it has actually changed.
- edit-delete-item: an item to be deleted. The entity has an attribute id identifying the object to be deleted.
- edit-new-item: a new item to be edited. The item is type is defined by an object_type custom attribute of the entity. Within the item are a number of edit-value fields defining the attributes of the object. The name attribute of the edit-value entity is used as the attribute name.
- cancel-edit-link: Links created by page set up used to cancel editing specific items. The are all automatically clicked when the cancel button is pressed
- can-delete: Identifies divs representing objects that can be deleted.
- edit-restore: div created (and hidden) on page load which can be used to restore a deleted item (until it is saved). This is inserted after the can-delete div.

The editing links are set up when the page is loaded, but are hidden. Blocks of class.edit-update are set up for editing as follows:

- The initial value of edit-value item is saved in the gazetteer.editdata map
- The data change event is linked to the checkDirty page handler, which sets the Save button state
- Validators for the block are initiallized
- The links for editing and cancelling editing the block are created, if they do not already exist (if they exist the must have an id matching the block id with "_edit_link" or "_unedit_link" appended. These are inserted after and at the end of the block, respectively. They are given class enable-edit and cancel-edit-link.
- Each div with editable-item and can-delete classes is given a delete and undelete link. The delete item has class
- Each item with edit-new-template is set up to allow creating new items using it as a template. When the create new link is clicked the template is cloned.
- An item with id #favourite is used to locate a favourite toggle for the name.
- Each select with a .viewed-name-lookup is initiallized with a list of names currently viewed in the application. (This is for linking associated names)
- Each span.author is hidden - it will be shown in edit mode
- Each a.name_link element is set up to call a javascript function to send the name id back to the python module for displaying. 

Field validation is via the name_validator.js code, which has a map of validators indexed on the object type and attribute name as "validate_type[_attribute]". When field validation is set up the code looks for an enclosing div with an object_type attribute to determine the object type.

Validators are set up on edit blocks (typically defining an object). The setupValidators function creates div with class errors for the block to hold the validator output for each validator registered in the block, which inserts a p.validator-error item into the errors div.

Database configuration
----------------------

The application configures the database using the DatabaseConfiguration.py module to set up the host, database, and user credentials. This module must be imported in python modules before any modules using the database (this can be done by importing the Controller.py module). The configuration module can also be run in standalone mode to configure the database connection (for example to connect to a development server).

By default the configuration points to the gazetteer database on the *production* server, logging in using the current user (getpass.getuser()). You can check the configuration in Quantum GIS from the menu at the Plugins | Gazetteer editor | About gazetteer application.

User roles and security
-----------------------

There are a number of postgres database roles used to control access to the database. These are:

<style type="text/css">
    table { border-spacing: 2px; padding: 5px }
    tr { vertical-align:top }
</style>
<table>
    <tr>
        <td>gazetteer_user</td>
        <td>Read only access to the database - no one has this role as 
        anyone looking at it is also authorised to edit it</td>
    </tr>
    <tr>
        <td>gazetteer_admin</td>
        <td>Able to update data in the database</td>
    </tr>
    <tr>
        <td>gazetteer_dba</td>
        <td>Has database administration privileges (access to the admin tool,
        updating users, system data, and publishing the data.</td>
    </tr>
    <tr>
        <td>gazetteer_export</td>
        <td>Holds the
            exports of the current published state of the database.
            Read only access to tables in the gazetteer_export schema
            is used for automatic uploading data to LDS, accessing the
            CSV file export from the web, and for reporting against
            the published data.
        </td>
    </tr>
    <tr>
        <td>gaz_web_reader</td>
        <td>Read only access to the gazetteer_web schema (used by the web
        application)</td>
    </tr>
    <tr>
        <td>gaz_web_admin</td>
        <td>Read write access to the gazetteer_web schema (used to publish the data to the web database)</td>
    </tr>
    <tr>
        <td>gaz_web_developer</td>
        <td>Full access to the gazetteer_web schema.</td>
    </tr>
</table>

Schema
------

The gazetteer is divided into the following schema:

<table>
    <tr>
        <td>gazetteer</td>
        <td>The main database and admin application tables.  These are maintained
        by NZGB staff, and updated using the QGIS plugin.</td>
    </tr>
    <tr>
        <td>gazetteer_history</td>
        <td>Retains historical records of the data.  This is maintained by insert/update/delete
            triggers on the gazetteer schema tables.  Note that all updates to the database 
            include the user id and update date. Any data being changed is copied to the history 
            tables before being overwritten/deleted.
        </td>
    </tr>
    <tr>
        <td>gazetteer_web</td>
        <td>The tables accessed by the web application.  These are periodically updated by
            NZGB stuff using the publish data function in the administration tool.
        </td>
    </tr>
    <tr>
        <td>gazetteer_export</td>
        <td>
            Contains tables for updating published data in LDS and in CSV files on the LINZ
            website.  These are also updated by the publish data function.  LDS will automatically 
            update to reflect changes to these tables (within 24 hours?).  The CSV data must be 
            downloaded by NZGB staff and passed to the Comms team for uploading. <br />
            _NOTE:_ This process could be replaced with a simple PHP script to access the 
            create a CSV file on the fly.
        </td>
    </tr>
</table>

Data is published from the NZGB admin database to two datasets, which are in the gazetteer_web and gazetteer_export schema.

The gazetteer_web schema contains tables used by the online gazetteer application. The data is generated by database stored procedures, and is updated by calling gweb_update_web_database() procedure. Any changes to the process will require modifying these procedures. The update is effective immediately the data is regenerated.

The LDS and CSV file exports are generated in the gazetteer_export database by the gaz_update_export_databae() procedure. This is based on the name_export view and the gazetteer_export_tables view. The name_export view defines the data that is available to be exported, and the gazetteer_export_tables view defines the data sets that will be generated by selecting columns and rows from the name_export view. When the data is published each data set populates a table in the gazetteer_export schema. (Note that the output column names in the gazetteer_export_tables view are prefixed by 5 characters which sorted to define the order of the columns).

The gazetteer_export_tables view is based (somewhat messily) on system codes in the following code groups:

<table>
    <tr>
        <td>XCOL</td>
        <td>Defines columns that may be exported.  Each column has a code, which defines the order
            in which it is included in the export table, and a category, which is used to select it 
            into a data set.  Each data set defines a set of categories it will export, which implies 
            a set of columns.
        </td>
    </tr>
    <tr>
        <td>XCRT</td>
        <td>Criteria to select rows from the table.  Each criteria has a value which is an SQL condition on the columns of the name_export view.
            In the same way as XCOL, the criteria has a category that is used to select it into a dataset.
        </td>
    </tr>
    <tr>
        <td>XDST</td>
        <td>A set of destinations, currently just includes LDSD (LDS) and CSVF (CSV file).</td>
    </tr>
    <tr>
        <td>XCAT</td>
        <td>The set of categories that may be used in XCOL or XCRT</td>
    </tr>
    <tr>
        <td>XDSN</td>
        <td>Defines an export data set.  The category defines the destination.  The value defines 
            the name of the table
        </td>
    </tr>
    <tr>
        <td>XDSC</td>
        <td>Defines the categories of XCOL and XCRT that apply to the data set.  The code matches
            one of the XDSN codes, and the value is a space separated list of categories.  XDSN
            codes which are not matched will by default get all categories referenced in the XCOL
            codes.
        </td>
    </tr>
</table>
        
QGIS plugin installation
------------------------

The QGIS plugin is packaged as a zip file NZGBplugin.zip, containing the entire plugin directory (named NZGBplugin) from the source code. This is installed to the LINZ QGIS plugin repository. Before uploading a new version the version number in Plugin.py should be updated. Once the file is upload the plugins.xml file in the repository needs to be updated to reflect the new version number.

Also the plugin version system code in the database needs to be updated so that users of an old version are warned they should upgrade. (code_group='APSD', code='VRSN').

Source code location and organisation
-------------------------------------

The source code is held in a git repository. Within this the main components are the database components in src/sql, and the plugin code at src/plugin.

The database components include sql scripts to build and update the database, and bash shell scripts to run them. There are two shell scripts, install.sh for the main (admin) database, and install_web.sh for the web database components. They take command line options that are passed to the postgres command line utilities (-h for host, -d for database, -U for userid), and an optional argument "drop". If the drop argument is specified, then the entire schema is dropped and reinstalled. This will lose all data that was in the database!!!