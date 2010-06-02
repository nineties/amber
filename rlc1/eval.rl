(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: eval.rl 2010-06-02 11:41:39 nineties $
 %);

include(stddef,code);
export(init_evaluator, assign, deref, check_arity, eval_sexp);

symbol_map: NULL; (% (symbol name, scope id) -> symbol object %);

scopeid: 0;
scopeid_stack: NULL;

(% p0: (symbol name, scope id) %);
symbol_hash: (p0) {
    return strhash(p0[0])*3 + p0[1];
};

symbol_equal: (p0, p1) {
    if (p0[1] != p1[1]) { return FALSE; };
    return streq(p0[0], p1[0]);
};

scope_push: () {
    scopeid = scopeid + 1;
    vec_pushback(scopeid_stack, scopeid);
};

scope_pop: () {
    vec_popback(scopeid_stack);
};


(% p0: symbol name, p1: value %);
assign: (p0, p1) {
    allocate(1);
    x0 = vec_at(scopeid_stack, vec_size(scopeid_stack)-1);
    map_add(symbol_map, mktup2(p0, x0), p1);
};

(% p0: symbol object %);
deref: (p0) {
    allocate(4);
    x0 = vec_size(scopeid_stack)-1;
    x3 = sym_name(p0);
    while (x0 >= 0) {
        x1 = vec_at(scopeid_stack, x0); (% scopeid-id %);
        x2 = map_find(symbol_map, mktup2(x3, x1));
        if (x2 != NULL) { return x2; };
        x0 = x0 - 1;
    };
    return p0;
};

check_arity: (p0, p1, p2) {
    if (length(p0) != p1) {
        fputs(stderr, "ERROR '");
        fputs(stderr, p2);
        fputs(stderr, "': required ");
        fputi(stderr, p1);
        fputs(stderr, " arguments");
        exit(1);
    }
};

eval_args: (p0) {
    if (p0 == nil_sym) { return nil_sym; };
    if (cons_p(p0) == nil_sym) { return eval_sexp(p0); };
    return mkcons(eval_sexp(car(p0)), eval_args(cdr(p0)));
};

eval_cons: (p0) {
    allocate(2);
    x0 = car(p0);
    x1 = eval_sexp(x0);
    if (x1 == var_sym)     { return eval_var(cdr(p0)); };
    if (x1 == set_sym)     { return eval_set(cdr(p0)); };
    if (x1 == if_sym)      { return eval_if(cdr(p0)); };
    if (x1 == cond_sym)    { return eval_cond(cdr(p0)); };
    if (x1 == while_sym)   { return eval_while(cdr(p0)); };
    if (x1 == do_sym)      { return eval_do(cdr(p0)); };
    if (x1 == lambda_sym)  { return eval_lambda(cdr(p0)); };
    if (x1 == macro_sym)   { return eval_macro(cdr(p0)); };
    if (x1 == import_sym)  { return eval_import(cdr(p0)); };
    if (prim_p(x1) != nil_sym)   { return (prim_funptr(x1))(eval_args(cdr(p0))); };
    if (lambda_p(x1) != nil_sym) { return eval_applambda(x1, cdr(p0)); };
    if (macro_p(x1) != nil_sym)  { return eval_appmacro(x1, cdr(p0)); };
label eval_cons_error;
    fputs(stderr, "ERROR: invalid application of '");
    pp_sexp(stderr, x1);
    fputs(stderr, "'\n");
    exit(1);
};

(% (var <id> <value>) %);
eval_var: (p0) {
    allocate(2);
    check_arity(p0, 2, "var");
    x0 = fresh_sym(car(p0));
    x1 = eval_sexp(cadr(p0));
    sym_set(x0, x1);
    assign(sym_name(x0), x0);
    return x0;
};

eval_set: (p0) {
    allocate(2);
    check_arity(p0, 2, "set");
    x0 = deref(car(p0));
    x1 = eval_sexp(cadr(p0));
    if (sym_value(x0) == NULL) {
        fputs(stderr, "ERROR 'eval_set': undefined variable '");
        fputs(stderr, sym_name(x0));
        fputs(stderr, "'\n");
        exit(1);
    };
    sym_set(x0, x1);
    return x0;
};

eval_quote: (p0) {
    allocate(1);
    if (cons_p(p0) != nil_sym) {
        return mkcons(eval_quote(car(p0)), eval_quote(cdr(p0)));
    };
    if (quote_p(p0) != nil_sym) {
        return mkquote(eval_quote(quote_sexp(p0)));
    };
    if (unquote_p(p0) != nil_sym) {
        return eval_sexp(unquote_sexp(p0));
    };
    return p0;
};

(% p0 : (cond ifthen ifelse) %);
eval_if: (p0) {
    allocate(2);
    scope_push();
    x0 = eval_sexp(car(p0));
    p0 = cdr(p0);
    if (x0 != nil_sym)  {
        x1 = eval_sexp(car(p0));
        scope_pop();
        return x1;
    };
    if (cdr(p0) != nil_sym) {
        x1 = eval_sexp(cadr(p0));
    } else {
        x1 = nil_sym;
    };
    scope_pop();
    return x1;
};

eval_cond: (p0) {
    allocate(1);
    scope_push();
    while (p0 != nil_sym) {
        x0 = car(p0);
        check_arity(x0, 2, "cond");
        if (eval_sexp(car(x0)) != nil_sym) {
            scope_pop();
            return eval_sexp(cadr(x0));
        };
        p0 = cdr(p0);
    };
    fputs(stderr, "ERROR 'eval_cond': any condition was not met\n");
    exit(1);
};

(% p0: (cond body) %);
eval_while: (p0) {
    allocate(3);
    check_arity(p0, 2, "while");
    scope_push();
    x0 = car(p0); (% condition %);
    x1 = cadr(p0); (% body %);
    x2 = eval_sexp(x0);
    while (x2 != nil_sym) {
        eval_sexp(x1);
        x2 = eval_sexp(x0);
    };
    scope_pop();
    if (x2 != nil_sym) {
        fputs(stderr, "ERROR 'while': conditional expression could not evaluated to true/false\n");
        exit(1);
    };
    return nil_sym;
};

eval_do: (p0) {
    allocate(1);
    scope_push();
    while (p0 != nil_sym) {
        x0 = eval_sexp(car(p0));
        p0 = cdr(p0);
    };
    scope_pop();
    return x0;
};

(% (lambda (params) body) %);
eval_lambda: (p0) {
    allocate(2);
    check_arity(p0, 2, "lambda");
    x0 = car(p0); (% params %);
    x1 = cadr(p0); (% body %);
    return mklambda(x0, x1);
};

(% (macro (params) body) %);
eval_macro: (p0) {
    allocate(2);
    check_arity(p0, 2, "macro");
    x0 = car(p0); (% params %);
    x1 = cadr(p0); (% body %);
    return mkmacro(x0, x1);
};

(% p0: argument pattern, p1:arguments p2:lambda%);
match_args: (p0, p1, p2) {
    allocate(1);
    if (p0 == nil_sym) {
        if (p1 == nil_sym) { return; };
        fputs(stderr, "ERROR: argument patter mismatch ");
        pp_sexp(stderr, p2);
        fputs(stderr, ": ");
        pp_sexp(stderr, p0);
        fputs(stderr, " <-> ");
        pp_sexp(stderr, p1);
        fputs(stderr, "\n");
        exit(1);
    };
    if (ign_p(p0) != nil_sym) {
        return;
    };
    if (sym_p(p0) != nil_sym) {
        x0 = fresh_sym(p0);
        sym_set(x0, p1);
        assign(sym_name(x0), x0);
        return;
    };
    if (cons_p(p0) != nil_sym) {
        if (cons_p(p1) == nil_sym) {
            fputs(stderr, "ERROR: argument pattern mismatch ");
            pp_sexp(stderr, p2);
            fputs(stderr, ": ");
            pp_sexp(stderr, p0);
            fputs(stderr, " <-> ");
            pp_sexp(stderr, p1);
            fputs(stderr, "\n");
            exit(1);
        };
        match_args(car(p0), car(p1), p2);
        match_args(cdr(p0), cdr(p1), p2);
        return;
    };
    fputs(stderr, "ERROR: invalid argument pattern ");
    pp_sexp(stderr, p2);
    fputs(stderr, ": ");
    pp_sexp(stderr, p0);
    fputs(stderr, "\n");
    exit(1);
};

(% p0: lambda, p1: params %);
eval_applambda: (p0, p1) {
    allocate(1);
    scope_push();
    match_args(lambda_params(p0), eval_args(p1), p0);
    x0 = eval_sexp(lambda_body(p0));
    scope_pop();
    return x0;
};

(% p0: macro, p1: params %);
eval_appmacro: (p0, p1) {
    allocate(3);
    scope_push();
    match_args(macro_params(p0), p1, p0);
    x0 = eval_sexp(macro_body(p0));
    scope_pop();
    return eval_sexp(x0);
};

imported : NULL;

eval_import: (p0) {
    allocate(3);
    check_arity(p0, 1, "import");
    x0 = eval_sexp(car(p0));
    if (string_p(x0) == nil_sym) {
	fputs(stderr, "ERROR 'import': required string\n");
	exit(1);
    };
    x1 = string_value(x0);
    if (set_contains(imported, x1)) {
        return nil_sym;
    };
    set_add(imported, x1);
    x2 = parse_module(x1);
    while (x2 != nil_sym) {
	eval_sexp(car(x2));
	x2 = cdr(x2);
    };
    return nil_sym;
};

eval_sexp: (p0) {
    allocate(2);
    x0 = p0[0]; (% node code %);
    if (x0 == NODE_CONS)   { return eval_cons(p0); };
    if (x0 == NODE_SYMBOL) {
        x1 = deref(p0);
        if (sym_value(x1) != NULL) {
            return sym_value(x1);
        };
        return x1;
    };
    if (x0 == NODE_QUOTE) { return eval_quote(quote_sexp(p0)); };
    return p0;
};

init_evaluator: () {
    symbol_map = mkmap(&symbol_hash, &symbol_equal, 100);
    imported = mkset(&strhash, &streq, 10);
    scopeid_stack = mkvec(0);
    scope_push(); (% global scope %);
};

