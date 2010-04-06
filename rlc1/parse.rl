(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: parse.rl 2010-04-06 14:17:12 nineties $
 %);

include(stddef, code, token);

export(parse);

(% p0: file name, input channel %);
parse: (p0, p1) {
    lexer_init(p0, p1);
    return mktup2(NODE_PROG, parse_toplevel_items(lex()));
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
eat: (p0, p1) {
    if (p0 == p1) { return; };
    fputloc(stderr);
    fputs(stderr, ": ERROR: expected ");
    fputc(stderr, ''');
    fputc(stderr, p1);
    fputc(stderr, ''');
    fputc(stderr, '\n');
    exit(1);
};

(% p0: token %);
end_of_item: (p0) {
    if (p0 == ',') { return TRUE; };
    if (p0 == ';') { return TRUE; };
    if (p0 == ')') { return TRUE; };
    if (p0 == ']') { return TRUE; };
    if (p0 == '}') { return TRUE; };
    return FALSE;
};

(% p0: first token %);
parse_toplevel_items: (p0) {
    allocate(2);
    if (p0 == TOK_END) {
        return NULL;
    };
    x0 = parse_toplevel_item(p0);
    x1 = lex();
    if (x1 == ';') {
        return ls_cons(x0, parse_toplevel_items(lex()));
    };
    if (x1 == TOK_END) {
        return ls_singleton(x0);
    };
    expected("';'");
};

(% p0: first token %);
parse_toplevel_item: (p0) {
    if (p0 == TOK_EXPORT) {
        return mktup2(NODE_EXPORT, parse_rewrite_expr(lex()));
    };
    if (p0 == TOK_TYPE) {
        return parse_typedecl_rhsdecl(p0);
    };
    parse_rewrite_expr(p0);
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
        return mktup4(NODE_DECL, NULL, x0, parse_declaration_expr(lex()));
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_command_expr: (p0) {
    allocate(1);
    if (p0 == TOK_RETURN) {
        x0 = lex();
        if (end_of_item(x0)) {
            unput();
            return mktup2(NODE_RET, NULL);
        };
        return mktup3(NODE_RETVAL, NULL, parse_assignment_expr(x0));
    };
    return parse_assignment_expr(p0);
};

(% p0: first token %);
parse_field_expr: (p0) {
    allocate(2);
    x0 = parse_assignment_expr(p0);
    x1 = lex();
    if (x1 == ':') {
        return mktup4(NODE_FIELD, NULL, x0, parse_assignment_expr(lex()));
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_assignment_expr: (p0) {
    allocate(2);
    x0 = parse_seqor_expr(p0);
    x1 = lex();
    if (x1 == '=') {
        return mktup5(NODE_ASSIGN, NULL, BINOP_NONE, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_ADDASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_ADD, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_SUBASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_SUB, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_MULASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_MUL, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_DIVASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_DIV, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_MODASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_MOD, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_ORASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_OR, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_XORASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_XOR, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_ANDASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_AND, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_LSHIFTASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_LSHIFT, x0, parse_assignment_expr(lex()));
    };
    if (x1 == TOK_RSHIFTASGN) {
        return mktup5(NODE_ASSIGN, NULL, BINOP_RSHIFT, x0, parse_assignment_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_SEQOR, x0, parse_seqand_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_SEQAND, x0, parse_or_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_OR, x0, parse_xor_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_XOR, x0, parse_and_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_AND, x0, parse_equality_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_EQ, x0, parse_relational_expr(lex()));
        goto &eq_loop;
    };
    if (x1 == TOK_NE) {
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_NE, x0, parse_relational_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_LT, x0, parse_shift_expr(lex()));
        goto &rel_loop;
    };
    if (x1 == '>') {
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_GT, x0, parse_shift_expr(lex()));
        goto &rel_loop;
    };
    if (x1 == TOK_LE) {
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_LE, x0, parse_shift_expr(lex()));
        goto &rel_loop;
    };
    if (x1 == TOK_GE) {
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_GE, x0, parse_shift_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_LSHIFT, x0, parse_additive_expr(lex()));
        goto &shift_loop;
    };
    if (x1 == TOK_RSHIFT) {
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_RSHIFT, x0, parse_additive_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_ADD, x0, parse_multiplicative_expr(lex()));
        goto &add_loop;
    };
    if (x1 == '-') {
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_SUB, x0, parse_multiplicative_expr(lex()));
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
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_MUL, x0, parse_prefix_expr(lex()));
        goto &mult_loop;
    };
    if (x1 == '/') {
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_DIV, x0, parse_prefix_expr(lex()));
        goto &mult_loop;
    };
    if (x1 == '%') {
        x0 = mktup5(NODE_BINEXPR, NULL, BINOP_MOD, x0, parse_prefix_expr(lex()));
        goto &mult_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_prefix_expr: (p0) {
    if (p0 == '+') {
        return mktup4(NODE_UNEXPR, NULL, UNOP_PLUS, parse_postfix_expr(lex()));
    };
    if (p0 == '-') {
        return mktup4(NODE_UNEXPR, NULL, UNOP_MINUS, parse_postfix_expr(lex()));
    };
    if (p0 == '~') {
        return mktup4(NODE_UNEXPR, NULL, UNOP_INVERSE, parse_postfix_expr(lex()));
    };
    if (p0 == '!') {
        return mktup4(NODE_UNEXPR, NULL, UNOP_NOT, parse_postfix_expr(lex()));
    };
    if (p0 == '&') {
        return mktup4(NODE_UNEXPR, NULL, UNOP_ADDRESSOF, parse_postfix_expr(lex()));
    };
    if (p0 == '*') {
        return mktup4(NODE_UNEXPR, NULL, UNOP_INDIRECT, parse_postfix_expr(lex()));
    };
    if (p0 == TOK_INCR) {
        return mktup4(NODE_UNEXPR, NULL, UNOP_PREINCR, parse_postfix_expr(lex()));
    };
    if (p0 == TOK_DECR) {
        return mktup4(NODE_UNEXPR, NULL, UNOP_PREDECR, parse_postfix_expr(lex()));
    };
    if (p0 == TOK_SYSCALL) {
        return mktup3(NODE_SYSCALL, NULL, parse_tuple(lex()));
    };
    return parse_postfix_expr(p0);
};

(% p0: first token %);
parse_postfix_expr: (p0) {
    allocate(2);
    x0 = parse_primary_item(p0);
label post_loop;
    x1 = lex();
    if (x1 == '(') {
        x0 = mktup4(NODE_CALL, NULL, x0, parse_tuple(x1));
        goto &post_loop;
    };
    if (x1 == '[') {
        x0 = mktup4(NODE_SUBSCRIPT, NULL, x0, parse_array(x1));
        goto &post_loop;
    };
    if (x1 == '{') {
        x0 = mktup4(NODE_LAMBDA, NULL, x0, parse_list(x1));
        goto &post_loop;
    };
    if (x1 == TOK_INCR) {
        x0 = mktup4(NODE_UNEXPR, NULL, UNOP_POSTINCR, x0);
        goto &post_loop;
    };
    if (x1 == TOK_DECR) {
        x0 = mktup4(NODE_UNEXPR, NULL, UNOP_POSTDECR, x0);
        goto &post_loop;
    };
    if (x1 == '.') {
        x1 = parse_identifier(lex());
        x0 = mktup4(NODE_FIELDREF, NULL, x0, get_ident_name(x1));
        goto &post_loop;
    };
    unput();
    return x0;
};

(% p0: first token %);
parse_primary_item: (p0) {
    allocate(2);
    if (p0 == TOK_IDENT) {
        return parse_identifier(p0);
    };
    if (p0 == '(') { return parse_tuple(p0); };
    if (p0 == '[') { return parse_array(p0); };
    if (p0 == '{') { return parse_list(p0); };
    if (p0 == TOK_CHAR) {
        (% character constant is treated as a 32-bit integer %);
        return mktup4(NODE_INTEGER, NULL, 32, token_val());
    };
    if (p0 == TOK_INT) {
        return mktup4(NODE_INTEGER, NULL, 32, token_val());
    };
    if (p0 == TOK_STRING) {
        x0 = strdup(token_text());
        x1 = strlen(x0);
        wch(x0, x1-1, '\0');
        return mktup4(NODE_STRING, NULL, x0+1);
    };
    if (p0 == '_') {
        return mktup2(NODE_DONTCARE, NULL);
    };
    if (p0 == TOK_CONSTR) {
        x0 = strdup(token_text());
        x1 = lex();
        if (x1 == '(') {
            return mktup5(NODE_VARIANT, NULL, x0, 0, parse_tuple(x1));
        };
        unput();
        return mktup5(NODE_VARIANT, NULL, x0, 0, mktup2(NODE_VOID, void_type));
    };
    expected("item");
};

parse_identifier: (p0) {
    if (p0 == TOK_IDENT) {
        return mktup6(NODE_IDENTIFIER, NULL, strdup(token_text()), 0, NULL, FALSE);
    };
    expected("identifier");
};

(% p0: list of items %);
make_tuple_from_list: (p0) {
    allocate(3);
    x1 = ls_length(p0);
    x0 = memalloc(x1 * 4);
    x2 = 0;
    while (p0 != NULL) {
        x0[x2] = ls_value(p0);
        x2 = x2 + 1;
        p0 = ls_next(p0);
    };
    return mktup4(NODE_TUPLE, NULL, x1, x0);
};

(% p0: list of items %);
make_array_from_list: (p0) {
    allocate(3);
    x1 = ls_length(p0);
    x0 = memalloc(x1 * 4);
    x2 = 0;
    while (p0 != NULL) {
        x0[x2] = ls_value(p0);
        x2 = x2 + 1;
        p0 = ls_next(p0);
    };
    return mktup4(NODE_ARRAY, NULL, x1, x0);
};

(% p0: first token %);
parse_tuple: (p0) {
    allocate(2);
    eat(p0, '(');
    x0 = lex();
    if (x0 == ')') {
        return make_tuple_from_list(NULL);
    };
    x1 = parse_comma_list(x0);
    eat(lex(), ')');
    return make_tuple_from_list(x1);
};

(% p0: first token %);
parse_comma_list: (p0) {
    allocate(2);
    x0 = parse_field_expr(p0);
    x1 = lex();
    if (x1 == ',') {
        return ls_cons(x0, parse_comma_list(lex()));
    } else {
        unput();
        return ls_singleton(x0);
    };
};

(% p0: first token %);
parse_array: (p0) {
    allocate(2);
    eat(p0, '[');
    x0 = lex();
    if (x0 == ']') {
        return make_array_from_list(NULL);
    };
    x1 = parse_comma_list(x0);
    eat(lex(), ']');
    return make_array_from_list(x1);
};

(% p0: first token %);
parse_list: (p0) {
    allocate(2);
    eat(p0, '{');
    x0 = lex();
    if (x0 == '}') {
        return mktup3(NODE_CODE, NULL, NULL);
    };
    x1 = parse_semi_list(x0);
    eat(lex(), '}');
    return mktup3(NODE_CODE, NULL, x1);
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
        unput();
        return ls_singleton(x0);
    };
    expected("';' or '}'");
};

(% p0: first token %);
parse_typedecl_rhsdecl: (p0) {
    allocate(2);
    eat(p0, TOK_TYPE);
    x0 = parse_identifier(lex());
    eat(lex(), ':');
    x1 = parse_typedecl_rhs(lex());
    return mktup3(NODE_TYPEDECL, get_ident_name(x0), x1);
};

(% p0: first token %);
parse_typedecl_rhs: (p0) {
    if (p0 == TOK_IDENT) {
        return parse_variant(p0);
    };
    return parse_type(p0);
};

parse_variant: (p0) {
    allocate(1);
    x0 = parse_variant_items(p0);
    return mktup3(NODE_VARIANT_T, NULL, x0);
};

parse_variant_items: (p0) {
    allocate(2);
    x0 = parse_variant_item(p0);
    x1 = lex();
    if (x1 == '|') {
        return ls_cons(x0, parse_variant_items(lex()));
    } else {
        unput();
        return ls_singleton(x0);
    };
};

parse_variant_item: (p0) {
    allocate(2);
    x0 = get_ident_name(parse_identifier(p0));
    add_constr(x0);
    x1 = lex();
    if (x1 == '(') {
        return mktup3(x0, 0, parse_tuple_type(x1));
    };
    unput();
    return mktup3(x0, 0, void_type);
};

parse_type: (p0) {
    if (p0 == TOK_CHAR_T) { return char_type; };
    if (p0 == TOK_INT_T) { return int_type; };
    if (p0 == '(') {
        return parse_tuple_type(p0);
    };
    assert(0);
};

parse_tuple_type: (p0) {
    allocate(1);
    eat(p0, '(');
    x0 = parse_type_list(lex());
    eat(lex(), ')');
    return make_tuple_t_from_list(x0);
};

parse_type_list: (p0) {
    allocate(2);
    x0 = parse_type(p0);
    x1 = lex();
    if (x1 == ',') {
        return ls_cons(x0, parse_type_list(lex()));
    } else {
        unput();
        return ls_singleton(x0);
    };
};

make_tuple_t_from_list: (p0) {
    allocate(3);
    x0 = ls_length(p0);
    x1 = memalloc(x0 * 4);
    x2 = 0;
    while (p0 != NULL) {
        x1[x2] = ls_value(p0);
        x2 = x2 + 1;
        p0 = ls_next(p0);
    };
    return mktup3(NODE_TUPLE_T, x0, x1);
};
