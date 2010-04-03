(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: type.rl 2010-04-03 17:38:29 nineties $
 %);

include(stddef, code);

export(mktyvar, mktyscheme, rename_tyscheme);
export(freevar, freevar_tyscheme);
export(is_polymorphic_type);

typeid : 0;
new_tyid: () {
    typeid = typeid + 1;
    return typeid - 1;
};

mktyvar: () {
    return mktup2(NODE_TYVAR, new_tyid());
};

(% p0: type %);
mktyscheme: (p0) {
    return mktup2(mkiset(), p0);
};


(% p0: type scheme %);
rename_tyscheme: (p0) {
    allocate(4);
    x0 = p0[0]; (% old type-ids %);
    if (x0 == NULL) { return p0; };
    x1 = mkiset(); (% new type-ids %);
    x2 = mkmap(&simple_hash, &simple_equal, 10); (% old-id to new-id %);
    while (x0 != NULL) {
        x3 = new_tyid();
        x1 = iset_add(x1, x3);
        map_add(x2, ls_value(x0), x3);
        x0 = ls_next(x0);
    };
    return mktup2(x1, rename(x2, p0[1]));
};

(% p0: mapping, p1: type %);
rename: (p0, p1) {
    allocate(1);
    if (p1[0] == NODE_TUPLE_T) {
        return rename_tuple_t(p0, p1);
    };
    if (p1[0] == NODE_ARRAY_T) {
        return mktup2(NODE_ARRAY_T, rename(p0, p1[1]));
    };
    if (p1[0] == NODE_LAMBDA_T) {
        return mktup3(NODE_LAMBDA_T,
            rename_tuple_t(p0, p1[1]), rename(p0, p1[2]));
    };
    if (p1[0] == NODE_TYVAR) {
        x0 = map_find(p0, p1[1]);
        if (x0 != NULL) { return mktup2(NODE_TYVAR, x0); };
        return p1;
    };
    return p1;
};

(% p0: mapping, p1: type %);
rename_tuple_t: (p0, p1) {
    allocate(3);
    x0 = p1[1]; (% length %);
    x1 = memalloc(4*x0);
    x2 = 0;
    while (x2 < x0) {
        x1[x2] = rename(p0, (p1[2])[x2]);
        x2 = x2 + 1;
    };
    return mktup3(NODE_TUPLE_T, x0, x1);
};


(% p0: type %);
freevar: (p0) {
    return freevar_iter(mkiset(), p0);
};

(% p0: integer set, p1: type %);
freevar_iter: (p0, p1) {
    allocate(2);
    if (p1[0] == NODE_TUPLE_T) {
        x0 = p1[1]; (% length %);
        x1 = 0;
        while (x1 < x0) {
            p0 = freevar_iter(p0, (p1[2])[x1]);
            x1 = x1 + 1;
        };
        return p0;
    };
    if (p1[0] == NODE_ARRAY_T) { return freevar_iter(p0, p1[1]); };
    if (p1[0] == NODE_LAMBDA_T) {
        p0 = freevar_iter(p0, p1[1]);
        return freevar_iter(p0, p1[2]);
    };
    if (p1[0] == NODE_TYVAR) {
        return iset_add(p0, p1[1]);
    };
    return p0;
};

(% p0: type scheme %);
freevar_tyscheme: (p0) {
    return iset_subtract(freevar(p0[2]), p0[1]);
};

is_polymorphic_type: (p0) {
    allocate(3);
    if (p0[0] == NODE_VOID_T)   { return FALSE; };
    if (p0[0] == NODE_CHAR_T)   { return FALSE; };
    if (p0[0] == NODE_INT_T)    { return FALSE; };
    if (p0[0] == NODE_FLOAT_T)  { return FALSE; };
    if (p0[0] == NODE_DOUBLE_T) { return FALSE; };
    if (p0[0] == NODE_POINTER_T) {
        return is_polymorphic_type(p0[POINTER_T_BASE]);
    };
    if (p0[0] == NODE_ARRAY_T) {
        return is_polymorphic_type(p0[ARRAY_LENGTH]);
    };
    if (p0[0] == NODE_TUPLE_T) {
        x0 = p0[TUPLE_T_LENGTH];
        x1 = p0[TUPLE_T_ELEMENTS];
        x2 = 0;
        while (x2 < x0) {
            if (is_polymorphic_type(x1[x2])) { return TRUE; };
            x2 = x2 + 1;
        };
        return FALSE;
    };
    if (p0[0] == NODE_LAMBDA_T) {
        if (is_polymorphic_type(p0[LAMBDA_T_PARAM]))  { return TRUE; };
        if (is_polymorphic_type(p0[LAMBDA_T_RETURN])) { return TRUE; };
        return FALSE;
    };
    return TRUE;
};

