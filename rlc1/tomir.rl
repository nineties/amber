(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: tomir.rl 2010-03-24 03:32:05 nineties $
 %);

(% translate typed rowlcore to MIR %);

include(stddef, code);
export(tomir);

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

tomir_funcs: [not_reachable, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented
];

(% p0: item %);
tomir_item: (p0) {
    allocate(1);
    x0 = tomir_funcs[p0[0]];
    return x0(p0);
};

tomir_prog: (p0) {
    if (p0 == NULL) { return NULL; };
    return ls_cons(tomir_item(ls_value(p0)), ls_next(p0));
};

(% p0: program (item list) %);
tomir: (p0) {
    return tomir_prog(p0[1]);
};
