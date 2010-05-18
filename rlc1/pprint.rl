(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: pprint.rl 2010-05-19 04:53:35 nineties $
 %);

include(stddef,code);

export(pp_sexpr);

pp_symbol: (p0, p1) {
    if (p1[0] != NODE_SYMBOL) {
        fputs(stderr, "ERROR 'pp_symbol': not a symbol\n");
        exit(1);
    };
    fputs(p0, p1[1]);
};

pp_int: (p0, p1) {
    if (p1[0] != NODE_INT) {
        fputs(stderr, "ERROR 'pp_int': not an integer\n");
        exit(1);
    };
    fputi(p0, p1[1]);
};

pp_char: (p0, p1) {
    if (p1[0] != NODE_CHAR) {
        fputs(stderr, "ERROR 'pp_char': not a character\n");
        exit(1);
    };
    fputc(p0, p1[1]);
};

pp_string: (p0, p1) {
    if (p1[0] != NODE_STRING) {
        fputs(stderr, "ERROR 'pp_string': not a string\n");
        exit(1);
    };
    fputs(p0, p1[1]);
};

pp_cons: (p0, p1) {
    allocate(1);
    if (p1 != NULL) {
        if (p1[0] != NODE_CONS) {
            fputs(stderr, "ERROR 'pp_cons': not a cons cell\n");
            exit(1);
        };
    };
    fputc(p0, '(');
    x0 = p1;
    while (x0 != NULL) {
        pp_sexpr(p0, x0[1]);
        x0 = x0[2];
        if (x0 != NULL) {
            fputc(p0, ' ');
        }
    };
    fputc(p0, ')');
};

(% p0: output channel, p1: S-expression %);
pp_sexpr: (p0, p1) {
    if (p1 == NULL)           { return pp_cons(p0, p1); };
    if (p1[0] == NODE_CONS)   { return pp_cons(p0, p1) };
    if (p1[0] == NODE_SYMBOL) { return pp_symbol(p0, p1) };
    if (p1[0] == NODE_INT)    { return pp_int(p0, p1) };
    if (p1[0] == NODE_CHAR)   { return pp_char(p0, p1) };
    if (p1[0] == NODE_STRING) { return pp_string(p0, p1) };
    panic("'pp_sexpr': not reachable here");
};
