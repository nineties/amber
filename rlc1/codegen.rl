(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: codegen.rl 2010-02-22 18:06:25 nineties $ 
 %);

include(stddef, code);
export(codegen);

codegen_funcs: [ not_called, do_nothing, do_nothing, not_called, not_called,
    not_called, not_called, do_nothing, not_called, not_called, not_called,
    codegen_asm
];

not_called: (p0, p1) {
    fputs(stderr, "ERROR: this function should not be called\n");
    exit(1);
};

do_nothing: (p0, p1) { };

codegen_asm: (p0, p1) {
    fputs(p0, get_rawstring(p1[1]));
};

codegen_item: (p0, p1) {
    allocate(1);
    x0 = codegen_funcs[p1[0]];
    x0(p0, p1);
};

(% p0: NODE_PROG %);
codegen: (p0, p1) {
    allocate(1);
    x0 = p1[1];
    while (x0 != NULL) {
        codegen_item(p0, ls_value(x0));
        fputc(p0, '\n');
        x0 = ls_next(x0);
    };
};
