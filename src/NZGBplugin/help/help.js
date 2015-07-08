// Setup up h2 elements to hide/show following sections
var gazhelp = gazhelp || {};

gazhelp.setuph2 = function()
{
    var h2=$(this);
    h2.nextUntil('h2').wrapAll('<div class="h2content" />');
    var div = h2.next();
    div.hide();
    h2.click( function() {div.toggle('fast');} );
    h2.addClass('button');
}

gazhelp.setup = function()
{
    $('h2').each( gazhelp.setuph2 );
}

$(document).ready( gazhelp.setup );
