(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: typing.rl 2010-02-27 15:59:02 nineties $ 
 %);

include(stddef, code);

export(typing);

varid: 0;

new_varid: () {
    varid = varid + 1;
    return varid - 1;
};

scopeid: 0;
scopeid_stack: NULL; 
varmap: NULL;   (% variable table %);

strhash: (p0) {
    allocate(1);
    x0 = 0;
    while (rch(p0, 0) != '\0') {
        x0 = x0 * 7 + rch(p0, 0);
        p0 = p0 + 1;
    };
    return x0;
};

(% p0: (scopeid-id, name) %);
varmap_hash: (p0) {
    return strhash(p0[1]) * 3+ p0[0];
};

varmap_keyequal: (p0, p1) {
    if (p0[0] != p1[0]) { return FALSE; };
    return streq(p0[1], p1[1]);
};

varmap_push: () {
    scopeid = scopeid + 1;
    vec_pushback(scopeid_stack, scopeid);
};

varmap_pop: () {
    vec_popback(scopeid_stack);
};

(% p0: name, p1: value %);
varmap_add: (p0, p1) {
    map_add(varmap, mktup2(scopeid, p0), p1);
};

(% p0: name %);
varmap_find: (p0) {
    allocate(3);
    x0 = vec_size(scopeid_stack)-1;
    while (x0 >= 0) {
        x1 = vec_at(scopeid_stack, x0); (% scopeid-id %);
        x2 = map_find(varmap, mktup2(x1, p0));
        if (x2 != NULL) { return x2; };
        x0 = x0 - 1;
    };
    return NULL;
};

init_varmap: () {
    varmap = mkmap(&varmap_hash, &varmap_keyequal, 10);
    scopeid_stack = mkvec(0);
    varmap_push(); (% global scopeid %);
};


tyvarmap: NULL;

tyvarid_hash: (p0) {
    return p0;
};

tyvarid_equal: (p0, p1) {
    return p0 == p1;
};

init_tyvarmap: () {
    tyvarmap = mkmap(&tyvarid_hash, &tyvarid_equal, 10);
};

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

infer_funcs: [not_reachable, not_implemented, infer_integer, infer_string, infer_identifier,
    infer_array, infer_tuple, not_implemented, infer_decl, not_implemented,
    not_implemented, infer_lambda, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented
];

void_type   : NULL;
char_type   : NULL;
int_type    : NULL;
float_type  : NULL;
double_type : NULL;

init_basic_types: () {
    void_type   = mktup1(NODE_VOID_T);
    char_type   = mktup1(NODE_CHAR_T);
    int_type    = mktup1(NODE_INT_T);
    float_type  = mktup1(NODE_FLOAT_T);
    double_type = mktup1(NODE_DOUBLE_T);
};

infer_integer: (p0) {
    if (p0[2] == 8) { p0[1] = char_type; return p0; };
    if (p0[2] == 32) { p0[1] = int_type; return p0; };
    not_reachable();
};

infer_string: (p0) {
    p0[1] = mktup2(NODE_POINTER_T, char_type);
    return p0;
};

infer_identifier: (p0) {
    allocate(2);
    x0 = varmap_find(p0[2]); (% (tyscheme, id) %);
    if (x0 == NULL) {
        fputs(stderr, "ERROR: undefined variable '");
        fputs(stderr, p0[2]);
        fputs(stderr, "'\n");
        exit(1);
    };
    x1 = rename_tyscheme(x0[0]);
    p0[1] = x1[2];
    p0[3] = x0[1];
    p0[4] = x1;
    return deref(p0);
};

infer_array: (p0) {
    allocate(4);
    x0 = mktyvar();
    x1 = p0[2]; (% length %);
    x2 = 0;
    x3 = p0[3]; (% pointer to the array %);
    while (x2 < x1) {
        x3[x2] = infer_item(x3[x2]);
        unify(x0, x3[x2][1]);
        x2 = x2 + 1;
    };
    p0[1] = mktup4(NODE_ARRAY_T, x0, x1, FALSE);
    return deref(p0);
};

parse_pat: (p0) {
    if (p0[0] == NODE_IDENTIFIER) { return parse_var_pat(p0); };
    if (p0[0] == NODE_TUPLE) { return parse_tuple_pat(p0); };
    fputs(stderr, "ERROR: invalid pattern expression '");
    put_item(stderr, p0);
    fputs(stderr, "'\n");
    exit(1);
};

parse_var_pat: (p0) {
    allocate(3);
    x0 = mktyvar();
    x1 = new_varid();
    x2 = mktyscheme(x0);
    varmap_add(p0[2], mktup2(x2, x1));
    p0[1] = x0;
    p0[3] = x1;
    p0[4] = x2;
    return p0;
};

parse_tuple_pat: (p0) {
    allocate(4);
    x0 = p0[2]; (% length %);
    x1 = 0;
    x3 = memalloc(4*x0);
    while (x1 < x0) {
        x2 = p0[3];
        x2[x1] = parse_pat(x2[x1]);
        x3[x1] = (x2[x1])[1];
        x1 = x1 + 1;
    };
    p0[1] = mktup3(NODE_TUPLE_T, x0, x3);
    return p0;
};

infer_block: (p0) {
    allocate(2);
    x0 = p0[2];
    x1 = mktyvar();
    while (x0 != NULL) {
        ls_set(x0, infer_item(ls_value(x0)));
        unify(x1, (ls_value(x0))[0]);
        x0 = ls_next(x0);
    };
    return deref(p0);
};

infer_tuple: (p0) {
    allocate(4);
    x1 = p0[2]; (% length %);
    x2 = p0[3];
    x3 = memalloc(4*x1);
    x0 = 0;
    while (x0 < x1) {
        x2[x0] = infer_item((p0[3])[x0]);
        x3[x0] = (x2[x0])[1];
        x0 = x0 + 1;
    };
    p0[1] = mktup3(NODE_TUPLE_T, x1, x3);
    return deref(p0);
};

infer_decl: (p0) {
    allocate(1);
    x0 = infer_decl_impl(p0[2], p0[3]);
    p0[2] = x0[0];
    p0[3] = x0[1];
    p0[1] = (x0[1])[1];
    return deref(p0);
};

(% p0: lhs, p1: rhs %);
infer_decl_impl: (p0, p1) {
    if (p0[0] == NODE_IDENTIFIER) {
        return infer_decl_var(p0, p1);
    };
    not_reachable();
};

(% p0: var, p1: expr %);
infer_decl_var: (p0, p1) {
    allocate(3);
    x0 = mktyvar();
    x1 = new_varid();
    varmap_add(p0[2], mktup2(mktyscheme(x0), x1));
    p1 = infer_item(p1);
    unify(x0, p1[1]);
    x2 = closure(p1[1]);
    varmap_add(p0[2], mktup2(x2, x1));
    p0[1] = p1[1];
    p0[4] = x2;
    p0 = deref(p0);
    return mktup2(p0, p1);
};

infer_lambda: (p0) {
    varmap_push();
    p0[LAMBDA_ARG]  = parse_pat(p0[LAMBDA_ARG]);
    p0[LAMBDA_BODY] = infer_item(p0[LAMBDA_BODY]);
    varmap_pop();
    not_implemented();
};

(% p0: item %);
infer_item: (p0) {
    allocate(1);
    x0 = infer_funcs[p0[0]];
    return x0(p0);
};

remove_unfreevar: (p0) {
    allocate(1);
    if (p0 == NULL) { return NULL; };
    x0 = map_find(tyvarmap, ls_value(p0));
    if (x0 == NULL) {
        p0[1] = remove_unfreevar(ls_next(p0));
        return p0;
    };
    return remove_unfreevar(ls_next(p0));
};

(% p0: type %);
closure: (p0) {
    allocate(1);
    x0 = freevar(p0);
    x0 = remove_unfreevar(x0);
    return mktup3(x0, p0);
};

(% p0, p1: type %);
unify: (p0, p1) {
    if (p0[0] == NODE_TYVAR) { return unify_tyvar(p0, p1); };
    if (p1[0] == NODE_TYVAR) { return unify_tyvar(p1, p0); };
    if (p0[0] == p1[0]) {
        if (p0[0] == NODE_VOID_T)     { return; };
        if (p0[0] == NODE_CHAR_T)     { return; };
        if (p0[0] == NODE_INT_T)      { return; };
        if (p0[0] == NODE_FLOAT_T)    { return; };
        if (p0[0] == NODE_DOUBLE_T)   { return; };
        if (p0[0] == NODE_POINTER_T)  { return unify(p0[POINTER_T_BASE], p1[POINTER_T_BASE]); };
        if (p0[0] == NODE_TUPLE_T)    { return unify_tuple_t(p0, p1); };
        if (p0[0] == NODE_ARRAY_T)    {
            unify(p0[ARRAY_T_ELEMENT], p1[ARRAY_T_ELEMENT]);
            if (p0[ARRAY_T_LENGTH] != p1[ARRAY_T_LENGTH]) {
                type_mismatch(p0, p1);
            };
            return;
        };
        if (p0[0] == NODE_LAMBDA_T) { return unify_function_t(p0, p1); };
    };
    type_mismatch(p0, p1);
};

unify_tuple_t: (p0, p1) {
    allocate(2);
    if (p0[1] != p1[1]) { type_mismatch(p0, p1); };
    x1 = p0[1]; (% length %);
    x0 = 0;
    while (x0 < x1) {
        unify((p0[2])[x0], (p1[2])[x0]);
        x0 = x0 + 1;
    };
};

unify_function_t: (p0, p1) {
    unify_tuple_t(p0[1], p1[1]);
    unify(p0[2], p1[2]);
};

(% p0: tyvar, p1, type %);
unify_tyvar: (p0, p1) {
    allocate(1);
    if (p1[0] == NODE_TYVAR) {
        if (p0[1] == p1[1]) { return; };
    };
    x0 = map_find(tyvarmap, p0[1]);
    if (x0 != NULL) {
        unify(x0[1], p1);
    };
    if (p1[0] == NODE_TYVAR) {
        x0 = map_find(tyvarmap, p1[1]);
        if (x0 != NULL) {
            unify(p0, x0[1]);
        };
    };
    occur_check(p0[1], p1);
    x0 = closure(p1);
    map_add(tyvarmap, p0[1], x0);
};

(% p0: id, p1, type %);
occur_check: (p0, p1) {
    allocate(1);
    if (p1[0] == NODE_TUPLE_T)    { return occur_check_tuple_t(p0, p1); };
    if (p1[0] == NODE_ARRAY_T)    { return occur_check(p0, p1[1]); };
    if (p1[0] == NODE_LAMBDA_T) { return occur_check_function_t(p0, p1); };
    if (p1[0] == NODE_TYVAR) {
        if (p0 == p1[1]) {
            fputs(stderr, "ERROR: infinite type\n");
            exit(1);
        };
        x0 = map_find(tyvarmap, p1[1]);
        if (x0 == NULL) { return; };
        x0 = rename_tyscheme(x0);
        occur_check(p0, x0[1]);
    };
};

occur_check_tuple_t: (p0, p1) {
    allocate(2);
    x1 = p1[1]; (% length %);
    x0 = 0;
    while (x0 < x1) {
        occur_check(p0, (p1[2])[x0]);
        x0 = x0 + 1;
    };
};

occur_check_function_t: (p0, p1) {
    occur_check_tuple_t(p0, p1[1]);
    occur_check(p0, p1[2]);
};

(% p0, p1: type %);
type_mismatch: (p0, p1) {
    fputs(stderr, "ERROR: type mismatch ");
    put_type(stderr, p0);
    fputs(stderr, " <-> ");
    put_type(stderr, p1);
    fputc(stderr, '\n');
    exit(1);
};

deref_funcs: [not_reachable, not_implemented, deref_integer, deref_string, deref_identifier,
    deref_array, deref_tuple, not_implemented, deref_decl, not_implemented,
    not_implemented, not_implemented, not_implemented, not_implemented, not_implemented,
    not_implemented, not_implemented
];

(% p0: item %);
deref: (p0) {
    allocate(1);
    x0 = deref_funcs[p0[0]];
    return x0(p0);
};

deref_integer: (p0) {
    p0[1] = deref_type(p0[1]);
    return p0;
};

deref_string: (p0) {
    p0[1] = deref_type(p0[1]);
    return p0;
};

deref_identifier: (p0) {
    allocate(2);
    x0 = deref_type(p0[1]);
    x1 = closure(x0);
    p0[1] = x0;
    p0[4] = x1;
    return p0;
};

deref_array: (p0) {
    allocate(3);
    x0 = p0[2]; (% length %);
    x1 = 0;
    while (x1 < x0) {
        x2 = p0[3];
        x2[x1] = deref(x2[x1]);
        x1 = x1 + 1;
    };
    p0[1] = deref_type(p0[1]);
    return p0;
};

deref_tuple: (p0) {
    allocate(3);
    x0 = p0[2]; (% length %);
    x1 = 0;
    while (x1 < x0) {
        x2 = p0[3];
        x2[x1] = deref(x2[x1]);
        x1 = x1 + 1;
    };
    p0[1] = deref_type(p0[1]);
    return p0;
};

deref_decl: (p0) {
    p0[2] = deref(p0[2]); (% lhs %);
    p0[3] = deref(p0[3]); (% rhs %);
    p0[1] = deref_type(p0[1]);
    return p0;
};

(% p0: type %);
deref_type: (p0) {
    allocate(3);
    if (p0[0] == NODE_TUPLE_T) {
        x0 = p0[1]; (% length %);
        x1 = 0;
        while (x1 < x0) {
            x2 = p0[2];
            x2[x1] = deref_type(x2[x1]);
            x1 = x1 + 1;
        };
        return p0;
    };
    if (p0[0] == NODE_ARRAY_T)   { p0[1] = deref_type(p0[1]); return p0; };
    if (p0[0] == NODE_LAMBDA_T) {
        p0[1] = deref_type(p0[1]);
        p0[2] = deref_type(p0[2]);
        return p0;
    };
    if (p0[0] == NODE_TYVAR) {
        x0 = map_find(tyvarmap, p0[1]); (% x0: type scheme %);
        if (x0 == NULL) { return p0; };
        x1 = x0[2];
        x1 = deref_type(x1);
        x2 = closure(x1);
        map_add(tyvarmap, p0[1], x2);
        return x1
    };
    return p0;
};

(% p0: program (item list) %);
typing: (p0) {
    allocate(1);

    init_basic_types();
    init_varmap();
    init_tyvarmap();

    x0 = p0[1];
    while (x0 != NULL) {
        ls_set(x0, infer_item(ls_value(x0)));
        x0 = ls_next(x0);
    }
};

