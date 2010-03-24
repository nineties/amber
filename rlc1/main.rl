(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: main.rl 2010-03-24 22:21:05 nineties $
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

    (% lex and parse %);
    x0 = open_in(p0);
    x1 = parse(p0, x0);
    close_in(x0);

    (% type check %);
    typing(x1);

    (% translate to three address code %);
    x1 = tcodegen(x1);

    (% generate assembly %);
    x0 = open_out(change_suffix(p0, "s"));
    asmgen(x0, x1);
    close_out(x0);
};

ascmd: ["/usr/bin/as", NULL, "-o", NULL, NULL];
(% p0: filename %);
assemble: (p0) {
    allocate(1);
    x0 = fork(); (% pid %);
    if (x0 == 0) {
	(% child %);
	ascmd[1] = change_suffix(p0, "s");
	ascmd[3] = change_suffix(p0, "o");
	execve(ascmd[0], ascmd, 0);
    } else {
	waitpid(-1, &x1, 0);
    };
};

(% p0: argc, p1: argv %);
main: (p0, p1) {
    allocate(1);

    progname = strdup(p1[0]);

    x0 = 1;
    while (x0 < p0) {
        compile(p1[x0]);
	assemble(p1[x0]);
        x0 = x0 + 1;
    };
    exit(0);
};
