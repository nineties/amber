(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: parse.rl 2010-02-27 16:05:50 nineties $ 
 %);

include(stddef, code, token);

export(parse);

(% p0: file name, input channel %);
parse: (p0, p1) {
    lexer_init(p0, p1);
    return mktup2(NODE_PROG, ls_cons(parse_primary_item(lex()), NULL));
    (% return mktup2(NODE_PROG, parse_semi_list(lex())); %);
};

(% p0: name of expected token %);
expected: (p0) {
    fputloc(stderr);
    fputs(stderr, ": ERROR: expected ");
    fputs(stderr, p0);
    fputc(stderr, '\n');
    exit(1);
};

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

(% p0: first token %);
parse_item: (p0) {
    return parse_rewrite_expr(p0);
};


(% p0: first token %);
parse_rewrite_expr: (p0) {
    allocate(2);
    x0 = parse_declaration_expr(p0);
    x1 = lex();
    if (x1 == TOK_REWRITE) {
        return mktup3(NODE_REWRITE, x0, parse_rewrite_expr(lex()));
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_declaration_expr: (p0) {
    allocate(2);
    x0 = parse_command_expr(p0);
    x1 = lex();
    if (x1 == ':') {
        return mktup5(NODE_PAT, ":", 2, x0, parse_declaration_expr(lex()));
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_command_expr: (p0) {
    allocate(2);
    return parse_assignment_expr(p0);
    if (p0 != TOK_COMMAND) {
        return parse_assignment_expr(p0);
    };
    x0 = token_val();
    x1 = lex();
    if (x1 == ',') {
        unput();
        return mktup5(NODE_PAT, x0, 0);
    };
    if (x1 == ';') {
        unput();
        return mktup5(NODE_PAT, x0, 0);
    };
    if (x1 == ')') {
        unput();
        return mktup5(NODE_PAT, x0, 0);
    };
    if (x1 == ']') {
        unput();
        return mktup5(NODE_PAT, x0, 0);
    };
    if (x1 == '}') {
        unput();
        return mktup5(NODE_PAT, x0, 0);
    };
    return mktup5(NODE_PAT, x0, 1, parse_assignment_expr(x1));
};

(% p0: first token %);
parse_assignment_expr: (p0) {
    allocate(2);
    x0 = parse_seqor_expr(p0);
    x1 = lex();
    if (x1 == '=') {
        return mktup5(NODE_PAT, "=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_ADDASGN) {
        return mktup5(NODE_PAT, "+=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_SUBASGN) {
        return mktup5(NODE_PAT, "-=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_MULASGN) {
        return mktup5(NODE_PAT, "*=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_DIVASGN) {
        return mktup5(NODE_PAT, "/=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_MODASGN) {
        return mktup5(NODE_PAT, "%=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_ORASGN) {
        return mktup5(NODE_PAT, "|=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_XORASGN) {
        return mktup5(NODE_PAT, "^=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_ANDASGN) {
        return mktup5(NODE_PAT, "&=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_LSHIFTASGN) {
        return mktup5(NODE_PAT, "<<=", 2, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_RSHIFTASGN) {
        return mktup5(NODE_PAT, ">>=", 2, x0, parse_assignment_expr(lex()));
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_seqor_expr: (p0) {
    allocate(2);
    x0 = parse_seqand_expr(p0);
label seqor_loop;
    x1 = lex();
    if (x1 == TOK_SEQOR) {
        x0 = mktup5(NODE_PAT, "||", 2, x0, parse_seqand_expr(lex()));
        goto &seqor_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_seqand_expr: (p0) {
    allocate(2);
    x0 = parse_or_expr(p0);
label seqand_loop;
    x1 = lex();
    if (x1 == TOK_SEQAND) {
        x0 = mktup5(NODE_PAT, "&&", 2, x0, parse_or_expr(lex()));
        goto &seqand_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_or_expr: (p0) {
    allocate(2);
    x0 = parse_xor_expr(p0);
label or_loop;
    x1 = lex();
    if (x1 == '|') {
        x0 = mktup5(NODE_PAT, "|", 2, x0, parse_xor_expr(lex()));
        goto &or_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_xor_expr: (p0) {
    allocate(2);
    x0 = parse_and_expr(p0);
label xor_loop;
    x1 = lex();
    if (x1 == '^') {
        x0 = mktup5(NODE_PAT, "^", 2, x0, parse_and_expr(lex()));
        goto &xor_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_and_expr: (p0) {
    allocate(2);
    x0 = parse_equality_expr(p0);
label and_loop;
    x1 = lex();
    if (x1 == '&') {
        x0 = mktup5(NODE_PAT, "&", 2, x0, parse_equality_expr(lex()));
        goto &and_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_equality_expr: (p0) {
    allocate(2);
    x0 = parse_relational_expr(p0);
label eq_loop;
    x1 = lex();
    if (x1 == TOK_EQ) {
        x0 = mktup5(NODE_PAT, "==", 2, x0, parse_relational_expr(lex()));
        goto &eq_loop;
    };
    if (x1 == TOK_NE) {
        x0 = mktup5(NODE_PAT, "!=", 2, x0, parse_relational_expr(lex()));
        goto &eq_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_relational_expr: (p0) {
    allocate(2);
    x0 = parse_shift_expr(p0);
label rel_loop;
    x1 = lex();
    if (x1 == '<') {
        x0 = mktup5(NODE_PAT, "<", 2, x0, parse_shift_expr(lex()));
        goto &rel_loop;
    };
    if (x1 == '>') {
        x0 = mktup5(NODE_PAT, ">", 2, x0, parse_shift_expr(lex()));
        goto &rel_loop;
    };
    if (x1 == TOK_LE) {
        x0 = mktup5(NODE_PAT, "<=", 2, x0, parse_shift_expr(lex()));
        goto &rel_loop;
    };
    if (x1 == TOK_GE) {
        x0 = mktup5(NODE_PAT, ">=", 2, x0, parse_shift_expr(lex()));
        goto &rel_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_shift_expr: (p0) {
    allocate(2);
    x0 = parse_additive_expr(p0);
label shift_loop;
    x1 = lex();
    if (x1 == TOK_LSHIFT) {
        x0 = mktup5(NODE_PAT, "<<", 2, x0, parse_additive_expr(lex()));
        goto &shift_loop;
    };
    if (x1 == TOK_RSHIFT) {
        x0 = mktup5(NODE_PAT, ">>", 2, x0, parse_additive_expr(lex()));
        goto &shift_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_additive_expr: (p0) {
    allocate(2);
    x0 = parse_multiplicative_expr(p0);
label add_loop;
    x1 = lex();
    if (x1 == '+') {
        x0 = mktup5(NODE_PAT, "+", 2, x0, parse_multiplicative_expr(lex()));
        goto &add_loop;
    };
    if (x1 == '-') {
        x0 = mktup5(NODE_PAT, "-", 2, x0, parse_multiplicative_expr(lex()));
        goto &add_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_multiplicative_expr: (p0) {
    allocate(2);
    x0 = parse_prefix_expr(p0);
label mult_loop;
    x1 = lex();
    if (x1 == '*') {
        x0 = mktup5(NODE_PAT, "*", 2, x0, parse_prefix_expr(lex()));
        goto &mult_loop;
    };
    if (x1 == '/') {
        x0 = mktup5(NODE_PAT, "/", 2, x0, parse_prefix_expr(lex()));
        goto &mult_loop;
    };
    if (x1 == '%') {
        x0 = mktup5(NODE_PAT, "%", 2, x0, parse_prefix_expr(lex()));
        goto &mult_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_prefix_expr: (p0) {
    if (p0 == '+') { return mktup4(NODE_PAT, "pre+", 1, parse_else_expr(lex())); };
    if (p0 == '-') { return mktup4(NODE_PAT, "pre-", 1, parse_else_expr(lex())); };
    if (p0 == '~') { return mktup4(NODE_PAT, "pre~", 1, parse_else_expr(lex())); };
    if (p0 == '!') { return mktup4(NODE_PAT, "pre!", 1, parse_else_expr(lex())); };
    if (p0 == '&') { return mktup4(NODE_PAT, "pre&", 1, parse_else_expr(lex())); };
    if (p0 == '*') { return mktup4(NODE_PAT, "pre*", 1, parse_else_expr(lex())); };
    if (p0 == '#') { return mktup2(NODE_EVAL, parse_else_expr(lex())); };
    if (p0 == TOK_INCR) {
        return mktup4(NODE_PAT, "pre++", 1, parse_else_expr(lex()));
    };
    if (p0 == TOK_DECR) {
        return mktup4(NODE_PAT, "pre--", 1, parse_else_expr(lex()));
    };
    return parse_else_expr(p0);
};

parse_else_expr: (p0) {
    allocate(2);
    x0 = parse_postfix_expr(p0);
    x1 = lex();
    if (x1 == TOK_ELSE) {
        return mktup5(NODE_PAT, "else", 2, x0, parse_else_expr(lex()));
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_postfix_expr: (p0) {
    allocate(2);
    x0 = parse_primary_item(p0);
label post_loop;
    x1 = lex();
    if (x1 == '(') {
        x0 = mktup5(NODE_PAT, "()", 2, x0, parse_tuple(x1));
        goto &post_loop;
    };
    if (x1 == '[') {
        x0 = mktup5(NODE_PAT, "[]", 2, x0, parse_array(x1));
        goto &post_loop;
    };
    if (x1 == '{') {
        x0 = mktup5(NODE_PAT, "{}", 2, x0, parse_list(x1));
        goto &post_loop;
    };
    if (x1 == TOK_INCR) {
        x0 = mktup3(NODE_PAT, "post++", 1, x0);
        goto &post_loop;
    };
    if (x1 == TOK_DECR) {
        x0 = mktup3(NODE_PAT, "post--", 1, x0);
        goto &post_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_primary_item: (p0) {
    if (p0 == TOK_IDENT) {
        return mktup4(NODE_PAT, strdup(token_text()), 0, NULL);
    };
    if (p0 == '(') { return parse_tuple(p0); };
    if (p0 == '[') { return parse_array(p0); };
    if (p0 == '{') { return parse_list(p0); };
    if (p0 == TOK_INT) {
        return mktup3(NODE_INTEGER, NULL, token_val());
    };
    if (p0 == TOK_STRING) {
        return mktup4(NODE_STRING, NULL, strdup(token_text()), FALSE);
    };
    if (p0 == TOK_COMMENT) {
        return mktup4(NODE_STRING, NULL, strdup(token_text()), TRUE);
    };
    expected("item");
};

(% p0: list of items %);
make_tuple_from_list: (p0) {
    allocate(3);
    if (p0 == NULL) {
        return mktup5(NODE_TUPLE, NULL, 0, NULL);
    };
    x1 = ls_length(p0);
    x0 = memalloc(x1 * 4);
    x2 = 0;
    while (p0 != NULL) {
        x0[x2] = ls_value(p0);
        x2 = x2 + 1;
        p0 = ls_next(p0);
    };
    return mktup5(NODE_TUPLE, NULL, x1, x0);
};

(% p0: list of items %);
make_array_from_list: (p0) {
    allocate(3);
    if (p0 == NULL) {
        return mktup5(NODE_ARRAY, NULL, 0, NULL);
    };
    x1 = ls_length(p0);
    x0 = memalloc(x1 * 4);
    x2 = 0;
    while (p0 != NULL) {
        x0[x2] = ls_value(p0);
        x2 = x2 + 1;
        p0 = ls_next(p0);
    };
    return mktup5(NODE_ARRAY, NULL, x1, x0);
};

(% p0: first token %);
parse_tuple: (p0) {
    allocate(2);
    eatchar(p0, '(');
    x0 = lex();
    if (x0 == ')') {
        return make_tuple_from_list(NULL);
    };
    x1 = parse_comma_list(x0);
    eatchar(lex(), ')');
    return make_tuple_from_list(x1);
};

(% p0: first token %);
parse_comma_list: (p0) {
    allocate(2);
    x0 = parse_item(p0);
    x1 = lex();
    if (x1 == ',') {
        return ls_cons(x0, parse_comma_list(lex()));
    } else {
        unput();
        return ls_cons(x0, NULL);
    };
};

(% p0: first token %);
parse_array: (p0) {
    allocate(2);
    eatchar(p0, '[');
    x0 = lex();
    if (x0 == ']') {
        return make_array_from_list(NULL);
    };
    x1 = parse_comma_list(x0);
    eatchar(lex(), ']');
    return make_array_from_list(x1);
};

(% p0: first token %);
parse_list: (p0) {
    allocate(2);
    eatchar(p0, '{');
    x0 = lex();
    if (x0 == '}') {
        return mktup3(NODE_BLOCK, NULL, NULL);
    };
    x1 = parse_semi_list(x0);
    eatchar(lex(), '}');
    return mktup3(NODE_BLOCK, NULL, x1);
};

(% p0: first token %);
parse_semi_list: (p0) {
    allocate(2);
    if (p0 == '}') {
        unput();
        return NULL;
    };
    if (p0 == TOK_END) {
        unput();
        return NULL;
    };
    x0 = parse_item(p0);
    x1 = lex();
    if (x1 == ';') {
        return ls_cons(x0, parse_semi_list(lex()));
    };
    if (x1 == '}') {
        return ls_cons(x0, NULL);
    };
    expected("';' or '}'");
};
