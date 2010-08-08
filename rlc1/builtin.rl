(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: builtin.rl 2010-08-08 12:57:59 nineties $
 %);

include(stddef,code);
export(init_builtin_objects);
export(mkign);
export(mksym, sym_set, sym_name, sym_value, fresh_sym);
export(mkint, int_value);
export(mkchar, char_value);
export(mkstring, string_value);
export(mkarray, array_size, array_get, array_set);
export(mklambda,lambda_arity,lambda_params,lambda_body);
export(mkmacro,macro_arity,macro_params,macro_body);
export(mkquote,quote_sexp);
export(mkunquote,unquote_sexp);
export(cons_p,sym_p,ign_p,int_p,char_p,string_p,prim_p,array_p,lambda_p,macro_p,quote_p,unquote_p);
export(prim_funptr);
export(mkcons,car,cdr,cadr,caddr,length,reverse);
export(nil_sym,true_sym,var_sym,set_sym,quote_sym,unquote_sym,if_sym,cond_sym,
    while_sym,do_sym,lambda_sym,macro_sym,foreach_sym,import_sym);

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
    expect(p0, NODE_CONS, "cdr", "cons object");
    return p0[2];
};

cadr  : (p0) { return car(cdr(p0)); };
caddr : (p0) { return car(cdr(cdr(p0))); };
cddr  : (p0) { return cdr(cdr(p0)); };

(% p0: list, p1: index %);
nth: (p0, p1) {
    while (p1 > 0) {
        p0 = cdr(p0);
        p1 = p1-1;
    };
    return car(p0);
};

append: (p0, p1) {
    allocate(1);
    if (p0 == nil_sym) { return p1; };
    x0 = p0;
    while (x0[2] != nil_sym) {
        x0 = x0[2];
    };
    x0[2] = p1;
    return p0;
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

mkign: () {
    return mktup1(NODE_IGNORE)
};

mksym: (p0) {
    return mktup3(NODE_SYMBOL, strdup(p0), NULL);
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

fresh_sym: (p0) {
    expect(p0, NODE_SYMBOL, "fresh_sym", "symbol object");
    return mksym(sym_name(p0));
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

(% p0: init, p1: size (as int) %);
mkarray: (p0, p1) {
    allocate(2);
    x0 = memalloc(p1*4);
    x1 = 0;
    while (x1 < p1) {
        x0[x1] = p0;
        x1 = x1 + 1;
    };
    return mktup3(NODE_ARRAY, p1, x0);
};

array_size: (p0) {
    expect(p0, NODE_ARRAY, "array_size", "array object");
    return p0[1];
};

(% p0: array object, p1: index (as int) %);
array_get: (p0, p1) {
    allocate(1);
    expect(p0, NODE_ARRAY, "array_get", "array object");
    if (p1 < 0) { index_error("array_get"); };
    if (p1 >= array_size(p0)) { index_error("array_get"); };
    x0 = p0[2];
    return x0[p1];
};

(% p0: array object, p1: index (as int), p2: value %);
array_set: (p0, p1, p2) {
    allocate(1);
    expect(p0, NODE_ARRAY, "array_get", "array_object");
    if (p1 < 0) { index_error("array_set"); };
    if (p1 >= array_size(p0)) { index_error("array_set"); };
    x0 = p0[2];
    x0[p1] = p2;
};

index_error: (p0) {
    fputs(stderr, "ERROR '");
    fputs(stderr, p0);
    fputs(stderr, "' : index out of range\n");
    exit(1);
};

(% p0: params, p1: body %);
mklambda: (p0, p1) {
    return mktup3(NODE_LAMBDA, p0, p1);
};

lambda_params: (p0) {
    expect(p0, NODE_LAMBDA, "lambda_params", "lambda object");
    return p0[1];
};

lambda_body: (p0) {
    expect(p0, NODE_LAMBDA, "lambda_body", "lambda object");
    return p0[2];
};

lambda_arity: (p0) {
    return length(lambda_params(p0));
};

(% p0: params, p1: body %);
mkmacro: (p0, p1) {
    expect(p0, NODE_CONS, "macro", "list of parameters");
    return mktup3(NODE_MACRO, p0, p1);
};

macro_params: (p0) {
    expect(p0, NODE_MACRO, "macro_params", "macro object");
    return p0[1];
};

macro_body: (p0) {
    expect(p0, NODE_MACRO, "macro_body", "macro object");
    return p0[2];
};

macro_arity: (p0) {
    return length(macro_params(p0));
};

(% p0: sexp %);
mkquote: (p0) {
    return mktup2(NODE_QUOTE, p0);
};

quote_sexp: (p0) {
    expect(p0, NODE_QUOTE, "quote_sexp", "quoted S-expression");
    return p0[1];
};

(% p0: sexp %);
mkunquote: (p0) {
    return mktup2(NODE_UNQUOTE, p0);
};

unquote_sexp: (p0) {
    expect(p0, NODE_UNQUOTE, "unquote_sexp", "unquoted S-expression");
    return p0[1];
};

(% p0: code, p1: object %);
check_code: (p0, p1) {
    if (p1[0] == p0) {
        return true_sym;
    };
    return nil_sym;
};

cons_p    : (p0) { return check_code(NODE_CONS, p0); };
sym_p     : (p0) { return check_code(NODE_SYMBOL, p0); };
ign_p     : (p0) { return check_code(NODE_IGNORE, p0); };
int_p     : (p0) { return check_code(NODE_INT, p0); };
char_p    : (p0) { return check_code(NODE_CHAR, p0); };
string_p  : (p0) { return check_code(NODE_STRING, p0); };
prim_p    : (p0) { return check_code(NODE_PRIM, p0); };
array_p   : (p0) { return check_code(NODE_ARRAY, p0); };
lambda_p  : (p0) { return check_code(NODE_LAMBDA, p0); };
macro_p   : (p0) { return check_code(NODE_MACRO, p0); };
quote_p   : (p0) { return check_code(NODE_QUOTE, p0); };
unquote_p : (p0) { return check_code(NODE_UNQUOTE, p0); };

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
    fputs(stderr, " is required (");
    pp_sexp(stderr, p0);
    fputs(stderr, ")\n");
    exit(1);
};

(% primitive functions %);

(% p0: S-expression %);
rl_eval: (p0) {
    check_arity(p0, 1, "eval");
    return eval_sexp(car(p0));
};

(% p0: address of the function %);
mkprim: (p0) {
    return mktup2(NODE_PRIM, p0);
};

(% p0: args, p1: name, p2: address of xxx_p %);
rl_xxx_p: (p0, p1, p2) {
    check_arity(p0, 1, p1);
    return p2(car(p0));
};

rl_cons_p   : (p0) { return rl_xxx_p(p0, "cons?", &cons_p); };
rl_symbol_p : (p0) { return rl_xxx_p(p0, "symbol?", &sym_p); };
rl_int_p    : (p0) { return rl_xxx_p(p0, "int?", &int_p); };
rl_char_p   : (p0) { return rl_xxx_p(p0, "char?", &char_p); };
rl_string_p : (p0) { return rl_xxx_p(p0, "string?", &string_p); };
rl_array_p  : (p0) { return rl_xxx_p(p0, "array?", &array_p); };

rl_cons: (p0) {
    check_arity(p0, 2, "cons");
    return mkcons(car(p0), cadr(p0));
};

rl_car: (p0) {
    check_arity(p0, 1, "car");
    return car(car(p0));
};

rl_cdr: (p0) {
    check_arity(p0, 1, "cdr");
    return cdr(car(p0));
};

rl_setcar: (p0) {
    allocate(1);
    check_arity(p0, 2, "setcar");
    x0 = car(p0);
    x0[1] = cadr(p0);
};

rl_setcdr: (p0) {
    allocate(1);
    check_arity(p0, 2, "setcdr");
    x0 = car(p0);
    x0[2] = cadr(p0);
};

rl_append: (p0) {
    allocate(2);
    check_arity(p0, 2, "append");
    x0 = car(p0);
    x1 = cadr(p0);
    return append(x0, x1);
};

rl_length: (p0) {
    check_arity(p0, 1, "length");
    return mkint(length(car(p0)));
};

rl_reverse: (p0) {
    check_arity(p0, 1, "reverse");
    return reverse(car(p0));
};

rl_list: (p0) {
    return p0;
};

(% (string_get str idx) %);
rl_string_get: (p0) {
    allocate(2);
    check_arity(p0, 2, "string_get");
    x0 = car(p0);
    x1 = int_value(cadr(p0));
    return mkchar(rch(string_value(x0), x1));
};

(% (string_len str) %);
rl_string_len: (p0) {
    check_arity(p0, 1, "string_len");
    x0 = car(p0);
    return mkint(strlen(string_value(x0)));
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

rl_sub: (p0) {
    allocate(2);
    check_arity(p0, 2, "sub");
    x0 = int_value(car(p0));
    x1 = int_value(cadr(p0));
    return mkint(x0-x1);
};

rl_mul: (p0) {
    allocate(2);
    x0 = int_value(car(p0));
    p0 = cdr(p0);
    while (p0 != nil_sym) {
        x1 = car(p0);
        expect(x1, NODE_INT, "mul", "integer");
        x0 = x0 * int_value(x1);
        p0 = cdr(p0);
    };
    return mkint(x0);
};

rl_div: (p0) {
    allocate(2);
    check_arity(p0, 2, "div");
    x0 = int_value(car(p0));
    x1 = int_value(cadr(p0));
    return mkint(x0/x1);
};

rl_mod: (p0) {
    allocate(2);
    check_arity(p0, 2, "mod");
    x0 = int_value(car(p0));
    x1 = int_value(cadr(p0));
    return mkint(x0%x1);
};

rl_bitnot: (p0) {
    allocate(1);
    check_arity(p0, 1, "bitnot");
    x0 = int_value(car(p0));
    return mkint(~x0);
};

rl_bitand: (p0) {
    allocate(2);
    x0 = int_value(car(p0));
    p0 = cdr(p0);
    while (p0 != nil_sym) {
        x1 = car(p0);
        expect(x1, NODE_INT, "bitand", "integer");
        x0 = x0 & int_value(x1);
        p0 = cdr(p0);
    };
    return mkint(x0);
};

rl_bitxor: (p0) {
    allocate(2);
    x0 = int_value(car(p0));
    p0 = cdr(p0);
    while (p0 != nil_sym) {
        x1 = car(p0);
        expect(x1, NODE_INT, "bitxor", "integer");
        x0 = x0 ^ int_value(x1);
        p0 = cdr(p0);
    };
    return mkint(x0);
};

rl_bitor: (p0) {
    allocate(2);
    x0 = int_value(car(p0));
    p0 = cdr(p0);
    while (p0 != nil_sym) {
        x1 = car(p0);
        expect(x1, NODE_INT, "bitor", "integer");
        x0 = x0 | int_value(x1);
        p0 = cdr(p0);
    };
    return mkint(x0);
};

rl_lshift: (p0) {
    allocate(2);
    check_arity(p0, 2, "lshift");
    x0 = int_value(car(p0));
    x1 = int_value(cadr(p0));
    while (x1 > 0) {
        x0 = 2*x0;
        x1 = x1 - 1;
    };
    return mkint(x0);
};

rl_rshift: (p0) {
    allocate(2);
    check_arity(p0, 2, "rshift");
    x0 = int_value(car(p0));
    x1 = int_value(cadr(p0));
    while (x1 > 0) {
        x0 = x0/2;
        x1 = x1 - 1;
    };
    return mkint(x0);
};

(% p0: operator name, p1: args, p2: pointer to the function %);
int_binop_helper: (p0, p1, p2) {
    allocate(2);
    check_arity(p1, 2, p0);
    x0 = car(p1);
    x1 = cadr(p1);
    expect(x0, NODE_INT, p0, "integer");
    expect(x1, NODE_INT, p0, "integer");
    return p2(int_value(x0), int_value(x1));
};

_lt: (p0, p1) { if (p0 < p1) { return true_sym; } else { return nil_sym; } };
_gt: (p0, p1) { if (p0 > p1) { return true_sym; } else { return nil_sym; } };
_le: (p0, p1) { if (p0 <= p1) { return true_sym; } else { return nil_sym; } };
_ge: (p0, p1) { if (p0 >= p1) { return true_sym; } else { return nil_sym; } };
rl_lt: (p0) { return int_binop_helper("lt", p0, &_lt); };
rl_gt: (p0) { return int_binop_helper("gt", p0, &_gt); };
rl_le: (p0) { return int_binop_helper("le", p0, &_le); };
rl_ge: (p0) { return int_binop_helper("ge", p0, &_ge); };

_eq: (p0, p1) {
    if (p0[0] != p1[0]) { return FALSE; };
    if (p0[0] == NODE_CONS) {
        if (_eq(car(p0), car(p1)) == FALSE) { return TRUE; };
        return _eq(cdr(p0), cdr(p1));
    };
    if (p0[0] == NODE_SYMBOL) { return streq(sym_name(p0), sym_name(p1)); };
    if (p0[0] == NODE_INT)    { return int_value(p0) == int_value(p1); };
    if (p0[0] == NODE_CHAR)   { return char_value(p0) == char_value(p1); };
    if (p0[0] == NODE_PRIM)   { return prim_funptr(p0) == prim_funptr(p1); };
    return FALSE;
};

rl_eq: (p0) {
    check_arity(p0, 2, "eq");
    if (_eq(car(p0), cadr(p0))) { return true_sym; };
    return nil_sym;
};

rl_ne: (p0) {
    check_arity(p0, 2, "ne");
    if (_eq(car(p0), cadr(p0))) { return nil_sym; };
    return true_sym;
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

rl_eprint: (p0) {
    allocate(1);
    while (p0 != nil_sym) {
        x0 = car(p0);
        pp_sexp(stderr, x0);
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

(% (array <init> <len>) %);
rl_array: (p0) {
    allocate(2);
    check_arity(p0, 2, "array");
    x0 = car(p0); (% init value %);
    x1 = int_value(cadr(p0)); (% size %);
    return mkarray(x0, x1);
};

(% (array_get <array> <index>) %);
rl_array_get: (p0) {
    allocate(2);
    check_arity(p0, 2, "array_get");
    x0 = car(p0); (% array %);
    x1 = int_value(cadr(p0)); (% index %);
    return array_get(x0, x1);
};

(% (array_set <array> <index> <value>) %);
rl_array_set: (p0) {
    allocate(3);
    check_arity(p0, 3, "array_set");
    x0 = car(p0); (% array %);
    x1 = int_value(cadr(p0)); (% index %);
    x2 = caddr(p0); (% value %);
    array_set(x0, x1, x2);
    return nil_sym;
};

(% (syscall <syscall-id> <arguments as int> %);
rl_syscall: (p0) {
    x0 = int_value(car(p0));
    p0 = cdr(p0);
    x1 = length(p0);
    if (x1 == 0) { return syscall(x0); };
    if (x1 == 1) { return syscall(x0, int_value(car(p0))); };
    if (x1 == 2) {
        return syscall(x0,
            int_value(car(p0)),
            int_value(cadr(p0)));
    };
    if (x1 == 3) {
        return syscall(x0,
            int_value(car(p0)),
            int_value(cadr(p0)),
            int_value(caddr(p0)));
    };
    if (x1 == 3) {
        return syscall(x0,
            int_value(car(p0)),
            int_value(cadr(p0)),
            int_value(caddr(p0)),
            int_value(nth(p0, 3)));
    };
    if (x1 == 4) {
        return syscall(x0,
            int_value(car(p0)),
            int_value(cadr(p0)),
            int_value(caddr(p0)),
            int_value(nth(p0, 3)),
            int_value(nth(p0, 4)));
    };
    if (x1 == 4) {
        return syscall(x0,
            int_value(car(p0)),
            int_value(cadr(p0)),
            int_value(caddr(p0)),
            int_value(nth(p0, 3)),
            int_value(nth(p0, 4)),
            int_value(nth(p0, 5)));
    };
    fputs(stderr, "ERROR 'syscall': too many arguments\n");
    exit(1);
};

rl_exit: (p0) {
    check_arity(p0, 1, "exit");
    exit(int_value(car(p0)));
};

rl_char2int: (p0) {
    allocate(1);
    check_arity(p0, 1, "char2int");
    x0 = char_value(car(p0));
    return mkint(x0);
};

tosbuf: char [12];
rl_int2s: (p0) {
    allocate(2);
    check_arity(p0, 1, "int2s");
    x1 = int_value(car(p0));
    if (x1 < 0) { x1 = -x1; };

    wch(tosbuf, 11, '\0');
    wch(tosbuf, 10, x1%10 + '0');
    x0 = 10; (% index %);
    x1 = x1/10;
    while (x1 != 0) {
        x0 = x0 - 1;
        wch(tosbuf, x0, x1%10 + '0');
        x1 = x1/10;
    };
    if (int_value(car(p0)) < 0) {
        x0 = x0 - 1;
        wch(tosbuf, x0, '-');
    };
    return mkstring(tosbuf+x0);
};

rl_char2s: (p0) {
    check_arity(p0, 1, "char2s");
    wch(tosbuf, 0, char_value(car(p0)));
    wch(tosbuf, 1, '\0');
    return mkstring(tosbuf);
};

rl_symbol2s: (p0) {
    check_arity(p0, 1, "symbol2s");
    return mkstring(sym_name(car(p0)));
};

rl_tosym: (p0) {
    check_arity(p0, 1, "tosym");
    return mksym(string_value(car(p0)));
};

rl_sappend: (p0) {
    allocate(5);
    x0 = p0;
    x1 = 0; (% total length %);
    while (x0 != nil_sym) {
        x1 = x1 + strlen(string_value(car(x0)));
        x0 = cdr(x0);
    };
    x2 = memalloc(x1 + 1);
    x0 = p0;
    x3 = 0;
    while (x0 != nil_sym) {
        x4 = string_value(car(x0));
        strcpy(x2+x3, x4);
        x3 = x3 + strlen(x4);
        x0 = cdr(x0);
    };
    wch(x2, x1, '\0');
    return mkstring(x2);
};

rl_put_byte: (p0) {
    allocate(1);
    check_arity(p0, 1, "put_byte");
    x0 = int_value(car(p0));
    putc(x0);
    return nil_sym;
};

rl_put_short: (p0) {
    allocate(1);
    check_arity(p0, 1, "put_short");
    x0 = int_value(car(p0));

    putc(x0&255);
    putc((x0/256)&255);
    return nil_sym;
};

rl_put_long: (p0) {
    allocate(1);
    check_arity(p0, 1, "put_long");
    x0 = int_value(car(p0));
    putc(x0&255);
    putc((x0/256)&255);
    putc((x0/65536)&255);
    putc((x0/16777216)&255);
    return nil_sym;
};

rl_put_str: (p0) {
    allocate(1);
    check_arity(p0, 1, "put_str");
    x0 = string_value(car(p0));
    puts(x0);
    putc('\0');
    return nil_sym;
};

rl_assoc: (p0) {
    allocate(3);
    check_arity(p0, 2, "assoc");
    x0 = car(p0);   (% key %);
    x1 = cadr(p0);  (% list %);
    while (x1 != nil_sym) {
        x2 = car(x1); (% (key . val) %);
        if (_eq(x0, car(x2))) {
            return cdr(x2);
        };
        x1 = cdr(x1);
    };
    return nil_sym;
};

nil_sym    : NULL;
true_sym   : NULL;
var_sym    : NULL;
set_sym    : NULL;
if_sym     : NULL;
cond_sym   : NULL;
while_sym  : NULL;
do_sym     : NULL;
lambda_sym : NULL;
macro_sym  : NULL;
foreach_sym: NULL;
import_sym : NULL;

(% p0: name %);
register_sym: (p0) {
    allocate(1);
    x0 = mksym(p0);
    assign(p0, x0);
    return x0;
};

(% p0: name, p1: address of function %);
register_prim: (p0, p1) {
    assign(p0, mksym2(p0, mkprim(p1)));
};

init_builtin_objects: () {
    nil_sym     = register_sym("nil");
    true_sym    = register_sym("true");
    var_sym     = register_sym("var");
    set_sym     = register_sym("set");
    if_sym      = register_sym("if");
    cond_sym    = register_sym("cond");
    while_sym   = register_sym("while");
    do_sym      = register_sym("do");
    lambda_sym  = register_sym("lambda");
    macro_sym   = register_sym("macro");
    foreach_sym = register_sym("foreach");
    import_sym  = register_sym("import");

    register_prim("eval"       , &rl_eval);
    register_prim("cons"       , &rl_cons);
    register_prim("car"        , &rl_car);
    register_prim("cdr"        , &rl_cdr);
    register_prim("setcar"     , &rl_setcar);
    register_prim("setcdr"     , &rl_setcdr);
    register_prim("append"     , &rl_append);
    register_prim("length"     , &rl_length);
    register_prim("reverse"    , &rl_reverse);
    register_prim("list"       , &rl_list);
    register_prim("string_len" , &rl_string_len);
    register_prim("string_get" , &rl_string_get);
    register_prim("array"      , &rl_array);
    register_prim("array_get"  , &rl_array_get);
    register_prim("array_set"  , &rl_array_set);
    register_prim("cons?"      , &rl_cons_p);
    register_prim("symbol?"    , &rl_symbol_p);
    register_prim("int?"       , &rl_int_p);
    register_prim("char?"      , &rl_char_p);
    register_prim("string?"    , &rl_string_p);
    register_prim("array?"     , &rl_array_p);
    register_prim("add"        , &rl_add);
    register_prim("sub"        , &rl_sub);
    register_prim("mul"        , &rl_mul);
    register_prim("div"        , &rl_div);
    register_prim("mod"        , &rl_mod);
    register_prim("bitnot"     , &rl_bitnot);
    register_prim("bitand"     , &rl_bitand);
    register_prim("bitor"      , &rl_bitor);
    register_prim("bitxor"     , &rl_bitxor);
    register_prim("lshift"     , &rl_lshift);
    register_prim("rshift"     , &rl_rshift);
    register_prim("lt"         , &rl_lt);
    register_prim("gt"         , &rl_gt);
    register_prim("le"         , &rl_le);
    register_prim("ge"         , &rl_ge);
    register_prim("eq"         , &rl_eq);
    register_prim("ne"         , &rl_ne);
    register_prim("print"      , &rl_print);
    register_prim("eprint"     , &rl_eprint);
    register_prim("getc"       , &rl_getc);
    register_prim("syscall"    , &rl_syscall);
    register_prim("exit"       , &rl_exit);
    register_prim("char2int"   , &rl_char2int);
    register_prim("int2s"      , &rl_int2s);
    register_prim("char2s"     , &rl_char2s);
    register_prim("symbol2s"   , &rl_symbol2s);
    register_prim("tosym"      , &rl_tosym);
    register_prim("sappend"    , &rl_sappend);
    register_prim("put_byte"   , &rl_put_byte);
    register_prim("put_short"  , &rl_put_short);
    register_prim("put_long"   , &rl_put_long);
    register_prim("put_str"    , &rl_put_str);
    register_prim("assoc"      , &rl_assoc);
};
