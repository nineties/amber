(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: totac.rl 2010-03-24 12:09:59 nineties $
 %);

(% translate typed rowlcore to Three Address Code %);

include(stddef, code);
export(totac);

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

totac_extfuncs: [not_reachable, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented
];

(% p0: item %);
totac_extitem: (p0) {
    allocate(1);
    x0 = totac_extfuncs[p0[0]];
    return x0(p0);
};

totac_prog: (p0) {
    if (p0 == NULL) { return NULL; };
    return ls_cons(totac_extitem(ls_value(p0)), ls_next(p0));
};

(% p0: program (item list) %);
totac: (p0) {
    return totac_prog(p0[1]);
};
