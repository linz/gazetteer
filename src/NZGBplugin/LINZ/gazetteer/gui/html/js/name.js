
var gazetteer = gazetteer || {};

function autoGrow (oField) {
  if (oField.scrollHeight > oField.clientHeight) {
    oField.style.height = oField.scrollHeight + "px";
  }
}

gazetteer.isDirty = function()
{
    if( $('.edit-delete-item').length ) return true;
    if( $('.edit-new-item').length) return true;
    var dirty=false;
    $('.edit-update:visible .edit-value').each( function()
    {
        var el = $(this);
        if( el.val() != gazetteer.editdata[el.attr('id')] )
        {
            dirty=true;
            return false;
        }
    });

    return dirty;
}

gazetteer.isValid = function()
{
    return $('.validator-error:visible').length == 0;
}

gazetteer.checkDirty = function()
{
    var dirty = gazetteer.isDirty();
    if( window.qcontroller )
    {
        window.qcontroller.setDirty( dirty );
    }
    if( gazetteer.saveButton )
    {
        var saveable= dirty && gazetteer.isValid();
        gazetteer.saveButton.attr("disabled", ! saveable );
    }
}

gazetteer.startEdit = function()
{
    $('span.author').show();
    $('div.editable-item').addClass('edit-item');
    $('.enable-edit').show();
    $('.hide-during-edit').hide();
    gazetteer.editButton.hide();
    gazetteer.saveButton.show();
    gazetteer.cancelButton.show();
    gazetteer.checkDirty();
    if( window.qcontroller )
    {
        if( window.qcontroller )
        {
            window.qcontroller.setEditing( true );
        }
    }

}

gazetteer.saveEdit = function()
{
    var edited={};
    var deleted=[];
    var newitems=[];
    $('.edit-update:visible .edit-value').each( function()
    {
        var el = $(this);
        if( el.val() != gazetteer.editdata[el.attr('id')] )
        {
            edited[el.attr('id')]= el.val();
        }
    });
    $('.edit-delete-item').each( function() { deleted.push($(this).attr('id'));});
    $('.edit-new-item').each( function(){
        var itemdata={};
        itemdata._item_type = $(this).attr('object_type');
        $(this).find('.edit-value').each( function(){
            itemdata[$(this).attr('name')]=$(this).val();
        });
        newitems.push(itemdata);
    });
    var edits = JSON.stringify( {'update': edited, 'delete': deleted, 'new': newitems } );
    if( window.qcontroller )
    {
        window.qcontroller.applyUpdates(edits);
    }
}

gazetteer.cancelEdit = function()
{
    $('.cancel-edit-link').click();
    $('span.author').hide();
    $('div.editable-item').removeClass('edit-item');
    $('.enable-edit').hide();
    $('.hide-during-edit').show();
    gazetteer.editButton.show();
    gazetteer.saveButton.hide();
    gazetteer.cancelButton.hide();
    {
        if( window.qcontroller )
        {
            window.qcontroller.setEditing( false );
            window.qcontroller.setDirty( false );
        }
    }
}

// Get the validator for an item

gazetteer.getValidator = function( objtype, field )
{
    var key = 'validate_'+objtype;
    if(field){ key = key + '_' + field;}
    if(! gazetteer.validators ) { return undefined; }
    var func = gazetteer.validators[key];
    if(! func ) { return undefined; }
    if( typeof(func) != "function")
    {
        return undefined;
    }
    return func;
}

// Get a function to retrieve the value of an item -
// either a string for an element, or an object for a block

gazetteer.getValueFunction = function( item )
{
    if( item.is('div'))
    {
        return function(){
            var value = {};
            item.find('.edit-value').each( function()
            {
                var field = $(this);
                value[field.attr('name')] = field.val();
            });
            return value;
        }
    }
    return function(){ return item.val(); }
}

gazetteer.setupFieldValidation = function( item, errordiv )
{
    var field=item.attr('name');
    if( ! field ){ return; }
    var objtype=item.closest('div.object-type').attr('object_type');
    var validator = gazetteer.getValidator(objtype,field);
    if(validator)
    {
        var valfunc = gazetteer.createValidator( item, validator, errordiv );
        valfunc();
        item.change( valfunc );
    }
}

gazetteer.createValidator = function( item, validator, errordiv )
{
    var getvalfunc = gazetteer.getValueFunction( item );
    var error = $('<p class="validator-error"></p>');
    error.hide();
    errordiv.append(error);
    valfunc = function()
    {
        var value = getvalfunc();
        var result = value != null ? validator(value) : null;
        error.text(result);
        if( result )
        {
            item.addClass('invalid-data');
            error.show();
        }
        else
        {
            item.removeClass('invalid-data');
            error.hide();
        }
        gazetteer.checkDirty();
    };
    return valfunc;
}

gazetteer.setupValidators = function( block )
{
    var errordiv = $('<div class="errors"></div>');
    block.find('.edit-value').each( function(){
        gazetteer.setupFieldValidation( $(this), errordiv );
    });
    objtype = block.attr('object_type');
    if( objtype )
    {
        validator = gazetteer.getValidator(objtype);
        if( validator )
        {
            var valfunc = gazetteer.createValidator( block, validator, errordiv );
            valfunc();
            block.find('.edit-value').change(valfunc);
        }
    }
    if( errordiv.find('p.validator-error').length ) block.append(errordiv);
}

// Set up the processing of data on the page, adding links for editing etc.
// An edit block is a form for editing an item.  This code hides the block and
// adds a link to unhide for editing.

gazetteer.setupEditUpdate = function()
{
   var block=$(this);

   // Set up feature type categories
   gazetteer.setupFeatureTypes( block );

   // Set up authorities options list function
   gazetteer.setupEventAuthorities( block );

   // Set up the data values
   // edit blocks contain values set from the editdata variable.  Initiallize
   // the value, and put in a change event handler.

   block.find('.edit-value').each( function()
   {
       var el = $(this);
       var data = gazetteer.editdata[el.attr('id')];
       el.val(data);
       el.change( gazetteer.checkDirty );
       return true;
   });

   // Set up up the validators

   gazetteer.setupValidators( block );

   // Set up up the links to expose and hide the block

   var bid=block.attr("id");
   var elink = $('#'+bid+'_edit_link')
   var nlink = $('#'+bid+'_unedit_link')
   if( ! elink.length )
   {
      elink=$('<a href="javascript:0" class="show-edit-update action-link">Edit</a>');
      elink.insertAfter(block);
   }
   if( ! nlink.length )
   {
      nlink=$('<a href="javascript:0" class="show-edit-update action-link">Cancel edit</a>');
      if( ! block.is('span') ) block.append('<br />');
      block.append(nlink);
   }
   elink.addClass("enable-edit");
   nlink.addClass("cancel-edit-link");
   elink.hide();
   nlink.hide();
   block.hide();
   elink.click(function()
       {
           elink.hide();
           nlink.show();
           block.show();
           block.find('.edit-value').trigger('gazStartEditEvent');
       });
   nlink.click(function()
       {
           nlink.hide();
           block.hide();
           elink.show();
           block.find('.edit-value').trigger('gazEndEditEvent');
       });
   return true;
}


// An edit-item with can-delete is a block relating to an object that can be
// deleted.  Add a delete link which when clicked hides the block, replacing it
// with a link to undelete the block.

gazetteer.setupEditDelete = function()
{
   var ediv=$(this);
   var dlink=$('<a href="javascript:0" class="enable-edit delete-edit-item action-link">Delete</a>');
   var ulink=$('<a href="javascript:0" class="undelete-edit-item cancel-edit-link action-link">Restore deleted item</a>');
   var udiv = $('<div class="edit-restore" />');
   udiv.append(ulink);
   udiv.insertAfter(ediv);
   udiv.hide();
   ediv.append(dlink);
   dlink.hide();
   dlink.click(function(){
       ediv.hide();
       ediv.addClass('edit-delete-item');
       udiv.show();
       gazetteer.checkDirty();
   });
   ulink.click(function(){
       ediv.show();
       ediv.removeClass('edit-delete-item');
       udiv.hide();
       gazetteer.checkDirty();
   });
   return true;
}

// edit-new-template are templates for new items that can be added.
// For each one create a link to open it.


// Create a new item by cloning the template.  Insert a link to remove the item

gazetteer.createNewItem = function( template, eltype )
{
    var copy = template.clone();
    copy.removeAttr('id');
    copy.removeClass('edit-new-template');
    copy.addClass('edit-new-item');

    // Set up authorities options list function and field validators
    gazetteer.setupEventAuthorities( copy );
    gazetteer.setupValidators( copy );
    copy.find('.viewed-name-lookup').each( gazetteer.setupViewedNamesSelector );

    // Set up link to cancel new item
    var dlink = $('<a href="javascript:0" class="delete-new-edit-block cancel-edit-link action-link">Delete new '+eltype+'</a>');
    copy.append('<br />');
    copy.append(dlink);
    copy.insertBefore(template);
    dlink.click(function(){copy.remove(); gazetteer.checkDirty()});
    gazetteer.checkDirty();
}

gazetteer.setupEditNew = function()
{
   var block=$(this);
   var bid=block.attr("id");
   var eltype=block.attr('object_type') || 'item';
   eltype = eltype.replace(/([a-z])([A-Z])/,'$1 $2');
   eltype = eltype.toLowerCase();
   var eltypedef=block.find('input[name="_item_type_name"]');
   if( eltypedef.length )
   {
       eltype=eltypedef.val();
   }

   var nlink = $('#'+bid+'_link');
   if( ! nlink.length )
   {
      nlink=$('<a href="javascript:0" class="edit-new-link action-link">Create new '+eltype+'</a>');
      nlink.insertBefore(block);
   }
   nlink.addClass('enable-edit');
   nlink.hide();
   nlink.click(function(){
      gazetteer.createNewItem( block, eltype );
   });
   return true;
}

gazetteer.createFavouriteButton = function()
{
    var span = $(this);
    var id= span.text();
    try
    {
        var isfavourite = window.qcontroller.isFavourite;

        var favicon = "img/fav.png";
        var notfavicon = "img/not_fav.png";
        var icon = isfavourite ? favicon : notfavicon;
        var el = $('<img src="'+icon+'"></img>');
        el.insertBefore(span);
        el.click(function()
        {
            isfavourite = ! isfavourite;
            window.qcontroller.isFavourite=isfavourite;
            icon = isfavourite ? favicon : notfavicon;
            el.attr('src',icon);
        });
    }
    catch (err )
    {
    }
    span.remove();
}

gazetteer.setupFeatureTypes = function( block )
{
    var featTypes = gazetteer.getControllerData('featureTypes','featureTypes',[]);
    var typeopt = block.find('select[name="feat_type"]');
    var catopt = block.find('select[name="feat_type_category"]');
    if( ! typeopt.length ) return;
    if( ! catopt.length ) return;
    if( ! featTypes.length ) return;
    var nl = featTypes.length;
    var setTypeOpts=function()
    {
        var category = catopt.val();
        var curval=typeopt.val();
        typeopt.empty();
        for( var i=0; i<nl; i++ )
        {
            var ftype=featTypes[i];
            if( ftype.category == category )
            {
                var iscur = ftype.code == curval;
                typeopt.append( new Option(ftype.value,ftype.code,iscur,iscur));
            }
        }
    }
    var data = gazetteer.editdata[typeopt.attr('id')];
    if( data )
    {
        for( var i=0; i < nl; i++ )
        {
            var ftype = featTypes[i];
            if( ftype.code == data )
            {
                catopt.val(ftype.category);
                break;
            }
        }
    }
    catopt.change(setTypeOpts);
    setTypeOpts();
}

gazetteer.setupEventAuthorities = function( block )
{
    var authorities = gazetteer.getControllerData('eventTypes','eventTypes',[]);
    var validauth = gazetteer.getControllerData('eventTypeAuthorities','eventTypeAuthorities',{});
    var typeopt = block.find('select[name="event_type"]');
    var authopt = block.find('select[name="authority"]');
    var dbvalue = gazetteer.editdata[authopt.attr('id')];
    if( ! typeopt.length ) return;
    if( ! authopt.length ) return;
    var nl = authorities.length;
    var setAuthOpts = function()
    {
        var curval = authopt.val();
        var optlist = validauth[typeopt.val()];
        authopt.empty();
        for( var i=0; i<nl; i++ )
        {
            var auth = authorities[i];
            if( auth.code == dbvalue || ! optlist || optlist.indexOf(auth.code) >=  0)
            {
                var iscur = auth.code == curval;
                authopt.append( new Option(auth.value, auth.code, iscur, iscur));
            }
        }
    }
    typeopt.change(setAuthOpts);
    setAuthOpts();
}

gazetteer.setupViewedNamesSelector = function()
{
    var select = $(this);
    var resetViews = function()
        {
        var curval = select.val();
        var views = gazetteer.getControllerData('viewedNames','viewedNames',[],true);
        var nviews = views.length;
        select.empty();
        for( var i=0; i < nviews; i++ )
        {
            var name = views[i];
            var iscur = name.name_id == curval;
            select.append( new Option( name.name, name.name_id, iscur, iscur ));
        }
    };
    select.focus(resetViews);
    resetViews()
}

gazetteer.setupNameLink = function()
{
    var link=$(this);
    var name_id = link.attr('href');
    name_id=name_id.replace( /^\?id\=/,'');
    link.click( function( event )
    {
        if( window.qcontroller ) window.qcontroller.showNameId( name_id, event.ctrlKey );
        return false;
    });
}

gazetteer.setupNameProcessHandler = function()
{
    var dfltproc = $('[name=default_name_process]').first();
    var procsel = $('[name=name_process]').first();
    var statussel = $('[name=name_status]').first();
    if( ! dfltproc.length || ! statussel.length ) return;
    var statuses = gazetteer.getControllerData('statuses','',null,false);
    var procstatus = gazetteer.getControllerData('processStatuses','',null,false);
    if( ! statuses || ! procstatus ) return;


    var processUpdated = function()
    {
        var procval = null;
        if(procsel.length && procsel.is(':visible'))
        {
            procval = procsel.val();
        }
        if( ! procval )
        {
            procval = dfltproc.val();
        }
        var statval=statussel.val();
        statussel.empty();
        var ns = statuses.length;
        var valid=['UNEW','UDEL',statval];
        if( procval in procstatus )
        {
            valid = valid.concat(procstatus[procval]);
        }
        for( var i = 0; i < ns; i++ )
        {
            var s = statuses[i];
            if( valid.indexOf(s.code) < 0 ) continue;
            var iscur = s.code == procval;
            statussel.append( new Option(s.value, s.code, iscur, iscur));
        }
    }
    processUpdated();
    if( procsel )
    {
        procsel.change(processUpdated);
        procsel.bind('gazStartEditEvent',processUpdated);
        procsel.bind('gazEndEditEvent',processUpdated);
    }
}


gazetteer.getControllerData = function( name, property, dflt, refresh )
{
    if( refresh || ! (name in gazetteer) )
    {
        gazetteer[name] = dflt;
        try
        {
            if( ! property ){ property = name; }
            jsdata = window.qcontroller[property];
            gazetteer[name]=JSON.parse(jsdata);
        }
        catch (err)
        {
        };
    }
    return gazetteer[name];
}

gazetteer.createEditButtons = function()
{
    var buttonbar = $('#button_bar');
    gazetteer.editButton = $('<input type="submit" class="button" name="Edit" value="Edit" />');
    gazetteer.saveButton = $('<input type="submit" class="button" name="Save" value="Save" />');
    gazetteer.cancelButton = $('<input type="submit" class="button" name="Cancel" value="Cancel" />');

    buttonbar.append(gazetteer.editButton);
    buttonbar.append(gazetteer.saveButton);
    buttonbar.append(gazetteer.cancelButton);

    gazetteer.saveButton.hide();
    gazetteer.cancelButton.hide();

    gazetteer.editButton.click(gazetteer.startEdit);
    gazetteer.saveButton.click(gazetteer.saveEdit);
    gazetteer.cancelButton.click(gazetteer.cancelEdit);
}

gazetteer.setup = function()
{
    // const backgroundColor = window.getComputedStyle( document.body ,null).getPropertyValue('background-color');
    // if(backgroundColor === 'rgba(0, 0, 0, 0)') {
    //     $('.data').addClass("NightMapping");
    // }
    // else {
    //     $('.data').removeClass("NightMapping");
    // }
    gazetteer.getControllerData('editdata','pageData',{});

    $('.edit-update').each( gazetteer.setupEditUpdate );
    $('div.editable-item.can-delete').each( gazetteer.setupEditDelete );
    $('.edit-new-template').each( gazetteer.setupEditNew );
    $('#favourite_button').each( gazetteer.createFavouriteButton );
    $('.viewed-name-lookup').each( gazetteer.setupViewedNamesSelector );
    $('span.author').hide();
    $('a.name_link').each( gazetteer.setupNameLink );
    gazetteer.createEditButtons();
    gazetteer.setupNameProcessHandler();
    if( $('[name=name_status]').value == 'UNEW' )
    {
        gazetteer.startEdit();
    }
    else
    {
        gazetteer.cancelEdit(); // Hide links until edit button is clicked
    }

    // Not triggered in QWebView ...
    // window.onbeforeunload=function()
    // {
    //     if( gazetteer.isDirty())
    //     {
    //         var title=$(document).attr('title');
    //         return "You haven't saved saved changes for "+title;
    //     }
    // }
}

$(document).ready(gazetteer.setup);

