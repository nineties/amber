(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: object.rl 2010-05-20 03:42:09 nineties $
 %);

include(stddef, code);
export(init_builtin_objects);
export(make_symbol, make_int, make_char, make_string);
export(sym_set, sym_name, sym_value);

nil_obj: NULL;
true_obj: NULL;
false_obj: NULL;

(%
 % symbol object:
 % 0: NODE_SYMBOL
 % 1: symbol name
 % 2: associated object (default: nil symbol)
 %);

make_symbol: (p0) {
    return mktup4(NODE_SYMBOL, strdup(p0), nil_obj);
};

make_int: (p0) {
    return mktup2(NODE_INT, p0);
};

make_char: (p0) {
    return mktup2(NODE_CHAR, p0);
};

make_string: (p0) {
    return mktup2(NODE_STRING, strdup(p0));
};

sym_set: (p0, p1) {
    expect(p0, NODE_SYMBOL, "sym_set", "symbol object");
    p0[2] = p1;
};

sym_name: (p0) {
    expect(p0, NODE_SYMBOL, "sym_name", "symbol object");
    return p0[1];
};

sym_value: (p0) {
    expect(p0, NODE_SYMBOL, "sym_value", "symbol object");
    return p0[2];
};

(% p0: object, p1: expected code, p2: caller name, p3: object name %);
expect: (p0, p1, p2, p3) {
    if (p0 != NULL) {
        if (p0[0] == p1) { return; }
    };
    fputs(stderr, "ERROR: '");
    fputs(stderr, p2);
    fputs(stderr, "': ");
    fputs(stderr, p3);
    fputs(stderr, " is required\n");
    exit(1);
};

init_builtin_objects: () {
    nil_obj   = make_symbol("$nil");
    sym_set(nil_obj, nil_obj);
    true_obj  = make_symbol("$true");
    false_obj = make_symbol("$false");
};
