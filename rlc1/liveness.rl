(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: liveness.rl 2010-04-05 14:08:32 nineties $
 %);

(% liveness analysis %);

include(stddef, code);
export(liveness);

(% opcode to functor %);
iterate_funcs: [
    iterate_normal, iterate_normal, iterate_normal, iterate_ret, iterate_normal,
    iterate_int, iterate_call, iterate_call, iterate_normal, iterate_normal,
    iterate_normal, iterate_div, iterate_mod, iterate_normal, iterate_normal,
    iterate_normal, iterate_normal, iterate_normal, iterate_normal, iterate_normal,
    iterate_normal, iterate_normal, iterate_normal, iterate_normal, iterate_normal
];

(% p0: list of instructions, p1: live-out register at final%);
iterate_normal: (p0, p1) {
    allocate(2);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);

    x1 = ls_value(p0);
    x0 = output_del(x0, x1);
    x1[INST_LIVE] = iset_copy(x0);
    x0 = input_add(x0, x1);
    return x0; (% live-in registers %);
};

iterate_ret: (p0, p1) {
    allocate(2);
    iterate(ls_next(p0), p1);
    x0 = ls_value(p0);
    if (x0[INST_ARG]) {
        (% retval instruction %);
        x1 = mkiset();
        x1 = register_add(x1, get_eax());
        return x1;
    };
    return mkiset();
};

iterate_int: (p0, p1) {
    allocate(4);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);
    x1 = ls_value(p0);
    x0 = register_del(x0, get_eax()); (% remove dead register %);
    x1[INST_LIVE] = iset_copy(x0);

    x2 = x1[INST_ARG];
    x3 = 0;
    while (x3 < x2) {
        x0 = register_add(x0, get_physical_reg(x3));
        x3 = x3 + 1;
    };
    return x0; (% live-in registers %);
};

iterate_call: (p0, p1) {
    allocate(2);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);
    x1 = ls_value(p0);
    x0 = register_del(x0, get_eax());
    x1[INST_LIVE] = iset_copy(x0);

    x0 = input_add(x0, x1);
    return x0; (% live-in registers %);
};

(% p0: list of instructions, p1: live-out register at final%);
iterate_div: (p0, p1) {
    allocate(2);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);

    x1 = ls_value(p0);
    x0 = register_del(x0, get_eax()); (% remove dead register %);
    x1[INST_LIVE] = iset_copy(x0);

    x0 = input_add(x0, x1);
    x0 = register_add(x0, get_eax());
    x0 = register_add(x0, get_edx());
    return x0; (% live-in registers %);
};

(% p0: list of instructions, p1: live-out register at final%);
iterate_mod: (p0, p1) {
    allocate(2);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);

    x1 = ls_value(p0);
    x0 = register_del(x0, get_edx()); (% remove dead register %);
    x1[INST_LIVE] = iset_copy(x0);

    x0 = input_add(x0, x1);
    x0 = register_add(x0, get_eax());
    x0 = register_add(x0, get_edx());
    return x0; (% live-in registers %);
};
(% p0: list of instructions, p1: live-out registers at final %);
iterate: (p0, p1) {
    allocate(2);
    if (p0 == NULL) { return p1; };
    x0 = ls_value(p0);
    x1 = iterate_funcs[x0[INST_OPCODE]];
    return x1(p0, p1);
};

(% p0: TCODE_FUNC object %);
liveness: (p0) {
    iterate(p0[3], mkiset());
};
