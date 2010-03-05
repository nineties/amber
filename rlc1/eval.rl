(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: eval.rl 2010-02-22 18:06:26 nineties $ 
 %);

include(stddef, code);
export(eval);

unit: () {
    allocate(1);
    x0 = mktup4(NODE_TUPLE, NULL, 0, NULL);
    x0[1] = mktup3(NODE_TUPLE_T, 0, NULL);
    return x0;
};

eval_funcs: [ not_called, eval_integer, eval_string, eval_identifier,
    not_called, eval_block, eval_tuple, not_called, not_called, eval_decl
];

not_called: (p0) {
    fputs(stderr, "ERROR: this function should not be called\n");
    exit(1);
};

eval_integer: (p0) {
    return p0;
};

eval_string: (p0) {
    return p0;
};

eval_identifier: (p0) {
    return p0;
};

eval_block: (p0) {
    allocate(1);
    x0 = p0[2];
    while (x0 != NULL) {
        eval(ls_value(x0));
        x0 = ls_next(x0);
    };
    return unit();
};

eval_tuple: (p0) {
    return p0;
};

eval_decl: (p0) {
    return p0;
};

(% p0: node %);
eval: (p0) {
    allocate(1);
    x0 = eval_funcs[p0[0]];
    return x0(p0);
};
