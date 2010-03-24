(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: asmgen.rl 2010-03-24 13:48:37 nineties $
 %);

include(stddef, code);
export(asmgen);

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

ext_tcode: (p0, p1) {
    if (p1[0] == TCODE_LABEL) {
	fputs(p0, p1[1]);
	fputs(p0, ":\n");
	return;
    };
    not_implemented();
};

(% p0: output channel, p1: instructions %);
asmgen: (p0, p1) {
    allocate(1);

    while (p1 != NULL) {
	ext_tcode(p0, ls_value(p1));
	p1 = ls_next(p1);
    };
};
