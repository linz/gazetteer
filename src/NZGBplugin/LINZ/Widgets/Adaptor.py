################################################################################
#
#  New Zealand Geographic Board gazetteer application,
#  Crown copyright (c) 2020, Land Information New Zealand on behalf of
#  the New Zealand Government.
#
#  This file is released under the MIT licence. See the LICENCE file found
#  in the top-level directory of this distribution for more information.
#
################################################################################


class Adaptor(object):
    """
    Adaptor class is a base class for adaptors to connect classes or other
    object representations to widgets.  The Adaptor defines the attributes
    of an object, their type, and provides functions gets and sets values.
    The Adaptor must be subclassed.

    Also it supports heirarchies of objects using the conventional dot
    notation (ie attributes like "owner.name")

    The attributes defined in the adaptor have a defined type, and can
    be editable or not.

    One attribute can be set as an idattribute, defining the unique id
    for the object

    Adaptors are used with AdaptorConnectors, which connect the adaptor
    to a widget, and AdaptorListModels, which define
    """

    class AttDef(object):
        def __init__(self, attribute, atype, editable, islist):
            self._attribute = attribute
            self._isobject = isinstance(atype, Adaptor)
            self._type = atype
            self._editable = editable
            self._islist = islist

        def attribute(self):
            return self._attribute

        def isobject(self):
            return self._isobject

        def type(self):
            return self._type

        def editable(self):
            return self._editable

        def islist(self):
            return self._islist

    def __init__(self, *attrlist, **attributes):
        """
        Initiallize the attribute list.  This optionally defines
        a set of attributes, supplied as name=type pairs.  Attributes
        added this way are stored in sorted order of names.

        For attributes which are themselves objects use an Adaptor
        for the object instead of a type.
        """
        # If using python > 2.7 this is could be replaced with collections.OrderedDict
        if type(self) == Adaptor:
            raise RuntimeError("The Adaptor class is abstract - it must be subclassed")
        self._attributes = []
        self._attrdef = {}
        self._idattribute = ""
        self._typename = ""
        iattr = 0
        while iattr < len(attrlist):
            attr = attrlist[iattr]
            iattr += 1
            if not isinstance(attr, str):
                raise RuntimeError(
                    "Adaptor constructor received invalid attribute name " + str(attr)
                )
            atype = str
            if iattr < len(attrlist) and type(attrlist[iattr]) == type:
                atype = attrlist[iattr + 1]
                iattr += 1
            self.addAttribute(attr, atype)

        for key in sorted(attributes.keys()):
            self.addAttribute(key, attributes[key])

    def addAttribute(self, attribute, atype, editable=False, isid=False, islist=False):
        """
        Add an attribute, defining the object and type.
        Attributes retain the order they are added in.
        """
        if not isinstance(atype, type) and not isinstance(atype, Adaptor):
            raise RuntimeError(
                str(atype) + " is not an type in " + self.__class__.__name__
            )
        if attribute not in self._attrdef:
            self._attributes.append(attribute)
        self._attrdef[attribute] = Adaptor.AttDef(attribute, atype, editable, islist)
        if isid:
            self.setIdAttribute(attribute)

    def setEditable(self, attribute="", editable=True):
        """
        Sets or unsets the editable flag for a specific attribute
        if one is defined, or all attributes if it is blank
        """
        if not attribute:
            for a in list(self._attrdef.values()):
                a._editable = editable
        else:
            if attribute in self._attrdef:
                self._attrdef[attribute]._editable = editable

    def setTypeName(self, typename):
        """
        Sets the name of the type for which this adapator applies,
        used for error messages
        """
        self._typename = typename

    def setIdAttribute(self, idattribute):
        """
        Set an attribute is the unique identifier for the object
        where appropriate.
        """
        if idattribute not in self._attrdef:
            raise RuntimeError(
                "Invalid id "
                + idattribute
                + " specified for "
                + self.typename()
                + " adaptor"
            )
        self._idattribute = idattribute

    def typename(self, object=None):
        """
        Returns the typename defined for the adaptor, or the type
        of the supplied object if no typename is given
        """
        return (
            self._typename
            if self._typename
            else object.__class__.__name__
            if object != None
            else self.__class__.__name__
        )

    def attributes(self):
        """
        Return the list of attributes
        """
        return self._attributes

    def typeof(self, attribute):
        """
        Return the type of an attribute
        """
        return self._attrdef[attribute].type

    def editable(self, attribute):
        """
        Return true if the attribute has been flagged as editable
        """
        return self._attrdef[attribute].editable()

    def idattribute(self):
        """
        Return the name of the attribute that is the unique id
        """
        return self._idattribute

    def _getObjectValue(self, object, attribute):
        """
        Must be overridden in a subclass to provide the code for
        getting an attribute value from an object.

        Not intended to be called directly - use getValue
        """
        raise RuntimeError(
            self.__class__.__name__ + " needs to override _setObjectValue"
        )

    def _setObjectValue(self, object, attribute, value):
        """
        Must be overridden in a subclass to provide the code for
        setting an object value

        Not intended to be called directly - use setValue
        """
        raise RuntimeError(
            self.__class__.__name__ + " needs to override _setObjectValue"
        )

    def _getMemberObject(self, object, attribute):
        """
        Split off member objects from a dotted attribute
        """
        member, memberattr = attribute.split(".", 1)
        if not member in self._attrdef:
            raise RuntimeError(
                member + " is not defined in the Adaptor for " + self.typename(object)
            )
        attrdef = self._attrdef[member]
        if attrdef.islist():
            raise RuntimeError(
                "Cannot retrieve "
                + memberattr
                + " of list member "
                + member
                + " of "
                + self.typename(object)
            )
        if not attrdef.isobject():
            raise RuntimeError(
                attribute
                + " is not defined in the Adaptor for "
                + self.typename(object)
            )
        adaptor = attrdef.type()
        member = self._getObjectValue(object, member)
        return adaptor, member, memberattr

    def getAttrDef(self, attribute):
        parts = attribute.split(".", 1)
        if parts[0] in self._attrdef:
            attrdef = self._attrdef[parts[0]]
            if len(parts) == 1:
                return attrdef
            elif attrdef.isobject():
                return attrdef.type().getAttrDef(parts[1])
        raise RuntimeError(
            "Invalid attribute " + str(attribute) + " requested for " + self.typename()
        )

    def getId(self, object):
        """
        Returns the value defined by the idattribute if it is defined
        """
        if self._idattribute:
            return self.getValue(object, self._idattribute)
        return None

    def getValue(self, object, attribute):
        """
        Gets the value of an attribute of an object
        """
        if object == None:
            return None
        elif "." in attribute:
            adaptor, member, attribute = self._getMemberObject(object, attribute)
            return adaptor.getValue(member, attribute)
        if attribute not in self._attrdef:
            raise RuntimeError(
                "Invalid attribute " + attribute + " of " + self.typename(object)
            )
        attrdef = self._attrdef[attribute]
        return self._getObjectValue(object, attribute)

    def setValue(self, object, attribute, value, overwrite=False):
        """
        Sets the value of an attribute of an object
        """
        if "." in attribute:
            member, attr = attribute.split(".", 1)
            if member not in self._attrdef:
                raise RuntimeError(
                    "Invalid attribute " + attribute + " of " + self.typename(object)
                )
            if not self._attrdef[member].editable():
                raise RuntimeError(
                    "Cannot edit the "
                    + attribute
                    + " attribute of "
                    + self.typename(object)
                )
            adaptor, member, attribute = self._getMemberObject(object, attribute)
            adaptor.setValue(member, attribute, value, overwrite)
            return
        elif attribute not in self._attrdef:
            raise RuntimeError(
                "Invalid attribute " + attribute + " of " + self.typename(object)
            )
        attrdef = self._attrdef[attribute]
        if attrdef.islist():
            raise RuntimeError(
                "Attribute "
                + attribute
                + " of "
                + self.typename(object)
                + " cannot be updated as it is a list attribute"
            )
        if attrdef.isobject():
            raise RuntimeError(
                "Attribute "
                + attribute
                + " of "
                + self.typename(object)
                + " cannot be used without member attribute qualifier"
            )
        if not attrdef.editable() and not overwrite:
            raise RuntimeError(
                "The "
                + attribute
                + " attribute of "
                + self.typename(object)
                + " cannot be edited"
            )
        if value != None:
            t = attrdef.type()
            try:
                value = t(value)
            except:
                raise RuntimeError(
                    "Cannot convert "
                    + str(value)
                    + " to "
                    + t.__name__
                    + " for "
                    + self.typename(object)
                    + "."
                    + attribute
                )
        self._setObjectValue(object, attribute, value)
