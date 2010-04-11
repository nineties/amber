(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: closure.rl 2010-04-11 10:23:57 nineties $
 %);

(% closure conversion %);

include (stddef, code);
export (closure_conversion);

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

cmap: NULL; (% identifier-id to item %);
fmap: NULL; (% identifier-id to label or NULL %);
closed: NULL; (% closed closure labels %);

remove_vars: (p0, p1) {
    allocate(3);
    if (p1[0] == NODE_IDENTIFIER) { return iset_del(p0, p1[3]); };
    if (p1[0] == NODE_DONTCARE) { return p0; };
    if (p1[0] == NODE_UNIT) { return p0; };
    if (p1[0] == NODE_TUPLE) {
        x0 = p1[TUPLE_LENGTH];
        x1 = p1[TUPLE_ELEMENTS];
        x2 = 0;
        while (x2 < x0) {
            p0 = remove_vars(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return p0;
    };
    if (p1[0] == NODE_TYPEDEXPR) { return remove_vars(p0, p1[2]); };
    not_reachable();
};

iterate_block_impl: (p0, p1) {
    if (p1 == NULL) { return p0; };
    p0 = iterate_block_impl(p0, ls_next(p1));
    return iterate(p0, ls_value(p1));
};

iterate: (p0, p1) {
    allocate(3);
    if (p1[0] == NODE_IDENTIFIER) {
        if (p1[5] == FALSE) {
            (% it is a local free variable %);
            p0 = iset_add(p0, p1[3]);
        };
        return p0;
    };
    if (p1[0] == NODE_ARRAY) {
        x0 = p1[ARRAY_LENGTH];
        x1 = p1[ARRAY_ELEMENTS];
        x2 = 0;
        while (x2 < x0) {
            p0 = iterate(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return p0;
    };
    if (p1[0] == NODE_TUPLE) {
        x0 = p1[ARRAY_LENGTH];
        x1 = p1[ARRAY_ELEMENTS];
        x2 = 0;
        while (x2 < x0) {
            p0 = iterate(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return p0;
    };
    if (p1[0] == NODE_BLOCK) {
        (% must iterate in reversed order %);
        return iterate_block_impl(p0, p1[BLOCK_STATEMENTS]);
    };
    if (p1[0] == NODE_DECL) {
        p0 = iterate(p0, p1[3]);
        return remove_vars(p0, p1[2]);
    };
    if (p1[0] == NODE_CALL) {
        p0 = iterate(p0, p1[2]);
        p0 = iterate(p0, p1[3]);
        return p0;
    };
    if (p1[0] == NODE_SUBSCRIPT) {
        p0 = iterate(p0, p1[2]);
        p0 = iterate(p0, p1[3]);
        return p0;
    };
    if (p1[0] == NODE_LAMBDA) {
        p0 = iterate(p0, p1[3]);
        return remove_vars(p0, p1[2]);
    };
    if (p1[0] == NODE_UNEXPR) { return iterate(p0, p1[3]); };
    if (p1[0] == NODE_BINEXPR) {
        p0 = iterate(p0, p1[3]);
        p0 = iterate(p0, p1[4]);
        return p0;
    };
    if (p1[0] == NODE_ASSIGN) {
        p0 = iterate(p0, p1[3]);
        p0 = iterate(p0, p1[4]);
        return p0;
    };
    if (p1[0] == NODE_RETVAL)    { return iterate(p0, p1[2]); };
    if (p1[0] == NODE_SYSCALL)   { return iterate(p0, p1[2]); };
    if (p1[0] == NODE_FIELD)     { return iterate(p0, p1[2]); };
    if (p1[0] == NODE_FIELDREF)  { return iterate(p0, p1[2]); };
    if (p1[0] == NODE_VARIANT)   {
        if (p1[4] != NULL) { return iterate(p0, p1[4]); };
        return p0;
    };
    if (p1[0] == NODE_TYPEDEXPR) { return iterate(p0, p1[2]); };
    if (p1[0] == NODE_IF) {
        p0 = iterate(p0, p1[2]);
        p0 = iterate(p0, p1[3]);
        return p0;
    };
    if (p1[0] == NODE_IFELSE) {
        p0 = iterate(p0, p1[2]);
        p0 = iterate(p0, p1[3]);
        p0 = iterate(p0, p1[4]);
        return p0;
    };
    return mkiset();
};

(% p0: item %);
free_variable: (p0) {
    return iterate(mkiset(), p0);
};

tuple_t_pushback: (p0, p1) {
    allocate(3);
    x0 = p0[TUPLE_T_LENGTH];
    x1 = p0[TUPLE_T_ELEMENTS];
    x2 = memalloc(4*(x0+1));
    memcpy(x2, x1, 4*x0);
    x2[x0] = p1;
    p0[TUPLE_T_LENGTH] = (x0 + 1);
    p0[TUPLE_T_ELEMENTS] = x2;
};

tuple_pushback: (p0, p1) {
    allocate(3);
    if (p0[0] == NODE_UNIT) {
        return mktup4(NODE_TUPLE,
            mktup3(NODE_TUPLE_T, 1, mktup1(p1[1])),
            1,
            mktup1(p1));
    };
    tuple_t_pushback(p0[1], p1[1]);
    x0 = p0[TUPLE_LENGTH];
    x1 = p0[TUPLE_ELEMENTS];
    x2 = memalloc(4*(x0+1));
    memcpy(x2, x1, 4*x0);
    x2[x0] = p1;
    p0[TUPLE_LENGTH] = (x0+1);
    p0[TUPLE_ELEMENTS] = x2;
    return p0;
};

(% p0: pointer to env, p1: free variables %);
build_closure_env: (p0, p1) {
    allocate(3);
    if (p1 == NULL) { return; };
    x2 = 1;
    while (p1 != NULL) {
        x1 = vec_at(vartable, ls_value(p1));
        assert(x1 != NULL);
        map_add(cmap, x1[3], mktup4(NODE_SUBSCRIPT, int_type, x0,
            mktup4(NODE_INTEGER, int_type, 32, x2)));
        x2 = x2 + 1;
        p1 = ls_next(p1);
    };
};

(% p0: function ident, p1: lambda, p2: free variables %);
close_function_impl: (p0, p1, p2) {
    allocate(3);
    x0 = mktup2(NODE_ARRAY_T, int_type);
    x1 = mktup6(NODE_IDENTIFIER, x0, strdup("closure0"), 0, mktyscheme(x0), FALSE);
    set_varid(x1);
    build_closure_env(x1, p2);
    map_add(cmap, x1[3], mktup4(NODE_SUBSCRIPT, int_type, x1,
            mktup4(NODE_INTEGER, int_type, 32, 0)));
    map_add(fmap, x1[3], x1);
    p1[3] = (close(p1[3]))[0];
    map_del(fmap, x1[3]);
    map_del(cmap, x1[3]);
    while (p2 != NULL) {
        map_del(cmap, ls_value(p2));
        p2 = ls_next(p2);
    };

    if (occur(x1, p1[3])) {
        (% build new parameter %);
        p1[2] = tuple_pushback(p1[2], x1);
        return;
    };
    closed = iset_add(closed, p0[3]);
    return;
};

(% p0: function ident, p1: lambda %);
close_function: (p0, p1) {
    allocate(5);
    (% determine the free variables of the lambda %);
    x1 = free_variable(p1);
    x1 = iset_del(x1, p0[3]);

    close_function_impl(p0, p1, x1);
    x2 = NULL;
    while (x1 != NULL) {
        x2 = ls_cons((close_identifier(vec_at(vartable, ls_value(x1))))[0], x2);
        x1 = ls_next(x1);
    };
    x2 = ls_reverse(x2);
    p1[5] = x2; (% free variables %);
    p1[4] = p0;
    return mktup2(p1, p0);
};

close_funcs: [ not_reachable, do_nothing, do_nothing, do_nothing, close_identifier,
not_implemented, close_tuple, close_block, close_decl, close_call, do_nothing,
close_lambda, close_unexpr, close_binexpr, close_assign, close_export, do_nothing,
close_external, do_nothing, close_retval, close_syscall, close_field, close_fieldref,
do_nothing, close_variant, do_nothing, close_typedexpr, close_if, close_ifelse, do_nothing,
do_nothing, close_new, close_while, close_for, close_newarray
];

do_nothing: (p0) {
    return mktup2(p0, NULL);
};

close_identifier: (p0) {
    allocate(2);
    if (p0[5]) {
        (% global identifier %);
        return mktup2(p0, p00);
    };
    x0 = map_find(cmap, p0[3]);
    if (x0 == NULL) { x0 = p0; };
    x1 = map_find(fmap, p0[3]);
    return mktup2(x0, x1);
};

close_tuple: (p0) {
    allocate(3);
    x0 = p0[TUPLE_LENGTH];
    x1 = p0[TUPLE_ELEMENTS];
    x2 = 0;
    while (x2 < x0) {
        x1[x2] = (close(x1[x2]))[0];
        x2 = x2 + 1;
    };
    return mktup2(p0, NULL);
};

close_block: (p0) {
    allocate(1);
    x0 = p0[BLOCK_STATEMENTS];
    while (x0 != NULL) {
        ls_set(x0, (close(ls_value(x0)))[0]);
        x0 = ls_next(x0);
    };
    return mktup2(p0, NULL);
};

close_fundecl: (p0) {
    allocate(6);
    x0 = p0[2]; (% identifier %);
    x1 = p0[3]; (% lambda %);
    if (x0[5] == TRUE) {
        (% global functions are already closed %);
        iset_add(closed, x0[3]);
        return mktup2(p0, x0);
    };
    x2 = close_function(x0, x1); (% new lambda, id %);
    map_add(fmap, x0[3], x2[1]);
    x1[3] = (close(x1[3]))[0];
    x3 = mkmap(&simple_hash, &simple_equal, 0);
    x4 = mktup2(NODE_ARRAY_T, int_type);
    x5 = mktup6(NODE_IDENTIFIER, x4, get_ident_name(x0), 0, mktyscheme(x4), TRUE);
    set_varid(x5);
    map_add(x3, x2[1][3], mktup4(NODE_SUBSCRIPT, int_type, x5,
        mktup4(NODE_INTEGER, int_type, 32, 0)));
    x1[3] = substitute(x3, x1[3]);
    p0[2] = x5;
    map_del(x3, x2[1][3]);
    return mktup2(p0, x2[1]);
};

close_decl: (p0) {
    allocate(3);
    x0 = p0[2]; (% lhs %);
    x1 = p0[3]; (% rhs %);
    if (x0[0] != NODE_IDENTIFIER) {
        not_implemented();
        exit(1);
    };
    if (x1[0] == NODE_LAMBDA) {
        return close_fundecl(p0);
    };
    x2 = close(x1);
    map_add(fmap, x0[3], x2[1]);
    p0[3] = x2[0];
    return mktup2(p0, NULL);
};

close_call: (p0) {
    allocate(4);
    x0 = p0[2]; (% fun %);
    x1 = p0[3]; (% arguments %);
    x2 = close(x0);
    if (x2[1] == NULL) {
        (% closure call %);
        p0[4] = TRUE;
        return mktup2(p0, NULL);
    };
    p0[4] = FALSE;
    if (iset_contains(closed, x2[1][3])) {
        return mktup2(p0, NULL);
    };
    x3 = (close(x1))[0];
    x1 = tuple_pushback(x1, x2[0]);
    p0[3] = x1;
    return mktup2(p0, NULL);
};

close_lambda: (p0) {
    allocate(3);
    if (p0[4] != NULL) {
        return mktup2(p0, p0[4]);
    };
    x0 = mktup2(NODE_ARRAY_T, int_type);
    x1 = mktup6(NODE_IDENTIFIER, x0, strdup("closure2"), 0, mktyscheme(x0), FALSE);
    set_varid(x1);
    x2 = close_function(x1, p0);
    return x2;
};

close_unexpr: (p0) {
    p0[3] = (close(p0[3]))[0];
    return mktup2(p0, NULL);
};

close_binexpr: (p0) {
    p0[3] = (close(p0[3]))[0];
    p0[4] = (close(p0[4]))[0];
    return mktup2(p0, NULL);
};

close_assign: (p0) {
    p0[4] = (close(p0[4]))[0];
    return mktup2(p0, NULL);
};

close_export: (p0) {
    p0[1] = (close(p0[1]))[0];
    return mktup2(p0, NULL);
};

close_external: (p0) {
    allocate(1);
    x0 = p0[1]; (% ident %);
    map_add(fmap, x0[3], x0);
    closed = iset_add(closed, x0[3]);
    return mktup2(p0, NULL);
};

close_retval: (p0) {
    p0[2] = (close(p0[2]))[0];
    return mktup2(p0, NULL);
};

close_syscall: (p0) {
    p0[2] = (close(p0[2]))[0];
    return mktup2(p0, NULL);
};

close_field: (p0) {
    p0[3] = (close(p0[3]))[0];
    return mktup2(p0, NULL);
};

close_fieldref: (p0) {
    p0[2] = (close(p0[2]))[0];
    return mktup2(p0, NULL);
};

close_variant: (p0) {
    if (p0[4] != NULL) {
        p0[4] = (close(p0[4]))[0];
    };
    return mktup2(p0, NULL);
};

close_typedexpr: (p0) {
    p0[2] = (close(p0[2]))[0];
    return mktup2(p0, NULL);
};

close_if: (p0) {
    p0[2] = (close(p0[2]))[0];
    p0[3] = (close(p0[3]))[0];
    return mktup2(p0, NULL);
};

close_ifelse: (p0) {
    p0[2] = (close(p0[2]))[0];
    p0[3] = (close(p0[3]))[0];
    p0[4] = (close(p0[4]))[0];
    return mktup2(p0, NULL);
};

close_new: (p0) {
    p0[2] = (close(p0[2]))[0];
    return mktup2(p0, NULL);
};

close_while: (p0) {
    p0[2] = (close(p0[2]))[0];
    p0[3] = (close(p0[3]))[0];
    return mktup2(p0, NULL);
};

close_for: (p0) {
    p0[2] = (close(p0[2]))[0];
    p0[3] = (close(p0[3]))[0];
    p0[4] = (close(p0[4]))[0];
    p0[5] = (close(p0[5]))[0];
    return mktup2(p0, NULL);
};

close_newarray: (p0) {
    p0[2] = (close(p0[2]))[0];
    p0[3] = (close(p0[3]))[0];
    return mktup2(p0, NULL);
};
close: (p0) {
    return (close_funcs[p0[0]])(p0);
};

substitute: (p0, p1) {
    allocate(3);
    if (p1[0] == NODE_IDENTIFIER) {
        x0 = map_find(p0, p1[3]);
        if (x0 != NULL) { return x0 };
        return p1;
    };
    if (p1[0] == NODE_ARRAY) {
        x0 = p1[ARRAY_LENGTH];
        x1 = p1[ARRAY_ELEMENTS];
        x2 = 0;
        while (x2 < x0) {
            x1[x2] = substitute(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return p1;
    };
    if (p1[0] == NODE_TUPLE) {
        x0 = p1[TUPLE_LENGTH];
        x1 = p1[TUPLE_ELEMENTS];
        x2 = 0;
        while (x2 < x0) {
            x1[x2] = substitute(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return p1;
    };
    if (p1[0] == NODE_BLOCK) {
        x0 = p1[BLOCK_STATEMENTS];
        while (x0 != NULL) {
            ls_set(x0, substitute(p0, ls_value(x0)));
            x0 = ls_next(x0);
        };
        return p1;
    };
    if (p1[0] == NODE_DECL) {
        if (p1[2][0] != NODE_IDENTIFIER) {
            fputs(stderr, "ERROR: not implemented (substitute)\n");
            exit(1);
        };
        x0 = p1[2];
        x1 = mktup6(x0[0], x0[1], x0[2], x0[3], x0[4], x0[5]);
        set_varid(x1);
        p1[2] = x1;
        p1[3] = substitute(p0, p1[3]);
        map_add(p0, x0[3], x1);
        return p1;
    };
    if (p1[0] == NODE_CALL) {
        p1[2] = substitute(p0, p1[2]);
        p1[3] = substitute(p0, p1[3]);
        return p1;
    };
    if (p1[0] == NODE_SUBSCRIPT) {
        p1[2] = substitute(p0, p1[2]);
        p1[3] = substitute(p0, p1[3]);
        return p1;
    };
    if (p1[0] == NODE_LAMBDA) {
        p1[2] = substitute(p0, p1[2]);
        p1[3] = substitute(p0, p1[3]);
        return p1;
    };
    if (p1[0] == NODE_UNEXPR) {
        p1[3] = substitute(p0, p1[3]);
        return p1;
    };
    if (p1[0] == NODE_BINEXPR) {
        p1[3] = substitute(p0, p1[3]);
        p1[4] = substitute(p0, p1[4]);
        return p1;
    };
    if (p1[0] == NODE_ASSIGN) {
        p1[3] = substitute(p0, p1[3]);
        p1[4] = substitute(p0, p1[4]);
        return p1;
    };
    if (p1[0] == NODE_RETVAL) {
        p1[2] = substitute(p0, p1[2]);
        return p1;
    };
    if (p1[0] == NODE_SYSCALL) {
        p1[2] = substitute(p0, p1[2]);
        return p1;
    };
    if (p1[0] == NODE_FIELD) {
        p1[3] = substitute(p0, p1[3]);
        return p1;
    };
    if (p1[0] == NODE_FIELDREF) {
        p1[2] = substitute(p0, p1[2]);
        return p1;
    };
    if (p1[0] == NODE_VARIANT) {
        if (p1[4] != NULL) {
            p1[4] = substitute(p0, p1[4]);
        };
        return p1;
    };
    if (p1[0] == NODE_TYPEDEXPR) {
        p1[2] = substitute(p0, p1[2]);
        return p1;
    };
    if (p1[0] == NODE_IF) {
        p1[2] = substitute(p0, p1[2]);
        p1[3] = substitute(p0, p1[3]);
        return p1;
    };
    if (p1[0] == NODE_IFELSE) {
        p1[2] = substitute(p0, p1[2]);
        p1[3] = substitute(p0, p1[3]);
        p1[4] = substitute(p0, p1[4]);
        return p1;
    };
    if (p1[0] == NODE_SARRAY) {
        not_reachable();
    };
    if (p1[0] == NODE_CAST) {
        p1[2] = substitute(p0, p1[2]);
        return p1;
    };
    if (p1[0] == NODE_NEW) {
        p1[2] = substitute(p0, p1[2]);
        return p1;
    };
    if (p1[0] == NODE_WHILE) {
        p1[2] = substitute(p0, p1[2]);
        return p1;
    };
    if (p1[0] == NODE_FOR) {
        p1[2] = substitute(p0, p1[2]);
        p1[3] = substitute(p0, p1[3]);
        p1[4] = substitute(p0, p1[4]);
        p1[5] = substitute(p0, p1[5]);
        return p1;
    };
    if (p1[0] == NODE_NEWARRAY) {
        p1[2] = substitute(p0, p1[2]);
        p1[3] = substitute(p0, p1[3]);
        return p1;
    };
    return p1;
};

(% p0: variable, p1: block %);
occur: (p0, p1) {
    allocate(3);
    if (p1[0] == NODE_IDENTIFIER) {
        if (p0[3] == p1[3]) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_ARRAY) {
        x0 = p1[ARRAY_LENGTH];
        x1 = p1[ARRAY_ELEMENTS];
        x2 = 0;
        while (x2 < x0) {
            if (occur(p0, x1[x2])) { return TRUE; };
            x2 = x2 + 1;
        };
        return FALSE;
    };
    if (p1[0] == NODE_TUPLE) {
        x0 = p1[TUPLE_LENGTH];
        x1 = p1[TUPLE_ELEMENTS];
        x2 = 0;
        while (x2 < x0) {
            if (occur(p0, x1[x2])) { return TRUE; };
            x2 = x2 + 1;
        };
        return FALSE;
    };
    if (p1[0] == NODE_BLOCK) {
        x0 = p1[BLOCK_STATEMENTS];
        while (x0 != NULL) {
            if (occur(p0, ls_value(x0))) { return TRUE; };
            x0 = ls_next(x0);
        };
        return FALSE;
    };
    if (p1[0] == NODE_DECL) {
        return occur(p0, p1[3]);
    };
    if (p1[0] == NODE_CALL) {
        if (occur(p0, p1[2])) { return TRUE; };
        if (occur(p0, p1[3])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_SUBSCRIPT) {
        if (occur(p0, p1[2])) { return TRUE; };
        if (occur(p0, p1[3])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_LAMBDA) {
        if (occur(p0, p1[2])) { return TRUE; };
        if (occur(p0, p1[3])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_UNEXPR) {
        if (occur(p0, p1[3])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_BINEXPR) {
        if (occur(p0, p1[3])) { return TRUE; };
        if (occur(p0, p1[4])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_ASSIGN) {
        if (occur(p0, p1[3])) { return TRUE; };
        if (occur(p0, p1[4])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_RETVAL) {
        return occur(p0, p1[2]);
    };
    if (p1[0] == NODE_SYSCALL) {
        return occur(p0, p1[2]);
    };
    if (p1[0] == NODE_FIELD) {
        return occur(p0, p1[3]);
    };
    if (p1[0] == NODE_FIELDREF) {
        return occur(p0, p1[2]);
    };
    if (p1[0] == NODE_VARIANT) {
        if (p1[4] != NULL) {
            return occur(p0, p1[4]);
        };
        return FALSE;
    };
    if (p1[0] == NODE_TYPEDEXPR) {
        return occur(p0, p1[2]);
    };
    if (p1[0] == NODE_IF) {
        if (occur(p0, p1[2])) { return TRUE; };
        if (occur(p0, p1[3])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_IFELSE) {
        if (occur(p0, p1[2])) { return TRUE; };
        if (occur(p0, p1[3])) { return TRUE; };
        if (occur(p0, p1[4])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_SARRAY) {
        not_reachable();
    };
    if (p1[0] == NODE_CAST) {
        return occur(p0, p1[2]);
    };
    if (p1[0] == NODE_NEW) {
        return occur(p0, p1[2]);
    };
    if (p1[0] == NODE_WHILE) {
        if (occur(p0, p1[2])) { return TRUE; };
        if (occur(p0, p1[3])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_FOR) {
        if (occur(p0, p1[2])) { return TRUE; };
        if (occur(p0, p1[3])) { return TRUE; };
        if (occur(p0, p1[4])) { return TRUE; };
        if (occur(p0, p1[5])) { return TRUE; };
        return FALSE;
    };
    if (p1[0] == NODE_NEWARRAY) {
        if (occur(p0, p1[2])) { return TRUE; };
        return occur(p0, p1[3]);
    };
    return FALSE;
};

closure_conversion: (p0) {
    allocate(1);
    fmap = mkmap(&simple_hash, &simple_equal, 0);
    cmap = mkmap(&simple_hash, &simple_equal, 0);
    closed = mkiset();
    x0 = p0[1]; (% item list %);
    while (x0 != NULL) {
        ls_set(x0, (close(ls_value(x0)))[0]);
        x0 = ls_next(x0);
    };
    return p0;
};

