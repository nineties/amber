(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: eval.rl 2010-05-20 03:45:30 nineties $
 %);

include(stddef,code);
export(init_evaluator, eval_sexp);

symbol_map: NULL; (% (symbol name, scope id) -> symbol object %);

scopeid: 0;
scopeid_stack: NULL;

(% p0: (symbol name, scope id) %);
symbol_hash: (p0) {
    return strhash(p0[0])*3 + p0[1];
};

symbol_equal: (p0, p1) {
    if (p0[1] != p1[1]) { return FALSE; };
    return streq(p0[0], p1[0]);
};

scope_push: () {
    scopeid = scopeid + 1;
    vec_pushback(scopeid_stack, scopeid);
};

scope_pop: () {
    vec_popback(scopeid_stack);
};

(% p0: symbol object %);
find_symbol: (p0) {
    allocate(4);
    x0 = vec_size(scopeid_stack)-1;
    x3 = sym_name(p0);
    while (x0 >= 0) {
        x1 = vec_at(scopeid_stack, x0); (% scopeid-id %);
        x2 = map_find(symbol_map, mktup2(x3, x1));
        if (x2 != NULL) { return x2; };
        x0 = x0 - 1;
    };
    return p0;
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
	return find_symbol(p0);
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

init_evaluator: () {
    symbol_map = mkmap(&symbol_hash, &symbol_equal, 100);
    scopeid_stack = mkvec(0);
    scope_push(); (% global scope %);
};

