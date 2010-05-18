(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: builtin.rl 2010-05-19 04:53:02 nineties $
 %);

include(stddef,code);
export(rl_empty,rl_cons,rl_car,rl_cdr,rl_reverse);

rl_empty: () {
    return NULL;
};

rl_cons: (p0, p1) {
    return mktup3(NODE_CONS, p0, p1);
};

rl_car: (p0) {
    if (p0 == NULL) {
        fputs(stderr, "ERROR 'car': empty list\n");
        exit(1);
    };
    if (p0[0] != NODE_CONS) {
        fputs(stderr, "ERROR 'car': not a list\n");
    };
    return p0[1];
};

rl_cdr: (p0) {
    if (p0 == NULL) {
        fputs(stderr, "ERROR 'cdr': empty list\n");
        exit(1);
    };
    if (p0[0] != NODE_CONS) {
        fputs(stderr, "ERROR 'car': not a list\n");
    };
    return p0[2];
};

rl_reverse: (p0) {
    allocate(1);
    if (p0 == NULL) { return NULL; };
    if (p0[0] != NODE_CONS) {
        fputs(stderr, "ERROR 'car': not a list\n");
    };
    x0 = NULL;
    while (p0 != NULL) {
        x0 = rl_cons(rl_car(p0), x0);
        p0 = rl_cdr(p0);
    };
    return x0;
};
