(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: codegen.rl 2010-02-22 18:06:25 nineties $ 
 %);

include(stddef, code);
export(codegen);

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};


ext_funcs: [not_implemented ,not_implemented ,not_implemented ,not_implemented
    ,not_implemented ,not_implemented ,not_implemented ,not_implemented ,ext_decl
    ,not_implemented ,not_implemented ,not_implemented ,not_implemented ,not_implemented
    ,not_implemented ,not_implemented ,not_implemented
];

(% p1: var, p2: value %);
ext_char_decl: (p0, p1, p2) {
    fputs(p0, p1[2]);
    fputs(p0, ": .byte ");
    fputi(p0, p2[3]);
    fputc(p0, '\n');
};

ext_int_decl: (p0, p1, p2) {
    fputs(p0, p1[2]);
    fputs(p0, ": .long ");
    fputi(p0, p2[3]);
    fputc(p0, '\n');
};

ext_string_decl: (p0, p1, p2) {
    fputs(p0, p1[2]);
    fputs(p0, ": .string ");
    fputs(p0, p2[2]);
    fputc(p0, '\n');
};

ext_array_decl: (p0, p1, p2) {
    not_implemented();
};

ext_decl: (p0, p1) {
    allocate(1);
    x0 = p1[1]; (% type %);
    if (x0[0] == NODE_CHAR_T) { return ext_char_decl(p0, p1[2], p1[3]); };
    if (x0[0] == NODE_INT_T)  { return ext_int_decl(p0, p1[2], p1[3]); };
    if (x0[0] == NODE_ARRAY_T) {
        if (x0[2]) {
            (% string declaration %);
            return ext_string_decl(p0, p1[2], p1[3]);
        } else {
            return ext_array_decl(p0, p1[2], p1[3]);
        };
    };
    not_implemented();
};

codegen_external_item: (p0, p1) {
    allocate(1);
    x0 = ext_funcs[p1[0]];
    x0(p0, p1);
};

(% p0: output channel, p1: NODE_PROG %);
codegen: (p0, p1) {
    allocate(1);
    x0 = p1[1];
    while (x0 != NULL) {
        codegen_external_item(p0, ls_value(x0));
        x0 = ls_next(x0);
    };
};
