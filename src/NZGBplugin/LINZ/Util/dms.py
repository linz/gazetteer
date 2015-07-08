################################################################################
#
# Copyright 2015 Crown copyright (c)
# Land Information New Zealand and the New Zealand Government.
# All rights reserved
#
# This program is released under the terms of the new BSD license. See the 
# LICENSE file for more information.
#
################################################################################

import re

latlon_patterns = [''.join(p.split()) for p in
    (
    # Decimal degrees
    r'''^\s*(\-?\d{1,3}(?:\.\d+)?)()()()
         \s+(\-?\d{1,3}(?:\.\d+)?)()()()\s*$''',
    # Decimal degrees plus hemisphere
    r'''^\s*(\-?\d{1,2}(?:\.\d+)?)()()\s*([ns])
         \s+(\-?\d{1,3}(?:\.\d+)?)()()\s*([ew])\s*$''',
    r'''^\s*(\-?\d{1,3}(?:\.\d+)?)()()\s*([ew])
         \s+(\-?\d{1,2}(?:\.\d+)?)()()\s*([ns])\s*$''',
    # Degrees/minutes plus hemisphere
    r'''^\s*(\d{1,2})\s+([0-5]?\d(?:\.\d+)?)()\s*([ns])
         \s+(\d{1,3})\s+([0-5]?\d(?:\.\d+)?)()\s*([ew])\s*$''',
    r'''^\s*(\d{1,3})\s+([0-5]?\d(?:\.\d+)?)()\s*([ew])
         \s+(\d{1,2})\s+([0-5]?\d(?:\.\d+)?)()\s*([ns])\s*$''',
    # Degrees/minutes/seconds plus hemisphere
    r'''^\s*(\d{1,2})\s+([0-5]\d)\s+([0-5]?\d(?:\.\d+)?)\s*([ns])
         \s+(\d{1,3})\s+([0-5]\d)\s+([0-5]?\d(?:\.\d+)?)\s*([ew])\s*$''',
    r'''^\s*(\d{1,3})\s+([0-5]\d)\s+([0-5]?\d(?:\.\d+)?)\s*([ew])
         \s+(\d{1,2})\s+([0-5]\d)\s+([0-5]?\d(?:\.\d+)?)\s*([ns])\s*$''',
    )]

latlon_re = [re.compile(p,re.I) for p in latlon_patterns]

def deg_dms( deg, ndp=1, hem=None ):
    neg = deg < 0
    deg = abs(deg)
    d=int(deg)
    deg=(deg-d)*60
    m=int(deg)
    s=(deg-m)*60
    if ndp <= 0:
        format ="{0} {1:02d} {2:02d}"
    else:
        format ="{0} {1:02d} {2:0"+str(ndp+3)+'.'+str(ndp)+"f}"
    dms=format.format(d,m,s)
    if hem:
        if neg:
            dms = dms+hem[0]
        elif len(hem) > 1:
            dms = dms+hem[1]
    elif neg:
        dms = '-'+dms
    return dms

def parse_lonlat( llstr ):
    # Decimal degrees (with or without hemisphere)
    for r in latlon_re:
        m = r.match(llstr)
        if m: break

    if not m:
        return None

    # Extract angles and hemispheres
    c1=float(m.group(1))+float(m.group(2) or '0')/60.0+float(m.group(3) or '0')/3600.0
    h1=m.group(4).upper()
    c2=float(m.group(5))+float(m.group(6) or '0')/60.0+float(m.group(7) or '0')/3600.0
    h2=m.group(8).upper()

    # If have hemisphere indicators
    if h1 or h2:
        if c1 < 0 or c2 < 0:
            return None
        if h1 in 'NS' and h2 in 'EW':
            if c1 > 90: return None
            if h1=='S': c1 = -c1
            if h2=='W': c2 = -c2
            return [c2,c1]
        if h2 in 'NS' and h1 in 'EW':
            if c2 > 90: return None
            if h1=='W': c1 = -c1
            if h2=='S': c2 = -c2
            return [c1,c2]
        else:
            return None

    # If decimal dms then need one > 90 to determine order
    if abs(c1) > 90 and abs(c2) <= 90:
        return [c1,c2]
    elif abs(c2) > 90 and abs(c1) <= 90:
        return [c2,c1]

    return None


if __name__ == '__main__':
    import sys
    try:
        import readline
    except:
        pass
    while True:
        x = raw_input('Enter a lat/lon string: ')
        if not x:
            break
        try:
            print parse_lonlat(x)
        except:
            print str(sys.exc_info()[1])
