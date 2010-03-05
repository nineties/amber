(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: main.rl 2010-02-27 15:57:26 nineties $ 
 %);

include(stddef, code);

export main;

progname : NULL;

(% p0: file name, p1: suffix %);
gen_fname: (p0, p1) {
    allocate(1);
    x0 = memalloc(strlen(p0) + strlen(p1) + 1);
    strcpy(x0, p0);
    strcpy(x0 + strlen(p0), p1);
    return x0;
};

(% p0: filename %);
compile: (p0) {
    allocate(2);

    init_rewrite();

    x0 = open_in(gen_fname(p0, ".rl"));
    puts("parsing...");
    x1 = parse(p0, x0);
    close_in(x0);
    puts("done\n");
    puts("type checking...");
    typing(x1);
    puts("done\n");

    (%
    x0 = open_out(gen_fname(p0, ".s"));
    codegen(x0, x1);
    close_out(x0);
    %);
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
    exit(0);
};
