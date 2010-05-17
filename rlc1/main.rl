(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: main.rl 2010-05-18 02:48:10 nineties $
 %);

(% rowl-core interpreter %);

include(stddef, code);

export main;

(% source file name %);
interpret: (p0) {
    allocate(1);
    x0 = open_in(p0);
    lexer_test(x0);
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

