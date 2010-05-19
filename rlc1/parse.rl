(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: parse.rl 2010-05-19 04:53:08 nineties $
 %);

include(stddef, code, token);

export(parse);

(% p0: character, p1: expected character %);
eatchar: (p0, p1) {
    if (p0 == p1) { return; };
    fputloc(stderr);
    fputs(stderr, ": ERROR: expected ");
    fputc(stderr, ''');
    fputc(stderr, p1);
    fputc(stderr, ''');
    fputc(stderr, '\n');
    exit(1);
};

parse_sexp: (p0) {
    allocate(3);
    if (p0 == '(') {
        x0 = NULL;
        while(1) {
            x1 = lex();
            if (x1 == TOK_END) {
                goto &parse_sexp;
            };
            if (x1 == ')') {
                return rl_reverse(x0);
            };
            x0 = rl_cons(parse_sexp(x1), x0);
        }
    };
    if (p0 == TOK_CHAR) {
        return make_char(token_val());
    };
    if (p0 == TOK_INT) {
        return make_int(token_val());
    };
    if (p0 == TOK_STRING) {
        return make_string(token_text());
    };
    if (p0 == TOK_SYMBOL) {
        return make_symbol(token_text());
    };
label parse_err;
    fputloc(stderr);
    fputs(stderr, ": ERROR: parse error\n");
    exit(1);
};

parse_sexp_list: (p0) {
    allocate(2);
    if (p0 == TOK_END) {
        return NULL;
    };
    x0 = parse_sexp(p0);
    x1 = parse_sexp_list(lex());
    return rl_cons(x0, x1);
};

(% p0: file name %);
parse: (p0) {
    allocate(2);
    x0 = open_in(p0);
    lexer_init(p0, x0);
    x1 = parse_sexp_list(lex());
    close_in(x0);
    return x1;
};
