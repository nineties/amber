(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: deadcode.rl 2010-04-07 17:55:36 nineties $
 %);

include(stddef, code);
export(eliminate_deadcode);

changed: FALSE;

register_contains: (p0, p1) {
    assert(p1 != NULL);
    return iset_contains(p0, p1[1]);
};

(% opcode to functor %);
iterate_funcs: [
    iterate_normal, iterate_normal, iterate_normal, iterate_ret, iterate_normal,
    iterate_int, iterate_call, iterate_call, iterate_normal, iterate_normal,
    iterate_normal, iterate_div, iterate_mod, iterate_normal, iterate_normal,
    iterate_normal, iterate_normal, iterate_normal, iterate_normal, iterate_normal,
    iterate_normal, iterate_normal, iterate_leal, iterate_store, iterate_load,
    iterate_nothing, iterate_nothing, iterate_nothing, iterate_nothing, iterate_nothing,
    iterate_nothing, iterate_nothing, iterate_nothing, iterate_nothing
];

register_is_used: (p0, p1) {
    return register_contains(p0, p1);
};

output_is_used: (p0, p1) {
    if (opd1_is_output(p1)) {
	if (register_is_used(p0, p1[INST_OPERAND1])) {
	    return TRUE;
	};
        if (is_local_operand(p1[INST_OPERAND1]) == FALSE) {
            return TRUE;
        };
    };
    if (opd2_is_output(p1)) {
	if (register_is_used(p0, p1[INST_OPERAND2])) {
	    return TRUE;
	};
        if (is_local_operand(p1[INST_OPERAND2]) == FALSE) {
            return TRUE;
        };
    };
    return FALSE;
};

(% p0: list of instructions, p1: live-out register at final%);
iterate_normal: (p0, p1) {
    allocate(3);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;

    if (output_is_used(x2, x1) == FALSE) {
	(% this is a dead instruction %);
	changed = TRUE;
	return x0;
    };

    x2 = output_del(x2, x1);
    x2 = input_add(x2, x1);
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_nothing: (p0, p1) {
    allocate(3);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;

    x2 = output_del(x2, x1);
    x2 = input_add(x2, x1);
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_ret: (p0, p1) {
    allocate(3);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = mkiset();
    if (x1[INST_ARG]) {
        (% retval instruction %);
        x2 = register_add(x2, get_eax());
    };
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_int: (p0, p1) {
    allocate(5);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;
    x2 = register_del(x2, get_eax());

    x3 = x1[INST_ARG];
    x4 = 0;
    while (x4 < x3) {
        x2 = register_add(x2, get_physical_reg(x4));
        x4 = x4 + 1;
    };
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_call: (p0, p1) {
    allocate(5);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;
    x2 = register_del(x2, get_eax());
    x2 = input_add(x2, x1);
    x3 = x1[INST_ARG];
    x4 = 0;
    while (x4 < x3) {
        x2 = register_add(x2, get_stack(x4));
        x4 = x4 + 1;
    };
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_div: (p0, p1) {
    allocate(3);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;

    if (register_contains(x2, get_eax()) == FALSE) {
        (% this is a dead instruction %);
        changed = TRUE;
        return x0;
    };

    x2 = register_del(x2, get_eax());
    x2 = register_add(x2, x1[INST_OPERAND1]);
    x2 = register_add(x2, get_eax());
    x2 = register_add(x2, get_edx());
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_mod: (p0, p1) {
    allocate(3);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;

    if (register_contains(x2, get_edx()) == FALSE) {
        (% this is a dead instruction %);
        changed = TRUE;
        return x0;
    };
    x2 = register_del(x2, get_edx());
    x2 = register_add(x2, x1[INST_OPERAND1]);
    x2 = register_add(x2, get_eax());
    x2 = register_add(x2, get_edx());
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_leal: (p0, p1) {
    allocate(3);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;
    if (register_contains(x2, x1[INST_OPERAND2]) == FALSE) {
        (% this is a dead instruction %);
        changed = TRUE;
        return x0;
    };
    x2 = register_del(x2, x1[INST_OPERAND2]);
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_store: (p0, p1) {
    allocate(3);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;
    x2 = register_add(x2, x1[INST_OPERAND1]);
    x2 = register_add(x2, x1[INST_OPERAND2]);
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate_load: (p0, p1) {
    allocate(3);
    x0 = iterate(ls_next(p0), p1);
    x1 = ls_value(p0);
    x2 = *p1;
    x2 = register_add(x2, x1[INST_OPERAND1]);
    x2 = register_del(x2, x1[INST_OPERAND2]);
    *p1 = x2;
    return ls_cons(x1, x0);
};

iterate: (p0, p1) {
    allocate(2);
    if (p0 == NULL) { return p0; };
    x0 = ls_value(p0);
    x1 = iterate_funcs[x0[INST_OPCODE]];
    return x1(p0, p1);
};

(% p0: TCODE_FUNC object %);
eliminate_deadcode: (p0) {
    allocate(1);
    changed = TRUE;
    while (changed) {
        changed = FALSE;
        x0 = mkiset();
        p0[3] = iterate(p0[3], &x0);
    };
};
