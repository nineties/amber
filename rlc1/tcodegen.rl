(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: tcodegen.rl 2010-03-24 13:42:31 nineties $
 %);

(% translate typed rowlcore to Three-address Code %);

include(stddef, code);
export(tcodegen);

tcode : NULL;

emit: (p0) {
    tcode = ls_cons(p0, tcode);
};

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

transl_extfuncs: [
    not_reachable, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented, not_implemented, transl_extdecl, not_implemented,
    not_implemented, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented
];

transl_extdecl: (p0) {
    allocate(1);
    x0 = p0[1]; (% type %);
    if (x0[0] == NODE_LAMBDA_T) {
        emit(mktup2(TCODE_LABEL, mangle(x0, get_ident_name(p0[2]))));
    } else {
        emit(mktup2(TCODE_LABEL, get_ident_name(p0[2])));
    };
};

(% p0: item %);
transl_extitem: (p0) {
    allocate(1);
    x0 = transl_extfuncs[p0[0]];
    x0(p0);
};

(% p0: program (item list) %);
tcodegen: (p0) {
    allocate(1);
    x0 = p0[1];
    while (x0 != NULL) {
        transl_extitem(ls_value(x0));
        x0 = ls_next(x0);
    };
    return ls_reverse(tcode);
};
