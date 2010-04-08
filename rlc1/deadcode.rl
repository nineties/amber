(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: deadcode.rl 2010-04-09 07:57:38 nineties $
 %);

include(stddef, code);
export(eliminate_deadcode);

changed: FALSE;

(% opcode to functor %);
iterate_funcs: [
    iterate_normal, iterate_nothing, iterate_nothing, iterate_nothing, iterate_normal,
    iterate_nothing, iterate_nothing, iterate_nothing, iterate_normal, iterate_normal,
    iterate_normal, iterate_div, iterate_mod, iterate_normal, iterate_normal,
    iterate_normal, iterate_normal, iterate_normal, iterate_normal, iterate_normal,
    iterate_normal, iterate_normal, iterate_normal, iterate_nothing, iterate_load,
    iterate_nothing, iterate_nothing, iterate_nothing, iterate_nothing, iterate_nothing,
    iterate_nothing, iterate_nothing, iterate_nothing, iterate_nothing
];

register_contains: (p0, p1) {
    return iset_contains(p1, p0[1]);
};

register_is_used: (p0, p1) {
    if (p1 == NULL) { return FALSE; };
    return register_contains(p0, (ls_value(p1))[INST_LIVEIN]);
};

output_is_used: (p0, p1) {
    if (opd1_is_output(p0)) {
	if (register_is_used(p0[INST_OPERAND1], p1)) {
	    return TRUE;
	};
        if (is_local_operand(p0[INST_OPERAND1]) == FALSE) {
            return TRUE;
        };
    };
    if (opd2_is_output(p0)) {
	if (register_is_used(p0[INST_OPERAND2], p1)) {
	    return TRUE;
	};
        if (is_local_operand(p0[INST_OPERAND2]) == FALSE) {
            return TRUE;
        };
    };
    return FALSE;
};

(% p0: list of instructions: live-out register at final%);
iterate_normal: (p0) {
    allocate(2);
    x0 = iterate(ls_next(p0));
    x1 = ls_value(p0);

    if (output_is_used(x1, x0) == FALSE) {
	(% this is a dead instruction %);
	changed = TRUE;
	return x0;
    };
    return ls_cons(x1, x0);
};

iterate_nothing: (p0) {
    allocate(2);
    x0 = iterate(ls_next(p0));
    x1 = ls_value(p0);
    return ls_cons(x1, x0);
};

iterate_div: (p0) {
    allocate(2);
    x0 = iterate(ls_next(p0));
    x1 = ls_value(p0);

    if (register_is_used(get_eax(), x0) == FALSE) {
        (% this is a dead instruction %);
        changed = TRUE;
        return x0;
    };
    return ls_cons(x1, x0);
};

iterate_mod: (p0) {
    allocate(2);
    x0 = iterate(ls_next(p0));
    x1 = ls_value(p0);

    if (register_is_used(get_edx(), x0) == FALSE) {
        (% this is a dead instruction %);
        changed = TRUE;
        return x0;
    };
    return ls_cons(x1, x0);
};

iterate_load: (p0) {
    allocate(2);
    x0 = iterate(ls_next(p0));
    x1 = ls_value(p0);
    if (output_is_used(x1, x0) == FALSE) {
        (% this is a dead instruction %);
        changed = TRUE;
        return x0;
    };
    return ls_cons(x1, x0);
};

iterate: (p0) {
    allocate(3);
    if (p0 == NULL) { return p0; };
    x0 = ls_value(p0);
    x1 = iterate_funcs[x0[INST_OPCODE]];
    return x1(p0);
};

(% p0: TCODE_FUNC object %);
eliminate_deadcode: (p0) {
    changed = TRUE;
    while (changed) {
        changed = FALSE;
        liveness(p0);
        p0[3] = iterate(p0[3]);
    };
};
