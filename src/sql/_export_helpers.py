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

import re


def event_ref_inner_query(event_type, authority, expose_id=False):
    if authority:
        if "," in authority:
            authorities = "', '".join(authority.split(","))
            authority_clause = f"and  ne.authority = ANY(ARRAY['{authorities}'])"
        else:
            authority_clause = f"and  ne.authority = '{authority}'"
    else:
        authority_clause = ""

    return re.sub(
        r"\n *\n",
        "\n",
        f"""select
            {"event_id as id," if expose_id else ""}
            event_reference as ref,
            event_date
            from name_event ne
            where ne.name_id = n.name_id
            and  ne.event_type='{event_type}'
            {authority_clause}
            order by event_date desc
            limit 1""",
    )


def sub_event_references():
    events = ["nzgb", "doc_gaz", "rev_gaz"]

    def generate_sub_event_col(key):
        return f"""
        (select ref from (select
            sub_event_reference as ref,
            sub_event_date
            from sub_event se
            where se.event_id = {key}_event.id
            order by sub_event_date desc
            limit 1) as x)
            as {key}_sub_ref,"""

    return "".join(map(generate_sub_event_col, events)).strip()[:-1]


def generate_event_ref_sql(m):
    return f"""   (select ref from ({event_ref_inner_query(m.group(2), m.group(3))}) as x)
            as {m.group(1)},"""
