(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: builtin.rl 2010-05-22 02:54:41 nineties $
 %);

include(stddef,code);
export(init_builtin_objects);
export(mksym, mkint, mkchar, mkstring);
export(sym_set, sym_name, sym_value);
export(cons_p,sym_p,int_p,char_p,string_p,prim_p);
export(prim_funptr);
export(mkcons,car,cdr,length,reverse);
export(nil_sym,true_sym,false_sym,if_sym,while_sym);

(%
 % symbol object:
 % 0: NODE_SYMBOL
 % 1: symbol name
 % 2: associated object (default: nil symbol)
 %);

mkcons: (p0, p1) {
    return mktup3(NODE_CONS, p0, p1);
};

car: (p0) {
    expect(p0, NODE_CONS, "car", "cons object");
    return p0[1];
};

cdr: (p0) {
    expect(p0, NODE_CONS, "car", "cons object");
    return p0[2];
};

length: (p0) {
    allocate(2);
    x0 = 0;
    while (p0 != nil_sym) {
        p0 = cdr(p0);
        x0 = x0 + 1;
    };
    return x0;
};

reverse: (p0) {
    allocate(1);
    if (p0 == nil_sym) { return nil_sym; };
    if (p0[0] != NODE_CONS) {
        fputs(stderr, "ERROR 'reverse': not a list\n");
    };
    x0 = nil_sym;
    while (p0 != nil_sym) {
        x0 = mkcons(car(p0), x0);
        p0 = cdr(p0);
    };
    return x0;
};

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
    if (p1[0] == p0) {
        return true_sym;
    };
    return false_sym;
};

cons_p: (p0) {
    if (p0[0] == NODE_CONS) { return true_sym; };
    return false_sym;
};
sym_p    : (p0) { return check_code(NODE_SYMBOL, p0); };
int_p    : (p0) { return check_code(NODE_INT, p0); };
char_p   : (p0) { return check_code(NODE_CHAR, p0); };
string_p : (p0) { return check_code(NODE_STRING, p0); };
prim_p   : (p0) { return check_code(NODE_PRIM, p0); };

prim_funptr: (p0) {
    expect(p0, NODE_PRIM, "prim_funptr", "primitive function");
    return p0[1];
};

(% p0: object, p1: expected code, p2: caller name, p3: object name %);
expect: (p0, p1, p2, p3) {
    if (p0[0] == p1) { return; };
    fputs(stderr, "ERROR: '");
    fputs(stderr, p2);
    fputs(stderr, "': ");
    fputs(stderr, p3);
    fputs(stderr, " is required\n");
    exit(1);
};

(% primitive functions %);

(% p0: address of the function %);
mkprim: (p0) {
    return mktup2(NODE_PRIM, p0);
};

rl_cons: (p0) {
    check_arity(p0, 2, "cons");
    return mkcons(car(p0), car(cdr(p0)));
};

rl_car: (p0) {
    check_arity(p0, 1, "car");
    return car(car(p0));
};

rl_cdr: (p0) {
    check_arity(p0, 1, "cdr");
    return cdr(car(p0));
};

rl_length: (p0) {
    check_arity(p0, 1, "length");
    return length(car(p0));
};

rl_reverse: (p0) {
    check_arity(p0, 1, "reverse");
    return reverse(car(p0));
};

rl_add: (p0) {
    allocate(2);
    x0 = 0;
    while (p0 != nil_sym) {
        x1 = car(p0);
        expect(x1, NODE_INT, "add", "integer");
        x0 = x0 + int_value(x1);
        p0 = cdr(p0);
    };
    return mkint(x0);
};

rl_mul: (p0) {
    allocate(2);
    x0 = 1;
    while (p0 != nil_sym) {
        x1 = car(p0);
        expect(x1, NODE_INT, "mul", "integer");
        x0 = x0 * int_value(x1);
        p0 = cdr(p0);
    };
    return mkint(x0);
};

rl_print: (p0) {
    allocate(1);
    while (p0 != nil_sym) {
        x0 = car(p0);
        pp_sexp(stdout, x0);
        p0 = cdr(p0);
    };
    return nil_sym;
};

rl_getc: (p0) {
    if (p0 != nil_sym) {
        fputs(stderr, "ERROR 'getc': getc takes no arguments\n");
        exit(1);
    };
    return mkchar(getc());
};

nil_sym   : NULL;
true_sym  : NULL;
false_sym : NULL;
cons_sym  : NULL;
car_sym   : NULL;
cdr_sym   : NULL;
add_sym   : NULL;
mul_sym   : NULL;
print_sym : NULL;
getc_sym  : NULL;
if_sym    : NULL;
while_sym : NULL;

init_builtin_objects: () {
    nil_sym   = mksym("nil");
    true_sym  = mksym("true");
    false_sym = mksym("false");
    cons_sym  = mksym2("cons", mkprim(&rl_cons));
    car_sym   = mksym2("car", mkprim(&rl_car));
    cdr_sym   = mksym2("cdr", mkprim(&rl_cdr));
    add_sym   = mksym2("add", mkprim(&rl_add));
    mul_sym   = mksym2("mul", mkprim(&rl_mul));
    print_sym = mksym2("print", mkprim(&rl_print));
    getc_sym  = mksym2("getc", mkprim(&rl_getc));
    if_sym    = mksym("if");
    while_sym = mksym("while");

    assign("nil", nil_sym);
    assign("true", true_sym);
    assign("false", false_sym);
    assign("cons", cons_sym);
    assign("car", car_sym);
    assign("cdr", cdr_sym);
    assign("add", add_sym);
    assign("mul", mul_sym);
    assign("print", print_sym);
    assign("getc", getc_sym);
    assign("if", if_sym);
    assign("while", while_sym);
};
