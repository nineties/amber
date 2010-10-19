(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: main.rl 2010-10-19 14:04:36 nineties $
 %);

(% rowl-core interpreter %);

include(stddef, code);

export main;

(% source file name %);
interpret: (p0) {
    allocate(1);

    init_evaluator();
    init_builtin_objects();

    x0 = parse(p0);
    while (x0 != nil_sym) {
        eval_sexp(car(x0));
        x0 = cdr(x0);
    }
};

usage: (p0) {
    puts("USAGE: ");
    puts(p0);
    puts(" [file]\n");
};

(% p0: argc, p1: argv %);
main: (p0, p1) {
    if (p0 < 2) {
        usage(p1[0]);
        return 1;
    };
    interpret(p1[1]);
    return 0;
};

