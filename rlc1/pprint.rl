(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: pprint.rl 2010-05-26 18:58:39 nineties $
 %);

include(stddef,code);

export(pp_sexp);

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
    if (p1[0] != NODE_CONS) {
        fputs(stderr, "ERROR 'pp_cons': not a cons cell\n");
        exit(1);
    };
    fputc(p0, '(');
    x0 = p1;
    while (x0 != nil_sym) {
        pp_sexp(p0, car(x0));
        x0 = cdr(x0);
        if (x0 != nil_sym) {
            fputc(p0, ' ');
        }
    };
    fputc(p0, ')');
};

(% p0: output channel, p1: S-expression %);
pp_sexp: (p0, p1) {
    if (p1[0] == NODE_CONS)    { return pp_cons(p0, p1) };
    if (p1[0] == NODE_SYMBOL)  { return pp_symbol(p0, p1) };
    if (p1[0] == NODE_INT)     { return pp_int(p0, p1) };
    if (p1[0] == NODE_CHAR)    { return pp_char(p0, p1) };
    if (p1[0] == NODE_STRING)  { return pp_string(p0, p1) };
    if (p1[0] == NODE_QUOTE)   { fputc(p0, '`'); return pp_sexp(p0, quote_sexp(p1)); };
    if (p1[0] == NODE_UNQUOTE) { fputc(p0, '@'); return pp_sexp(p0, unquote_sexp(p1)); };
    panic("'pp_sexp': not reachable here");
};
