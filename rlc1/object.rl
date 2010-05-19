(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: node.rl 2010-05-20 03:19:44 nineties $
 %);

include(stddef, code);
export(make_symbol, make_int, make_char, make_string);

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
    return mktup3(NODE_SYMBOL, strdup(p0), nil_obj);
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


