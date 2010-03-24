(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: main.rl 2010-03-24 13:47:31 nineties $
 %);

include(stddef, code);

export main;

progname : NULL;

(% rename xxx.rl to xxx.p1 %);
change_suffix: (p0, p1) {
    allocate(3);
    x0 = strlen(p0);
    x1 = strlen(p1);
    x2 = memalloc(x0 - 2 + x1 + 1);
    memcpy(x2, p0, x0 - 2);
    memcpy(x2 + x0 - 2, p1, x1);
    wch(x2, x0 - 2 + x1, '\0');
    return x2;
};

(% p0: filename %);
compile: (p0) {
    allocate(2);

    x0 = open_in(p0);
    puts("parsing...");
    x1 = parse(p0, x0);
    close_in(x0);
    puts("done\n");

    puts("type checking...");
    typing(x1);
    puts("done\n");

    puts("translating to three address code...");
    x1 = tcodegen(x1);
    puts("done\n");

    puts("generating assembly...");
    x0 = open_out(change_suffix(p0, "s"));
    asmgen(x0, x1);
    close_out(x0);
    puts("done\n");
};

(% p0: argc, p1: argv %);
main: (p0, p1) {
    allocate(1);

    progname = strdup(p1[0]);

    x0 = 1;
    while (x0 < p0) {
        compile(p1[x0]);
        x0 = x0 + 1;
    };
    puts("finished\n");
    exit(0);
};
