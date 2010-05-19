(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: main.rl 2010-05-20 03:30:40 nineties $
 %);

(% rowl-core interpreter %);

include(stddef, code);

export main;

(% source file name %);
interpret: (p0) {
    allocate(2);
    x0 = parse(p0);

    init_builtin_objects();
    init_evaluator();

    while (x0 != NULL) {
        x1 = eval_sexp(rl_car(x0));
        pp_sexp(stdout, x1);
        fputc(stdout, '\n');
        x0 = rl_cdr(x0);
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

