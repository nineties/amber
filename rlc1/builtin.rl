(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: builtin.rl 2010-05-20 15:30:16 nineties $
 %);

include(stddef,code);
export(init_builtin_objects);
export(nil_sym,true_sym, false_sym, add_sym);
export(mksym, mkint, mkchar, mkstring);
export(sym_set, sym_name, sym_value);
export(cons_p,sym_p,int_p,char_p,string_p,prim_p);
export(prim_funptr);
export(empty,cons,car,cdr,reverse);

(%
 % symbol object:
 % 0: NODE_SYMBOL
 % 1: symbol name
 % 2: associated object (default: nil symbol)
 %);

mksym: (p0) {
    return mktup3(NODE_SYMBOL, strdup(p0), nil_sym);
};

mksym2: (p0, p1) {
    return mktup3(NODE_SYMBOL, strdup(p0), p1);
};

sym_set: (p0, p1) {
    expect(p0, NODE_SYMBOL, "sym_set", "symbol object");
    p0[2] = p1;
};

sym_name: (p0) {
    expect(p0, NODE_SYMBOL, "sym_name", "symbol object");
    return p0[1];
};

sym_value: (p0) {
    expect(p0, NODE_SYMBOL, "sym_value", "symbol object");
    return p0[2];
};

mkint: (p0) {
    return mktup2(NODE_INT, p0);
};

int_value: (p0) {
    expect(p0, NODE_INT, "int_value", "integer object");
    return p0[1];
};

mkchar: (p0) {
    return mktup2(NODE_CHAR, p0);
};

char_value: (p0) {
    expect(p0, NODE_CHAR, "char_value", "character object");
    return p0[1];
};

mkstring: (p0) {
    return mktup2(NODE_STRING, strdup(p0));
};

string_value: (p0) {
    expect(p0, NODE_STRING, "string_value", "string object");
    return p0[1];
};

(% p0: code, p1: object %);
check_code: (p0, p1) {
    if (p1 != NULL) {
        if (p1[0] == p0) {
            return true_sym;
        }
    };
    return false_sym;
};

cons_p: (p0) {
    if (p0 == NULL) { return true_sym; };
    if (p0[0] == NODE_CONS) { return true_sym; };
    return false_sym;
};
sym_p   : (p0) { return check_code(NODE_SYMBOL, p0); };
int_p   : (p0) { return check_code(NODE_INT, p0); };
char_p  : (p0) { return check_code(NODE_CHAR, p0); };
sring_p : (p0) { return check_code(NODE_STRING, p0); };
prim_p  : (p0) { return check_code(NODE_PRIM, p0); };

prim_funptr: (p0) {
    expect(p0, NODE_PRIM, "prim_funptr", "primitive function");
    return p0[1];
};

(% p0: object, p1: expected code, p2: caller name, p3: object name %);
expect: (p0, p1, p2, p3) {
    if (p0 != NULL) {
        if (p0[0] == p1) { return; }
    };
    fputs(stderr, "ERROR: '");
    fputs(stderr, p2);
    fputs(stderr, "': ");
    fputs(stderr, p3);
    fputs(stderr, " is required\n");
    exit(1);
};

empty: () {
    return NULL;
};

cons: (p0, p1) {
    return mktup3(NODE_CONS, p0, p1);
};

car: (p0) {
    if (p0 == NULL) {
        fputs(stderr, "ERROR 'car': empty list\n");
        exit(1);
    };
    if (p0[0] != NODE_CONS) {
        fputs(stderr, "ERROR 'car': not a list\n");
    };
    return p0[1];
};

cdr: (p0) {
    if (p0 == NULL) {
        fputs(stderr, "ERROR 'cdr': empty list\n");
        exit(1);
    };
    if (p0[0] != NODE_CONS) {
        fputs(stderr, "ERROR 'car': not a list\n");
    };
    return p0[2];
};

reverse: (p0) {
    allocate(1);
    if (p0 == NULL) { return NULL; };
    if (p0[0] != NODE_CONS) {
        fputs(stderr, "ERROR 'car': not a list\n");
    };
    x0 = NULL;
    while (p0 != NULL) {
        x0 = cons(car(p0), x0);
        p0 = cdr(p0);
    };
    return x0;
};

(% primitive functions %);

(% p0: address of the function %);
mkprim: (p0) {
    return mktup2(NODE_PRIM, p0);
};

add: (p0) {
    allocate(2);
    x0 = 0;
    while (p0 != NULL ) {
        x1 = car(p0);
        expect(x1, NODE_INT, "add", "integer");
        x0 = x0 + int_value(x1);
        p0 = cdr(p0);
    };
    return mkint(x0);
};

print: (p0) {
    while (p0 != NULL) {
        x0 = car(p0);
        expect(x0, NODE_STRING, "print", "string");
        puts(string_value(x0));
        p0 = cdr(p0);
    };
    return nil_sym;
};

nil_sym     : NULL;
true_sym    : NULL;
false_sym   : NULL;
add_sym     : NULL;
print_sym   : NULL;

init_builtin_objects: () {
    nil_sym     = mksym("$nil");
    true_sym    = mksym("$true");
    false_sym   = mksym("$false");
    add_sym     = mksym2("$add", mkprim(&add));
    print_sym   = mksym2("$print", mkprim(&print));

    assign("$nil", nil_sym);
    assign("$true", true_sym);
    assign("$false", false_sym);
    assign("$add", add_sym);
    assign("$print", print_sym);
};
