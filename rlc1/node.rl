(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: node.rl 2010-05-19 04:39:04 nineties $
 %);

include(stddef, code);
export(make_symbol, make_int, make_char, make_string);

make_symbol: (p0) {
    return mktup2(NODE_SYMBOL, strdup(p0));
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
