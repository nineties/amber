(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: eval.rl 2010-05-20 02:51:35 nineties $
 %);

include(stddef,code);
export(eval_sexp);

symbol_map: NULL;

init_evaluator: () {
};

eval_sexp: (p0) {
    allocate(1);
    if (p0 == NULL) { return p0; };
    x0 = p0[0]; (% node code %);
    if (x0 == NODE_CONS) {
        fputs(stderr, "ERROR 'eval_sexp': not implemented yet\n");
        exit(1);
    };
    if (x0 == NODE_SYMBOL) {
        fputs(stderr, "ERROR 'eval_sexp': not implemented yet\n");
        exit(1);
    };
    if (x0 == NODE_INT) {
        return p0;
    };
    if (x0 == NODE_CHAR) {
        return p0;
    };
    if (x0 == NODE_STRING) {
        return p0;
    };
    panic("'eval_sexp': not reachable here");
};
