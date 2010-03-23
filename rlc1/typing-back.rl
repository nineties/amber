(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: typing-back.rl 2010-03-24 03:32:14 nineties $
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

infer_funcs: [ not_called, infer_integer, infer_string, infer_identifier,
    infer_array, infer_block, infer_tuple, infer_pat, infer_rewrite
];

void_type   : NULL;
bool_type   : NULL;
char_type   : NULL;
int_type    : NULL;
int64_type  : NULL;
float_type  : NULL;
double_type : NULL;

init_basic_types: () {
    void_type   = mktup1(NODE_VOID_T);
    bool_type   = mktup1(NODE_BOOL_T);
    char_type   = mktup1(NODE_CHAR_T);
    int_type    = mktup1(NODE_INT_T);
    int64_type  = mktup1(NODE_INT64_T);
    float_type  = mktup1(NODE_FLOAT_T);
    double_type = mktup1(NODE_DOUBLE_T);
};

not_called: (p0) {
    fputs(stderr, "ERROR: this function should not be called\n");
    exit(1);
};

not_reachable: () {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

infer_integer: (p0) {
    p0[1] = int_type;
    return p0;
};

infer_string: (p0) {
    p0[1] = mktup2(NODE_ARRAY_T, char_type);
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
    return p0;
};

infer_array: (p0) {
    allocate(4);
    x0 = p0[2]; (% length %);
    x1 = 0;
    x3 = NULL;
    while (x1 < x0) {
        x2 = p0[3];
        x2[x1] = infer_item(x2[x1]);
        if (x3 == NULL) {
            x3 = (x2[x1])[1];
        } else {
            unify(x3, (x2[x1])[1]);
        };
        x1 = x1 + 1;
    };
    if (x3 != NULL) {
        p0[1] = mktup2(NODE_ARRAY_T, x3);
    } else {
        p0[1] = mktup2(NODE_ARRAY_T, mktyvar());
    };
    return p0;
};

infer_block: (p0) {
    allocate(1);
    varmap_push();
    x0 = p0[2];
    while (x0 != NULL) {
        ls_set(x0, infer_item(ls_value(x0)));
        x0 = ls_next(x0);
    };
    p0[1] = void_type;
    varmap_pop();
    return p0;
};

(% p0: e1[e2] %);
infer_arrayop: (p0) {
    allocate(3);
    x0 = infer_item(p0[2]); (% e1 %);
    x1 = infer_item(p0[3]); (% e2 %);
    x2 = mktyvar();
    unify(mktup2(NODE_ARRAY_T, x2), x0[1]);
    unify(mktup2(NODE_ARRAY_T, int_type), x1[1]);
    p0[1] = x2;
    return deref(p0);
};

(% p0: (...) { ... } %);
infer_blockop: (p0) {
    varmap_push();
    p0[2] = parse_pat(p0[2]);
    p0[3] = infer_item(p0[3]);
    p0[1] = mktup3(NODE_LAMBDA_T, (p0[2])[1], (p0[3])[1]);
    varmap_pop();
    return deref(p0);
};

(% p0: e(...) %);
infer_tupleop: (p0) {
    allocate(1);
    x0 = mktyvar(); (% return type %);
    p0[2] = infer_item(p0[2]); (% function %);
    p0[3] = infer_item(p0[3]); (% arguments %);
    unify((p0[2])[1], mktup3(NODE_LAMBDA_T, (p0[3])[1], x0));
    p0[1] = x0;
    return deref(p0);
};

parse_pat: (p0) {
    if (p0[0] == NODE_IDENTIFIER) { return parse_var_pat(p0); };
    if (p0[0] == NODE_TUPLE) { return parse_tuple_pat(p0); };
    not_reachable();
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
    return p0;
};

infer_pat: (p0) {
    return p0;
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

infer_asgn: (p0) {
    p0[2] = infer_item(p0[2]);
    p0[3] = infer_item(p0[3]);
    unify((p0[2])[1], (p0[3])[1]);
    p0[1] = (p0[2])[1];
    return deref(p0);
};
infer_addasgn: (p0)    { return infer_opassign(p0); };
infer_subasgn: (p0)    { return infer_opassign(p0); };
infer_mulasgn: (p0)    { return infer_opassign(p0); };
infer_divasgn: (p0)    { return infer_opassign(p0); };
infer_modasgn: (p0)    { return infer_opassign(p0); };
infer_orasgn: (p0)     { return infer_opassign(p0); };
infer_xorasgn: (p0)    { return infer_opassign(p0); };
infer_andasgn: (p0)    { return infer_opassign(p0); };
infer_lshiftasgn: (p0) { return infer_opassign(p0); };
infer_rshiftasgn: (p0) { return infer_opassign(p0); };

infer_opassign: (p0) {
    p0[2] = infer_item(p0[2]);
    p0[3] = infer_item(p0[3]);
    p0[1] = (p0[2])[1];
    return deref(p0);
};

infer_add: (p0) { return infer_binary(p0); };
infer_sub: (p0) { return infer_binary(p0); };
infer_mul: (p0) { return infer_binary(p0); };
infer_div: (p0) { return infer_binary(p0); };
infer_mod: (p0) { return infer_binary(p0); };
infer_lshift: (p0) { return infer_binary(p0); };
infer_rshift: (p0) { return infer_binary(p0); };
infer_and: (p0) { return infer_binary(p0); };
infer_xor: (p0) { return infer_binary(p0); };
infer_or: (p0) { return infer_binary(p0); };
infer_lt: (p0) { return infer_comparison(p0); };
infer_gt: (p0) { return infer_comparison(p0); };
infer_le: (p0) { return infer_comparison(p0); };
infer_ge: (p0) { return infer_comparison(p0); };
infer_eq: (p0) { return infer_comparison(p0); };
infer_ne: (p0) { return infer_comparison(p0); };

infer_binary: (p0) {
    p0[2] = infer_item(p0[2]);
    p0[3] = infer_item(p0[3]);
    unify((p0[2])[1], (p0[3])[1]);
    p0[1] = (p0[2])[1];
    return deref(p0);
};

infer_comparison: (p0) {
    p0[2] = infer_item(p0[2]);
    p0[3] = infer_item(p0[3]);
    unify((p0[2])[1], (p0[3])[1]);
    p0[1] = int_type;
    return deref(p0);
};

infer_seqor: (p0) { return infer_seq_comparison(p0); };
infer_seqand: (p0) { return infer_seq_comparison(p0); };

infer_seq_comparison: (p0) {
    p0[2] = infer_item(p0[2]);
    p0[3] = infer_item(p0[3]);
    unify(int_type, (p0[2])[1]);
    unify(int_type, (p0[3])[1]);
    p0[1] = int_type;
    return deref(p0);
};

infer_uplus: (p0)   { return infer_unary(p0); };
infer_uminus: (p0)  { return infer_unary(p0); };
infer_inverse: (p0) { return infer_unary(p0); };

infer_unary: (p0) {
    p0[2] = infer_item(p0[2]);
    p0[3] = infer_item(p0[3]);
    unify((p0[2])[1], (p0[3])[1]);
    p0[1] = (p0[2])[1];
    return deref(p0);
};

infer_not: (p0) {
    p0[2] = infer_item(p0[2]);
    unify(int_type, (p0[2])[1]);
    p0[1] = int_type;
    return deref(p0);
};

infer_addressof: (p0) {
    p0[2] = infer_item(p0[2]);
    p0[1] = mktup2(NODE_POINTER_T, (p0[2])[1]);
    return deref(p0);
};

infer_indirect: (p0) {
    allocate(1);
    x0 = mktyvar(); (% refered type %);
    p0[2] = infer_item(p0[2]);
    unify(mktup2(NODE_POINTER_T, x0), (p0[2])[1]);
    p0[1] = x0;
    return deref(p0);
};

infer_preincr: (p0) { return infer_unary(p0); };
infer_predecr: (p0) { return infer_unary(p0); };
infer_postincr: (p0) { return infer_unary(p0); }; 
infer_postdecr: (p0) { return infer_unary(p0); };

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
    return mktup3(NODE_TYSCHEME, x0, p0);
};

(% p0, p1: type %);
unify: (p0, p1) {
    if (p0[0] == NODE_TYVAR) { return unify_tyvar(p0, p1); };
    if (p1[0] == NODE_TYVAR) { return unify_tyvar(p1, p0); };
    if (p0[0] == p1[0]) {
        if (p0[0] == NODE_VOID_T)     { return; };
        if (p0[0] == NODE_BOOL_T)     { return; };
        if (p0[0] == NODE_CHAR_T)     { return; };
        if (p0[0] == NODE_INT_T)      { return; };
        if (p0[0] == NODE_INT64_T)    { return; };
        if (p0[0] == NODE_FLOAT_T)    { return; };
        if (p0[0] == NODE_DOUBLE_T)   { return; };
        if (p0[0] == NODE_TUPLE_T)    { return unify_tuple_t(p0, p1); };
        if (p0[0] == NODE_ARRAY_T)    { return unify(p0[1], p1[1]); };
        if (p0[0] == NODE_LIST_T)     { return unify(p0[1], p1[1]); };
        if (p0[0] == NODE_POINTER_T)  { return unify(p0[1], p1[1]); };
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
        (% here x0 is NODE_TYSCHEME %);
        unify(x0[2], p1);
    };
    if (p1[0] == NODE_TYVAR) {
        x0 = map_find(tyvarmap, p1[1]);
        if (x0 != NULL) {
            unify(p0, x0[2]);
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
    if (p1[0] == NODE_LIST_T)     { return occur_check(p0, p1[1]); };
    if (p1[0] == NODE_POINTER_T)  { return occur_check(p0, p1[1]); };
    if (p1[0] == NODE_LAMBDA_T) { return occur_check_function_t(p0, p1); };
    if (p1[0] == NODE_TYVAR) {
        if (p0 == p1[1]) {
            fputs(stderr, "ERROR: infinite type\n");
            exit(1);
        };
        x0 = map_find(tyvarmap, p1[1]);
        if (x0 == NULL) { return; };
        x0 = rename_tyscheme(x0);
        occur_check(p0, x0[2]);
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

(% p0: item %);
deref: (p0) {
    if (p0[0] == NODE_IDENTIFIER) { return deref_identifier(p0); };
    if (p0[0] == NODE_INTEGER) { p0[1] = deref_type(p0[1]); return p0; };
    if (p0[0] == NODE_ARRAY) { return deref_array(p0); };
    if (p0[0] == NODE_LIST) { return deref_list(p0); };
    if (p0[0] == NODE_TUPLE) { return deref_tuple(p0); };
    if (p0[0] == NODE_ARRAYOP) { return deref_binary(p0); };
    if (p0[0] == NODE_LISTOP) { return deref_binary(p0); };
    if (p0[0] == NODE_TUPLEOP) { return deref_binary(p0); };
    if (p0[0] == NODE_DECL) { return deref_binary(p0); };
    if (p0[0] == NODE_ASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_ADDASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_SUBASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_MULASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_DIVASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_MODASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_ORASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_XORASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_ANDASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_LSHIFTASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_RSHIFTASGN) { return deref_binary(p0); };
    if (p0[0] == NODE_ADD) { return deref_binary(p0); };
    if (p0[0] == NODE_SUB) { return deref_binary(p0); };
    if (p0[0] == NODE_MUL) { return deref_binary(p0); };
    if (p0[0] == NODE_DIV) { return deref_binary(p0); };
    if (p0[0] == NODE_MOD) { return deref_binary(p0); };
    if (p0[0] == NODE_LSHIFT) { return deref_binary(p0); };
    if (p0[0] == NODE_RSHIFT) { return deref_binary(p0); };
    if (p0[0] == NODE_LT) { return deref_binary(p0); };
    if (p0[0] == NODE_GT) { return deref_binary(p0); };
    if (p0[0] == NODE_LE) { return deref_binary(p0); };
    if (p0[0] == NODE_GE) { return deref_binary(p0); };
    if (p0[0] == NODE_EQ) { return deref_binary(p0); };
    if (p0[0] == NODE_NE) { return deref_binary(p0); };
    if (p0[0] == NODE_AND) { return deref_binary(p0); };
    if (p0[0] == NODE_XOR) { return deref_binary(p0); };
    if (p0[0] == NODE_OR) { return deref_binary(p0); };
    if (p0[0] == NODE_SEQOR) { return deref_binary(p0); };
    if (p0[0] == NODE_SEQAND) { return deref_binary(p0); };
    if (p0[0] == NODE_UPLUS) { return deref_unary(p0); };
    if (p0[0] == NODE_UMINUS) { return deref_unary(p0); };
    if (p0[0] == NODE_INVERSE) { return deref_unary(p0); };
    if (p0[0] == NODE_NOT) { return deref_unary(p0); };
    if (p0[0] == NODE_ADDRESSOF) { return deref_unary(p0); };
    if (p0[0] == NODE_INDIRECT) { return deref_unary(p0); };
    if (p0[0] == NODE_PREINCR) { return deref_unary(p0); };
    if (p0[0] == NODE_PREDECR) { return deref_unary(p0); };
    if (p0[0] == NODE_POSTINCR) { return deref_unary(p0); };
    if (p0[0] == NODE_POSTDECR) { return deref_unary(p0); };
    not_reachable();
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

deref_list: (p0) {
    allocate(1);
    x0 = p0[2];
    while (x0 != NULL) {
        ls_set(x0, deref(ls_value(x0)));
        x0 = ls_next(x0);
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

deref_binary: (p0) {
    p0[1] = deref_type(p0[1]);
    p0[2] = deref(p0[2]);
    p0[3] = deref(p0[3]);
    return p0;
};

deref_unary: (p0) {
    p0[1] = deref_type(p0[1]);
    p0[2] = deref(p0[2]);
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
    if (p0[0] == NODE_LIST_T)    { p0[1] = deref_type(p0[1]); return p0; };
    if (p0[0] == NODE_POINTER_T) { p0[1] = deref_type(p0[1]); return p0; };
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

    x0 = p0[2];
    while (x0 != NULL) {
        ls_set(x0, infer_item(ls_value(x0)));
        x0 = ls_next(x0);
    }
};

