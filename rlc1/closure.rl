(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: closure.rl 2010-04-08 17:10:06 nineties $
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

ESCESSIVE_FUNCTION_NEST_DEPTH => 5;

nest_depth: 0;

incl_nestlevel: () {
    nest_depth = nest_depth + 1;
    return nest_depth;
};

decl_nestlevel: () {
    nest_depth = nest_depth - 1;
};

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
        x0 = p1[BLOCK_STATEMENTS];
        (% trickey part, must iterate in reversed order %);
        x0 = ls_reverse(x0);
        while (x0 != NULL) {
            p0 = iterate(p0, ls_value(x0));
            x0 = ls_next(x0);
        };
        p1[BLOCK_STATEMENTS] = ls_reverse(x0);
        return p0;
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
    if (p1[0] == NODE_SUBSCRIPT) { not_implemented(); };
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
    if (p1[0] == NODE_VARIANT)   { return iterate(p0, p1[4]); };
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

(% p0: pointer to env, p1: free variables %);
build_closure_env: (p0, p1) {
    if (p1 != NULL) { not_implemented(); };
    return p1;
};

(% p0: function ident, p1: lambda, p2: free variables %);
close_function_impl: (p0, p1, p2) {
    allocate(2);
    x0 = mktup6(NODE_IDENTIFIER, strdup("clsenv"), 0, mktyscheme(unit_type), FALSE);
    set_varid(x0);
    x1 = build_closure_env(x0, p2);
};

(% p0: function ident, p1: lambda %);
close_function: (p0, p1) {
    allocate(4);
    puts(get_ident_name(p0));
    putc('\n');
    x0 = incl_nestlevel();
    (% determine the free variables of the lambda %);
    x1 = free_variable(p1);
    puts("free variable:");
    while (x1 != NULL) {
        x2 = vec_at(vartable, ls_value(x1));
        putc(' ');
        put_item(stdout, x2);
        x1 = ls_next(x1);
    };
    putc('\n');
    x3 = close_function_impl(p0, p1, x1);

    return mktup2(p1, p0);
};

close_funcs: [ not_reachable, do_nothing, do_nothing, do_nothing, close_identifier,
not_implemented, close_tuple, close_block, close_decl, do_nothing, do_nothing,
do_nothing, close_unexpr, close_binexpr, close_assign, close_export, do_nothing,
do_nothing, do_nothing, close_retval, close_syscall, close_field, close_fieldref,
do_nothing, close_variant, do_nothing, close_typedexpr, close_if, close_ifelse, do_nothing
];

do_nothing: (p0) {
    return mktup2(p0, NULL);
};

close_identifier: (p0) {
    allocate(2);
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
    x0 = p0[2];
    while (x0 != NULL) {
        ls_set(x0, (close(ls_value(x0)))[0]);
        x0 = ls_next(x0);
    };
    return mktup2(p0, NULL);
};

close_fundecl: (p0) {
    allocate(3);
    x0 = p0[2]; (% identifier %);
    x1 = p0[3]; (% lambda %);
    x2 = close_function(x0, x1); (% new lambda, id %);
    map_add(fmap, x0[3], x2[1]);
    p0[3] = x2[0];
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
    p0[4] = (close(p0[4]))[0];
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

close: (p0) {
    return (close_funcs[p0[0]])(p0);
};

closure_conversion: (p0) {
    allocate(1);
    fmap = mkmap(&simple_hash, &simple_equal, 0);
    cmap = mkmap(&simple_hash, &simple_equal, 0);
    x0 = p0[1]; (% item list %);
    while (x0 != NULL) {
        ls_set(x0, (close(ls_value(x0)))[0]);
        x0 = ls_next(x0);
    };
    return p0;
};
