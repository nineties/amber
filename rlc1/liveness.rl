(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: liveness.rl 2010-04-09 11:07:11 nineties $
 %);

(% liveness analysis %);

include(stddef, code);
export(liveness);

live_map: NULL; (% label -> liveout %);
changed: FALSE;

update_livein: (p0, p1) {
    allocate(1);
    x0 = p0[INST_LIVEIN];
    if (iset_subtract(p1, x0) != NULL) {
        changed = TRUE;
        p0[INST_LIVEIN] = iset_union(p0[INST_LIVEIN], p1);
    };
};
update_liveout: (p0, p1) {
    allocate(1);
    x0 = p0[INST_LIVEOUT];
    if (iset_subtract(p1, x0) != NULL) {
        changed = TRUE;
        p0[INST_LIVEOUT] = iset_union(p0[INST_LIVEOUT], p1);
    };
};

(% opcode to functor %);
iterate_funcs: [
    iterate_normal, iterate_normal, iterate_normal, iterate_ret, iterate_normal,
    iterate_int, iterate_call, iterate_call, iterate_normal, iterate_normal,
    iterate_normal, iterate_div, iterate_mod, iterate_normal, iterate_normal,
    iterate_normal, iterate_normal, iterate_normal, iterate_normal, iterate_normal,
    iterate_normal, iterate_normal, iterate_normal, iterate_normal, iterate_normal,
    iterate_normal, iterate_jump, iterate_branch, iterate_branch, iterate_branch,
    iterate_branch, iterate_branch, iterate_branch, iterate_label, iterate_normal,
    iterate_normal
];

(% p0: list of instructions, p1: live-out register at final%);
iterate_normal: (p0, p1) {
    allocate(2);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);

    x1 = ls_value(p0);
    update_liveout(x1, x0);

    x0 = output_del(x0, x1);
    x0 = input_add(x0, x1);
    update_livein(x1, x0);
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
        update_livein(x0, x1);
        return x1;
    };
    return mkiset();
};

iterate_int: (p0, p1) {
    allocate(4);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);
    x1 = ls_value(p0);
    update_liveout(x1, x0);
    x0 = register_del(x0, get_eax()); (% remove dead register %);

    x2 = x1[INST_ARG];
    x3 = 0;
    while (x3 < x2) {
        x0 = register_add(x0, get_physical_reg(x3));
        x3 = x3 + 1;
    };
    update_livein(x1, x0);
    return x0; (% live-in registers %);
};

iterate_jump: (p0, p1) {
    allocate(2);
    iterate(ls_next(p0), p1);
    x0 = ls_value(p0);
    x1 = map_find(live_map, x0[INST_OPERAND1][1]);
    update_liveout(x0, x1);
    update_livein(x0, x1);
    return x1;
};

iterate_branch: (p0, p1) {
    allocate(4);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);
    x1 = ls_value(p0);
    x2 = map_find(live_map, x1[INST_OPERAND1][1]);
    x3 = iset_union(x0, x2);
    update_liveout(x1, x3);
    update_livein(x1, x3);
    return x3;
};

iterate_label: (p0, p1) {
    allocate(2);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);
    x1 = ls_value(p0);
    update_liveout(x1, x0);
    update_livein(x1, x0);
    map_add(live_map, x1[INST_OPERAND1][1], x1[INST_LIVEIN]);
    return x0;
};

(% p0: a location %);
must_be_memory: (p0) {
    if (p0[0] == OPD_PSEUDO) {
        (% assert(p0[PSEUDO_TYPE] != LOCATION_REGISTER); %);
        p0[PSEUDO_TYPE] = LOCATION_MEMORY;
        return;
    };
    if (p0[0] == OPD_AT) {
        must_be_memory(p0[2]);
        return;
    };
    if (p0[0] == OPD_REGISTER) {
        fputs(stderr, "ERROR: not reachable here\n");
        exit(1);
    };
    return;
};

iterate_call: (p0, p1) {
    allocate(4);

    x0 = iterate(ls_next(p0), p1); (% live-out registers %);
    x1 = ls_value(p0);
    update_liveout(x1, x0);
    x0 = register_del(x0, get_eax());

    (% registers live across function call must be assigned to stack memory %);
    x2 = x0;
    while (x2 != NULL) {
        must_be_memory(get_reg(ls_value(x2)));
        x2 = ls_next(x2);
    };

    x0 = input_add(x0, x1);
    x2 = x1[INST_ARG]; (% number of arguments %);
    x3 = 0;
    while (x3 < x2) {
        x0 = register_add(x0, get_stack(x3));
        x3 = x3 + 1;
    };
    update_livein(x1, x0);
    return x0; (% live-in registers %);
};

(% p0: list of instructions, p1: live-out register at final%);
iterate_div: (p0, p1) {
    allocate(2);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);

    x1 = ls_value(p0);
    update_liveout(x1, x0);
    x0 = register_del(x0, get_eax()); (% remove dead register %);

    x0 = input_add(x0, x1);
    x0 = register_add(x0, get_eax());
    x0 = register_add(x0, get_edx());
    update_livein(x1, x0);
    return x0; (% live-in registers %);
};

(% p0: list of instructions, p1: live-out register at final%);
iterate_mod: (p0, p1) {
    allocate(2);
    x0 = iterate(ls_next(p0), p1); (% live-out registers %);

    x1 = ls_value(p0);
    update_liveout(x1, x0);
    x0 = register_del(x0, get_edx()); (% remove dead register %);

    x0 = input_add(x0, x1);
    x0 = register_add(x0, get_eax());
    x0 = register_add(x0, get_edx());
    update_livein(x1, x0);
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
    allocate(1);
    live_map = mkmap(&strhash, &streq, 0);
    changed = TRUE;
    while (changed) {
        changed = FALSE;
        iterate(p0[3], mkiset());
    };
};
