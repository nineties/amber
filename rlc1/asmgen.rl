(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: asmgen.rl 2010-03-26 01:07:16 nineties $
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

SECTION_TEXT => 0;
SECTION_DATA => 1;

current_section: -1;
switch_section: (p0, p1) {
    if (p1 == current_section) { return; };
    current_section = p1;
    if (p1 == SECTION_TEXT) { return fputs(p0, ".text\n"); };
    if (p1 == SECTION_DATA) { return fputs(p0, ".data\n"); };
    not_reachable();
};

emit_opd: (p0, p1, p2) {
    if (p1[0] == OPD_INTEGER) {
	fputc(p0, '$');
	fputi(p0, p1[1]);
	return;
    };
    if (p1[0] == OPD_CHAR) {
	fputc(p0, '$');
	fputi(p0, p1[1]);
	return;
    };
    if (p1[0] == OPD_REGISTER) {
	fputs(p0, get_register_repr(p1, p2));
        return;
    };
    if (p1[0] == OPD_ADDRESS) {
        fputc(p0, '$');
        fputs(p0, p1[1]);
        return;
    };
    if (p1[0] == OPD_CONTENT) {
        fputs(p0, p1[1]);
        return;
    };
    not_implemented();
};

inst_string: ["movl", "pushl", "popl", "ret", "int", "call", "call"];
inst_prec:   [32,     32,      32,     32,    32   , "32",   "32"];

(% p0: output channel, p1: instruction %);
emit_inst: (p0, p1) {
    allocate(1);
    fputc(p0, '\t');
    fputs(p0, inst_string[p1[1]]);
    x0 = FALSE; (% insert comma %);
    if (p1[3] != NULL) {
	(% first operand %);
	fputc(p0, ' ');
	emit_opd(p0, p1[3], inst_prec[p1[1]]);
	x0 = TRUE;
    };
    if (p1[4] != NULL) {
	(% second operand %);
	if (x0) { fputc(p0, ','); };
	fputc(p0, ' ');
	emit_opd(p0, p1[4], inst_prec[p1[1]]);
	x0 = TRUE;
    };
    if (p1[2] != NULL) {
	(% output operand %);
	if (x0) { fputc(p0, ','); };
	fputc(p0, ' ');
	emit_opd(p0, p1[2], inst_prec[p1[1]]);
    };
    fputc(p0, '\n');
};

emit_extfuncs: [
    not_implemented, emit_data, emit_func, not_implemented
];

emit_static_data: (p0, p1) {
    allocate(3);
    if (p1[0] == DATA_CHAR) {
        fputs(p0, "\t.byte ");
        fputi(p0, p1[1]);
        fputc(p0, '\n');
        return;
    };
    if (p1[0] == DATA_INT) {
        fputs(p0, "\t.long ");
        fputi(p0, p1[1]);
        fputc(p0, '\n');
        return;
    };
    if (p1[0] == DATA_TUPLE) {
        x0 = p1[1]; (% length %);
        x1 = p1[2]; (% elements %);
        x2 = 0;
        while (x2 < x0) {
            emit_static_data(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return;
    };
    if (p1[0] == DATA_ARRAY) {
        x0 = p1[1]; (% length %);
        x1 = p1[2]; (% elements %);
        x2 = 0;
        while (x2 < x0) {
            emit_static_data(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return;
    };
    if (p1[0] == DATA_STRING) {
        fputs(p0, "\t.string \"");
        fputs(p0, p1[1]);
        fputs(p0, "\"\n");
        return;
    };
    if (p1[0] == DATA_LABEL) {
        fputs(p0, "\t.long ");
        fputs(p0, p1[1]);
        fputc(p0, '\n');
        return;
    };
    not_implemented();
};

emit_data: (p0, p1) {
    switch_section(p0, SECTION_DATA);
    if (p1[3]) {
        fputs(p0, ".global ");
        fputs(p0, p1[1]);
        fputc(p0, '\n');
    };
    fputs(p0, p1[1]); (% label %);
    fputs(p0, ":");
    emit_static_data(p0, p1[2]);
};

emit_func: (p0, p1) {
    allocate(1);
    switch_section(p0, SECTION_TEXT);
    if (p1[4]) {
        fputs(p0, ".global ");
        fputs(p0, p1[1]);
        fputc(p0, '\n');
    };
    fputs(p0, p1[1]); (% label %);
    fputs(p0, ":\n");
    x0 = p1[3]; (% instructions %);
    while (x0 != NULL) {
        emit_inst(p0, ls_value(x0));
        x0 = ls_next(x0);
    };
};

(% p0: output channel, p1: item %);
emit_extitem: (p0, p1) {
    allocate(1);
    x0 = emit_extfuncs[p1[0]];
    return x0(p0, p1);
};

(% p0: output channel, p1: instructions %);
asmgen: (p0, p1) {
    while (p1 != NULL) {
	emit_extitem(p0, ls_value(p1));
	p1 = ls_next(p1);
    };
};
