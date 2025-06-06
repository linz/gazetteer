// Define validators for fields.  Validators are named as
// object_type + '_' + field_name
// Each validator receives the jquery object being validated, and returns
// a string with an error message, or an empty string if no error.

var gazetteer = gazetteer || {};
gazetteer.validators = gazetteer.validators || {};

String.prototype.trim = function() { return this.replace(/^\s+|\s+$/g, ''); }


gazetteer.validators.validateDateString = function(field,dstr) {
    if( ! dstr.match(/^[123]?\d(\-|\s+)(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)(\-|\s+)(19|20)\d\d$/i))
    {
        return field+' must be formatted as (for example) 23-Jun-2005';
    }
    if( isNaN(Date.parse(dstr)))
    {
        return field+' is not a valid date';
    }
    return '';
}

gazetteer.validators.validateRequired = function( message )
{
    return function( dstr )
    {
        if( ! dstr.match(/\S/)) return message;
        return '';
    }
}

gazetteer.validators.validate_Event_event_date = function(dstr)
{
    dstr = dstr.trim();
    if( dstr == '' )
    {
        return "You must supply an event date";
    }
    return gazetteer.validators.validateDateString( 'Event date', dstr );
}

gazetteer.validators.validate_SubEvent_sub_event_date = function(dstr)
{
    dstr = dstr.trim();
    if( dstr == '' )
    {
        return "You must supply a date";
    }
    return gazetteer.validators.validateDateString( 'SubEvent date', dstr );
}

gazetteer.validators.validate_SubEvent = function(evt)
{
    if( ! gazetteer.validators.subEventReferenceValidators )
    {
        var validators = {};
        try
        {
            validators = JSON.parse(window.qcontroller.subEventReferenceValidators);
        }
        catch(err)
        {
        }
        gazetteer.validators.subEventReferenceValidators = validators;
    }
    validators = gazetteer.validators.subEventReferenceValidators;

    var ref = evt.sub_event_reference;
    if( evt.authority in validators ) {
        var vdt = validators[evt.authority];
        if( ! ref.match(RegExp(vdt.re)) ) return vdt.message;
    }
    else if( evt.sub_event_reference.match(/^\s*$/))
    {
        return "You must supply a reference for the sub event";
    }
    return '';
}

// 
gazetteer.validators.validate_Event = function(evt)
{
    if( ! gazetteer.validators.eventReferenceValidators )
    {
        var validators = {};
        try
        {
            validators = JSON.parse(window.qcontroller.eventReferenceValidators);
        }
        catch(err)
        {
        }
        gazetteer.validators.eventReferenceValidators = validators;
    }
    validators = gazetteer.validators.eventReferenceValidators;

    var ref = evt.event_reference;

    if( evt.event_type in validators )
    {
        var vdt = validators[evt.event_type];
        if( ! ref.match(RegExp(vdt.re)) ) return vdt.message;
    }
    else if( evt.event_reference.match(/^\s*$/))
    {
        return "You must supply a reference for the event";
    }
    return '';
}

gazetteer.validators.validate_NameAnnotation = function(annot)
{
    if( ! gazetteer.validators.nameAnnotationValidators )
    {
        var validators = {};
        try
        {
            validators = JSON.parse(window.qcontroller.nameAnnotationValidators);
        }
        catch(err)
        {
        }
        gazetteer.validators.nameAnnotationValidators = validators;
    }
    var validators = gazetteer.validators.nameAnnotationValidators;

    var note = annot.annotation;

    if( annot.annotation_type in validators )
    {
        var vdt = validators[annot.annotation_type];
        if( ! note.match(RegExp(vdt.re)) ) return vdt.message;
    }
    else if( note.match(/^\s*$/))
    {
        return "You must supply some text for the annotation";
    }
    return '';
}

gazetteer.validators.validate_FeatureAnnotation = function(annot)
{
    if( ! gazetteer.validators.featAnnotationValidators )
    {
        var validators = {};
        try
        {
            validators = JSON.parse(window.qcontroller.featAnnotationValidators);
        }
        catch(err)
        {
        }
        gazetteer.validators.featAnnotationValidators = validators;
    }
    var validators = gazetteer.validators.featAnnotationValidators;

    var note = annot.annotation;

    if( annot.annotation_type in validators )
    {
        var vdt = validators[annot.annotation_type];
        if( ! note.match(RegExp(vdt.re)) ) return vdt.message;
    }
    else if( note.match(/^\s*$/))
    {
        return "You must supply some text for the annotation";
    }
    return '';
}

gazetteer.validators.validate_Feature_setLocation=function(coords)
{
    if( ! gazetteer.validators.coordPatterns )
    {
        var patterns=[];
        try
        {
            patterns = JSON.parse(window.qcontroller.coordValidators);
            var np = patterns.length;
            for( var i=0; i < np; i++ )
            {
                patterns[i]=RegExp(patterns[i],'i');
            }
        }
        catch(err)
        {
            patterns = [];
        }
        gazetteer.validators.coordPatterns = patterns;
    }
    var patterns = gazetteer.validators.coordPatterns;
    var np = patterns.length;

    for( var i=0; i < np; i++ )
    {
        if( coords.match(patterns[i])) { return ''; }
    }
    if( np > 0 )
    {
        return 'Coordinates must be a valid lat/lon or NZTM value';
    }
    return '';
}

gazetteer.validators.validate_Name_name = gazetteer.validators.validateRequired( "You must supply a name - it cannot be blank") ;
gazetteer.validators.validate_Association_assoc_type = gazetteer.validators.validateRequired( "You must select an association type") ;
gazetteer.validators.validate_Association_name_id_to = gazetteer.validators.validateRequired( "You must select another name to associate with") ;
