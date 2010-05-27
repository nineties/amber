(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: parse.rl 2010-05-27 13:46:43 nineties $
 %);

include(stddef, code, token);

export(parse, parse_module);

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

escaped_char: (p0) {
    if (p0 == '0') { return 0; };
    if (p0 == 'a') { return 7; };
    if (p0 == 'b') { return 8; };
    if (p0 == 't') { return 9; };
    if (p0 == 'n') { return 10; };
    if (p0 == 'v') { return 11; };
    if (p0 == 'f') { return 12; };
    if (p0 == 'r') { return 13; };
    return p0;
};

unescape: (p0) {
    allocate(4);
    x0 = strlen(p0)-2;
    p0 = p0 + 1; (% skip first " %);
    x1 = memalloc(x0+1);
    x2 = 0;
    while (rch(p0,0) != '"') {
        x3 = rch(p0, 0);
        if (x3 == '\\') {
            p0 = p0 + 1;
            x3 = escaped_char(rch(p0, 0));
        };
        wch(x1, x2, x3);
        x2 = x2 + 1;
        p0 = p0 + 1;
    };
    wch(x1,x2,'\0');
    return x1;
};

parse_sexp: (p0) {
    allocate(3);
    if (p0 == '`') {
	return mkquote(parse_sexp(lex()));
    };
    if (p0 == '@') {
	return mkunquote(parse_sexp(lex()));
    };
    if (p0 == '(') {
        x0 = parse_list_body(lex());
        eatchar(')',lex());
        return x0;
    };
    if (p0 == TOK_CHAR) {
        return mkchar(token_val());
    };
    if (p0 == TOK_INT) {
        return mkint(token_val());
    };
    if (p0 == TOK_STRING) {
        x0 = unescape(token_text());
        return mkstring(x0);
    };
    if (p0 == TOK_SYMBOL) {
        return mksym(token_text());
    };
label parse_err;
    fputloc(stderr);
    fputs(stderr, ": ERROR: parse error\n");
    exit(1);
};

parse_list_body: (p0) {
    allocate(2);
    if (p0 == TOK_END) {
        return nil_sym;
    };
    if (p0 == ')') {
        unput();
        return nil_sym;
    };
    if (p0 == '.') {
        return parse_sexp(lex());
    };
    x0 = parse_sexp(p0);
    x1 = parse_list_body(lex());
    return mkcons(x0,x1);
};

parse_sexp_list: (p0) {
    allocate(2);
    if (p0 == TOK_END) {
        return nil_sym;
    };
    x0 = parse_sexp(p0);
    x1 = parse_sexp_list(lex());
    return mkcons(x0, x1);
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

(% p0: module name %);
parse_module: (p0) {
    allocate(4);
    x0 = strlen(p0);
    x1 = memalloc(x0 + 4 + 1); (% +4 for suffix '.rlc' %);
    strcpy(x1, p0);
    strcpy(x1 + x0, ".rlc");
    x2 = open_in(x1);
    lexer_push(x1, x2);
    x3 = parse_sexp_list(lex());
    close_in(x2);
    return x3;
};
