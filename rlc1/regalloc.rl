(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: regalloc.rl 2010-03-26 16:45:26 nineties $
 %);

(% Register allocation %);

include(stddef, code);
export(regalloc);

(% simple eager implementation %);

conflicts: NULL;

add_conflicts: (p0) {
    allocate(4);
    x0 = p0;
    while (x0 != NULL) {
        x1 = p0;
        while (x1 != NULL) {
            if (x0 != x1) {
                x2 = (ls_value(x0));
                x3 = (ls_value(x1));
                vec_put(conflicts, x2, iset_add(vec_at(conflicts, x2), x3));
            };
            x1 = ls_next(x1);
        };
        x0 = ls_next(x0);
    };
};

num_conflicts: (p0) {
    allocate(1);
    x0 = p0[1]; (% index %);
    return iset_size(vec_at(conflicts, x0));
};

(% p0: instructions %);
compute_conflicts: (p0) {
    allocate(2);
    conflicts = mkvec(num_locations());
    while (p0 != NULL) {
        x0 = ls_value(p0); (% instruction %);
        x1 = x0[INST_LIVE]; (% live locations %);

        (% registers in x1 conflict each other %);
        add_conflicts(x1);
        p0 = ls_next(p0);
    };
};

(% pickup pseudo register which have maximal conflicts %);
pickup_pseudo_reg: () {
    allocate(4);
    x0 = NULL;
    x1 = num_pseudo();
    x2 = 0;
    while (x2 < x1) {
        x3 = get_pseudo(x2);
        if (x3 != NULL) {
            if (x0 == NULL) {
                x0 = x3;
            } else {
                if (num_conflicts(x0) < num_conflicts(x3)) {
                    x0 = x3;
                };
            };
        };
        x2 = x2 + 1;
    };
    return x0;
};

select_location: (p0) {
    allocate(3);
    x0 = vec_at(conflicts, p0[1]); (% conflicts %);
    if (x0 == NULL) {
        (% no conflicts %);
        return get_eax();
    };
    (% try to allocation register %);
    x1 = 0;
    while (x1 < num_normal_regs()) {
        if (iset_contains(x0, x1) == FALSE) {
            return get_reg(x1);
        };
        x1 = x1 + 1;
    };
    (% try to reuse stack memory %);
    x1 = 0;
    while (x1 < num_stack()) {
        x2 = get_stack(x1);
        if (iset_contains(x0, x2[1]) == FALSE) {
            return x2;
        };
        x1 = x1 + 1;
    };
    (% allocate new stack memory %);
    return get_stack(x1);
};

assign_location: (p0) {
    allocate(4);
    x0 = select_location(p0);
    (% update register table %);
    assign_pseudo(p0, x0);
    (% update conflicts %);
    x1 = 0;
    x2 = vec_size(conflicts);
    while (x1 < x2) {
        x3 = vec_at(conflicts, x1);
        x3 = iset_del(x3, p0[1]);
        x3 = iset_add(x3, x0[1]);
        vec_put(conflicts, x1, x3);
        x1 = x1 + 1;
    };
};

assign_locations: () {
    allocate(3);
    x0 = 0;
    x1 = num_pseudo();
    while (x0 < x1) {
        x2 = pickup_pseudo_reg();
        assign_location(x2);
        x0 = x0 + 1;
    };
};

(% replace pseudo-reg to physical register or stack memory %);
replace: (p0) {
    if (p0 == NULL) { return NULL; };
    if (p0[0] == OPD_PSEUDO) {
        return get_reg(p0[1]);
    };
    return p0;
};

update_instructions: (p0) {
    allocate(2);
    if (p0 == NULL) { return NULL; };
    x0 = ls_value(p0);
    x0[INST_OUTPUT] = replace(x0[INST_OUTPUT]);
    x0[INST_INPUT] = replace(x0[INST_INPUT]);

    (% eliminate meaningless move %);
    if (x0[INST_OPCODE] == INST_MOVL) {
        if (x0[INST_OUTPUT] == x0[INST_INPUT]) {
            return update_instructions(ls_next(p0));
        };
    };

    x1 = ls_cons(x0, update_instructions(ls_next(p0)));

    (% insert leave instruction %);
    if (x0[INST_OPCODE] == INST_RET) {
        x1 = ls_cons(mkinst(INST_LEAVE, NULL, NULL, NULL), x1);
    };
    return x1;
};

allocate_stack_frame: (p0) {
    allocate(1);
    x0 = p0;
    if (num_stack() > 0) {
        x0 = ls_cons(mkinst(INST_SUBL, get_esp(), mktup2(OPD_INTEGER, 4*num_stack()), NULL), x0);
    };
    return
        ls_cons(mkinst(INST_PUSHL, NULL, get_ebp(), NULL),
        ls_cons(mkinst(INST_MOVL, get_ebp(), get_esp(), NULL),
            x0));
};

(% p0: TCODE_FUNC object %);
regalloc: (p0) {
    allocate(1);
    x0 = p0[3]; (% instructions %);
    if (num_pseudo() > 0) {
        compute_conflicts(x0);
        assign_locations();
    };
    x0 = update_instructions(x0);
    x0 = allocate_stack_frame(x0);
    p0[3] = x0;
};
