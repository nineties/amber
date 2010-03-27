(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: regalloc.rl 2010-03-27 22:33:22 nineties $
 %);

(% Register allocation %);

include(stddef, code);
export(regalloc);

conflicts: NULL;
equivregs: NULL;
input_count: NULL;
output_count: NULL;

(% p0: register, p1: is output %);
compute_score: (p0) {
    allocate(1);
    x0 = num_conflicts(p0) * 5;
    x0 = x0 + equivreg_score(p0) * 3;
    x0 = x0 + vec_at(input_count, p0[1]);
    x0 = x0 + vec_at(output_count, p0[1]) * 2;
    return x0;
};

(% p0: set of locations, p1: location %);
add_conflicts: (p0, p1) {
    allocate(3);
    if (p1 == NULL) { return; };
    if (is_constant_operand(p1)) { return; };
    x0 = p1[1];
    while (p0 != NULL) {
        x1 = ls_value(p0);
        if (x0 != x1) {
            x2 = iset_add(vec_at(conflicts, x0), x1);
            vec_put(conflicts, x0, x2);
            x2 = iset_add(vec_at(conflicts, x1), x0);
            vec_put(conflicts, x1, x2);
        };
        p0 = ls_next(p0);
    };
};

num_conflicts: (p0) {
    allocate(1);
    x0 = p0[1]; (% index %);
    return iset_size(vec_at(conflicts, x0));
};

equivreg_score: (p0) {
    allocate(3);
    x0 = p0[1]; (% index %);
    x1 = vec_at(equivregs, x0);
    x2 = 0;
    while (x1 != NULL) {
        if (p0[0] == OPD_PSEUDO) {
            x2 = x2 + 2;
            goto &next;
        };
        if (p0[0] == OPD_REGISTER) {
            x2 = x2 + 1;
            goto &next;
        };
        if (p0[0] == OPD_STACK) {
            x2 = x2 + 4;
            goto &next;
        };
        if (p0[0] == OPD_ARG) {
            x2 = x2 + 4;
            goto &next;
        };
        label next;
        x1 = ls_next(x1);
    };
    return x2;
};

add_equivregs: (p0, p1) {
    allocate(1);
    if (is_constant_operand(p0)) { return; };
    if (is_constant_operand(p1)) { return; };
    x0 = vec_at(equivregs, p0[1]);
    x0 = iset_add(x0, p1[1]);
    vec_put(equivregs, p0[1], x0);
};

incr_output_count: (p0) {
    allocate(1);
    if (p0 == NULL) { return; };
    if (is_constant_operand(p0)) { return; };
    x0 = vec_at(output_count, p0[1]);
    vec_size(output_count, p0[1], x0 + 1);
    return;
};

incr_input_count: (p0) {
    allocate(1);
    if (p0 == NULL) { return; };
    if (is_constant_operand(p0)) { return; };
    x0 = vec_at(input_count, p0[1]);
    vec_size(input_count, p0[1], x0 + 1);
    return;
};

(% p0: instructions %);
compute_conflicts: (p0) {
    allocate(3);
    conflicts = mkvec(num_locations());
    equivregs = mkvec(num_locations());
    input_count = mkvec(num_locations());
    output_count = mkvec(num_locations());
    while (p0 != NULL) {
        x0 = ls_value(p0); (% instruction %);
        x1 = x0[INST_LIVE]; (% live locations %);

        (% live registers in x1 conflict each other %);
        add_conflicts(x1, x0[INST_INPUT]);
        add_conflicts(x1, x0[INST_OUTPUT]);
        x2 = x1;
        while (x2 != NULL) {
            add_conflicts(x1, get_reg(ls_value(x2)));
            x2 = ls_next(x2);
        };

        if (x0[INST_OPCODE] == INST_MOVL) {
            add_equivregs(x0[INST_OUTPUT], x0[INST_INPUT]);
            add_equivregs(x0[INST_INPUT], x0[INST_OUTPUT]);
        };
        incr_output_count(x0[INST_OUTPUT]);
        incr_input_count(x0[INST_INPUT]);
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
                if (compute_score(x0) < compute_score(x3)) {
                    x0 = x3;
                };
            };
        };
        x2 = x2 + 1;
    };
    assert(x0 != NULL);
    return x0;
};

move_cost: (p0) {
    if (p0[0] == OPD_PSEUDO) { return 2; };
    if (p0[0] == OPD_REGISTER) { return 1; };
    if (p0[0] == OPD_STACK) { return 3; };
    if (p0[0] == OPD_ARG) { return 3; };
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

is_memory_access: (p0) {
    if (p0[0] == OPD_STACK) { return TRUE; };
    if (p0[0] == OPD_ARG)   { return TRUE; };
    return FALSE;
};

select_best_equivreg: (p0) {
    allocate(6);
    x0 = vec_at(conflicts, p0[1]);
    x1 = vec_at(equivregs, p0[1]);
    x2 = NULL; (% location with maximum cost %);
    x3 = NULL; (% register with maximum cost %);
    x5 = FALSE; (% TRUE if it must be a register %);
    while (x1 != NULL) {
        if (iset_contains(x0, ls_value(x1)) == FALSE) {
            x4 = get_reg(ls_value(x1));
            if (x3 == NULL) {
                if (x4[0] == OPD_REGISTER) {
                    x3 = x4;
                };
            };
            if (x2 == NULL) {
                x2 = x4;
            } else {
                if (is_memory_access(x2)) {
                    if (is_memory_access(x4)) {
                        x5 = TRUE;
                        goto &skip;
                    };
                };
                if (move_cost(x2) < move_cost(x4)) {
                    x2 = x4;
                };
            };
        };
        label skip;
        x1 = ls_next(x1);
    };
    if (x5) { return x3; };
    if (p0[PSEUDO_MUST_BE_REGISTER] == TRUE) { return x3; };
    return x2;
};

select_location: (p0) {
    allocate(4);
    x0 = vec_at(conflicts, p0[1]); (% conflicts %);
    if (x0 == NULL) {
        (% no conflicts %);
        x0 = vec_at(equivregs, p0[1]);
        if (x0 == NULL) { return get_eax(); };
        return select_best_equivreg(p0);
    };
    (% try to allocate register from equivregs %);
    x1 = select_best_equivreg(p0);
    if (x1 != NULL) { return x1; };

    (% try to allocation register %);
    x1 = 0;
    while (x1 < num_normal_regs()) {
        if (iset_contains(x0, x1) == FALSE) {
            return get_reg(x1);
        };
        x1 = x1 + 1;
    };

    if (p0[PSEUDO_MUST_BE_REGISTER] == TRUE) {
        fputs(stderr, "ERROR: failed to allocate register\n");
        exit(1);
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
    (% here, we must resize working tables. %);
    vec_pushback(conflicts, NULL);
    vec_pushback(equivregs, NULL);
    vec_pushback(input_count, NULL);
    vec_pushback(output_count, NULL);
    return get_stack(x1);
};

assign_location: (p0) {
    allocate(4);
    x0 = select_location(p0);
    (% update register table %);
    assign_pseudo(p0, x0);
    (% update conflicts/equivregs %);
    x1 = 0;
    x2 = num_locations();
    while (x1 < x2) {
        x3 = vec_at(conflicts, x1);
        x3 = iset_del(x3, p0[1]);
        x3 = iset_add(x3, x0[1]);
        vec_put(conflicts, x1, x3);

        x3 = vec_at(equivregs, x1);
        x3 = iset_del(x3, p0[1]);
        x3 = iset_add(x3, x0[1]);
        vec_put(equivregs, x1, x3);

        x1 = x1 + 1;
    };
    (% update output_count/input_count %);
    vec_put(output_count, x0[1],
        vec_at(output_count, p0[1]) + vec_at(output_count, x0[1]));
    vec_put(input_count, x0[1],
        vec_at(input_count, p0[1]) + vec_at(input_count, x0[1]));
};

assign_locations: () {
    allocate(2);
    x0 = 0;
    x1 = num_pseudo();
    while (x0 < x1) {
        assign_location(pickup_pseudo_reg());
	x0 = x0 + 1;
    };
};

(% replace pseudo-reg to physical register or stack memory %);
replace: (p0) {
    if (p0 == NULL) { return NULL; };
    if (p0[0] == OPD_PSEUDO) {
        return replace(get_reg(p0[1]));
    };
    return p0;
};

update_instructions: (p0) {
    allocate(2);
    if (p0 == NULL) { return NULL; };
    x0 = ls_value(p0);
    x0[INST_OUTPUT] = replace(x0[INST_OUTPUT]);
    x0[INST_INPUT]  = replace(x0[INST_INPUT]);

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
