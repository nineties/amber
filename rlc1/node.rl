(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: node.rl 2010-04-08 14:32:19 nineties $
 %);

include(stddef, code);
export(init_vartable, set_varid, num_variable, vartable);
export(get_ident_name);
export(get_rawstring);

varid: 0;
vartable: NULL;

set_varid: (p0) {
    p0[3] = varid;
    vec_pushback(vartable, p0);
    varid = varid + 1;
    return varid-1;
};

num_variable: () {
    return varid;
};

init_vartable: () {
    vartable = mkvec(0);
};

escaped: (p0) {
    if (p0 == ''')  { return '''; };
    if (p0 == '"')  { return '"'; };
    if (p0 == '\\') { return '\\'; };
    if (p0 == 'a')  { return '\a'; };
    if (p0 == 'b')  { return '\b'; };
    if (p0 == 'f')  { return '\f'; };
    if (p0 == 'n')  { return '\n'; };
    if (p0 == 'r')  { return '\r'; };
    if (p0 == 't')  { return '\t'; };
    if (p0 == 'v')  { return '\v'; };
    if (p0 == '0')  { return '\0'; };
    fputs(stderr, "ERROR: invalid escaped sequence ");
    fputc(stderr, p0);
    fputc(stderr, '\n');
};

get_ident_name: (p0) {
    return p0[2];
};

get_rawstring: (p0) {
    allocate(5);
    x0 = memalloc(strlen(p0[2])-1);
    x1 = p0[2];
    x2 = strlen(p0[2])-1;
    x3 = 0;
    x4 = 1;
    while (x4 < x2) {
        if (rch(x1, x4) == '\\') {
            wch(x0, x3, escaped(rch(x1, x4+1)));
            x4 = x4 + 2;
        } else {
            wch(x0, x3, rch(x1, x4));
            x4 = x4 + 1;
        };
        x3 = x3 + 1;
    };
    wch(x0, x3, '\0');
    return x0;
};

