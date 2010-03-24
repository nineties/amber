(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: totac.rl 2010-03-24 12:15:30 nineties $
 %);

(% translate typed rowlcore to Three Address Code %);

include(stddef, code);
export(transl);

(%
 %
 %
 %
 %
 %
 %
 %
 %
 %
 %);

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

transl_extfuncs: [not_reachable, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented
];

(% p0: item %);
transl_extitem: (p0) {
    allocate(1);
    x0 = transl_extfuncs[p0[0]];
    return x0(p0);
};

transl_prog: (p0) {
    if (p0 == NULL) { return NULL; };
    return ls_cons(transl_extitem(ls_value(p0)), ls_next(p0));
};

(% p0: program (item list) %);
transl: (p0) {
    return transl_prog(p0[1]);
};
