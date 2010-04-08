(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: regalloc.rl 2010-04-08 19:22:19 nineties $
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

(% p0: set of location-ids, p1: location %);
add_conflicts: (p0, p1) {
    allocate(3);
    if (p1 == NULL) { return; };
    if (is_constant_operand(p1)) { return; };
    x0 = p1[1];
    while (p0 != NULL) {
        x1 = ls_value(p0);
        if (x0 != x1) {
            (%
            puts("conflict: ");
            emit_opd(stdout, get_reg(x0), 32);
            puts(" <-> ");
            emit_opd(stdout, get_reg(x1), 32);
            putc('\n');
            %);
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

(% p1: registers assigned to p0 %);
update_tables: (p0, p1) {
    allocate(3);
    x0 = p1;
    (% registers conflicting with p1 now be conflict with registers in p1 %);
    while (x0 != NULL) {
        x1 = vec_at(conflicts, p0[1]);
        add_conflicts(x1, ls_value(x0));
        x0 = ls_next(x0);
    };
    (% remove entries of p0 %);
    x0 = 0;
    x1 = num_locations();
    while (x0 < x1) {
        x2 = vec_at(conflicts, x0);
        x2 = iset_del(x2, p0[1]);
        vec_put(conflicts, x0, x2);

        x2 = vec_at(equivregs, x0);
        x2 = iset_del(x2, p0[1]);
        vec_put(equivregs, x0, x2);

        x0 = x0 + 1;
    };
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

        add_conflicts(x1, x0[INST_OPERAND2]);
        add_conflicts(x1, x0[INST_OPERAND1]);

        (% live registers in x1 conflict each other %);
        x2 = x1;
        while (x2 != NULL) {
            add_conflicts(x1, get_reg(ls_value(x2)));
            x2 = ls_next(x2);
        };

        if (x0[INST_OPCODE] == INST_MOVL) {
            add_equivregs(x0[INST_OPERAND1], x0[INST_OPERAND2]);
            add_equivregs(x0[INST_OPERAND2], x0[INST_OPERAND1]);
        };
        incr_output_count(x0[INST_OPERAND1]);
        incr_input_count(x0[INST_OPERAND2]);
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
    return x0;
};

move_cost: (p0) {
    if (p0[0] == OPD_PSEUDO) { return 2; };
    if (p0[0] == OPD_REGISTER) { return 1; };
    if (p0[0] == OPD_STACK) { return 3; };
    if (p0[0] == OPD_ARG) { return 3; };
    if (p0[0] == OPD_AT) { return 3; };
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

is_memory_access: (p0) {
    if (p0[0] == OPD_STACK) { return TRUE; };
    if (p0[0] == OPD_ARG)   { return TRUE; };
    if (p0[0] == OPD_AT) {
        return is_memory_access(p0[2]);
    };
    if (p0[0] == OPD_LABEL) { return TRUE; };
    if (p0[0] == OPD_PSEUDO) {
        return p0[PSEUDO_TYPE] == LOCATION_MEMORY;
    };
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
            if (ls_value(x1) != p0[1]) {
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
        };
        label skip;
        x1 = ls_next(x1);
    };
    if (x5) { return x3; };
    if (p0[PSEUDO_TYPE] == LOCATION_REGISTER) { return x3; };
    return x2;
};

select_location: (p0) {
    allocate(4);

    x0 = vec_at(conflicts, p0[1]);

    if (p0[PSEUDO_TYPE] == LOCATION_MEMORY) {
	goto &alloc_stackmem;
    };

    (% try to allocate register from equivregs %);
    x1 = select_best_equivreg(p0);
    if (x1 != NULL) { return ls_singleton(x1); };

    (% try to allocation register %);
    x1 = 0;
    while (x1 < num_normal_regs()) {
        if (iset_contains(x0, x1) == FALSE) {
            if (p0[1] != x1) {
                return ls_singleton(get_reg(x1));
            };
        };
        x1 = x1 + 1;
    };

    if (p0[PSEUDO_TYPE] == LOCATION_REGISTER) {
        fputs(stderr, "ERROR: failed to allocate register\n");
        exit(1);
    };

    label alloc_stackmem;

    if (p0[PSEUDO_LENGTH] == 1) {
        (% try to reuse stack memory %);
        x1 = 0;
        while (x1 < num_stack()) {
            x2 = get_stack(x1);
            if (iset_contains(x0, x2[1]) == FALSE) {
                return ls_singleton(x2);
            };
            x1 = x1 + 1;
        };

        (% allocate new stack memory %);
        (% here, we must resize working tables. %);
        vec_pushback(conflicts, NULL);
        vec_pushback(equivregs, NULL);
        vec_pushback(input_count, NULL);
        vec_pushback(output_count, NULL);
        return ls_singleton(get_stack(x1));
    } else {
        (% returns continuous memories %);
        x0 = p0[PSEUDO_LENGTH];
        x1 = get_stack_array(num_stack(), x0);
        vec_resize(conflicts, vec_size(conflicts) + x0);
        vec_resize(equivregs, vec_size(equivregs) + x0);
        vec_resize(input_count, vec_size(input_count) + x0);
        vec_resize(output_count, vec_size(output_count) + x0);
        return x1;
    };
};

assign_location: (p0) {
    allocate(2);
    x0 = select_location(p0);
    (% update register table %);
    (%
    puts(">> assign: ");
    emit_opd(stdout, p0, 32);
    puts(" <-");
    x1 = x0;
    while (x1 != NULL) {
        putc(' ');
        emit_opd(stdout, ls_value(x1), 32);
        x1 = ls_next(x1);
    };
    putc('\n');
    %);

    assign_pseudo(p0, x0);
    (% update conflicts/equivregs %);
    update_tables(p0, x0);

    (% update output_count/input_count %);
    while (x0 != NULL) {
        vec_put(output_count, (ls_value(x0))[1],
            vec_at(output_count, p0[1]) + vec_at(output_count, (ls_value(x0))[1]));
        vec_put(input_count, (ls_value(x0))[1],
            vec_at(input_count, p0[1]) + vec_at(input_count, (ls_value(x0))[1]));
        x0 = ls_next(x0);
    };
};

assign_locations: () {
    allocate(3);
    x0 = 0;
    x1 = num_pseudo();
    while (x0 < x1) {
        x2 = pickup_pseudo_reg();
        if (x2 == NULL) { return; };
        assign_location(x2);
	x0 = x0 + 1;
    };
};

(% replace pseudo-reg to physical register or stack memory %);
replace: (p0) {
    allocate(2);
    if (p0 == NULL) { return NULL; };
    if (p0[0] == OPD_PSEUDO) {
        return replace(ls_value(p0[PSEUDO_LOCATION]));
    };
    if (p0[0] == OPD_AT) {
        x0 = p0[2];
        x1 = p0[3]; (% index %);
        if (x0[0] == OPD_STACK) {
            return get_stack(x0[STACK_OFFSET] + x1);
        };
        if (x0[0] == OPD_PSEUDO) {
            return replace(ls_at(x0[PSEUDO_LOCATION], x1));
        };
        if (x0[0] == OPD_LABEL) {
            return p0;
        };
        fputs(stderr, "ERROR: not reachable here\n");
        exit(1);
    };
    return p0;
};

update_instructions: (p0) {
    allocate(2);
    if (p0 == NULL) { return NULL; };
    x0 = ls_value(p0);
    x0[INST_OPERAND1] = replace(x0[INST_OPERAND1]);
    x0[INST_OPERAND2]  = replace(x0[INST_OPERAND2]);

    (% eliminate meaningless move %);
    if (x0[INST_OPCODE] == INST_MOVL) {
        if (x0[INST_OPERAND1] == x0[INST_OPERAND2]) {
            return update_instructions(ls_next(p0));
        };
    };

    x1 = ls_cons(x0, update_instructions(ls_next(p0)));

    (% insert leave instruction %);
    if (x0[INST_OPCODE] == INST_RET) {
        x1 = ls_cons(mkinst(INST_LEAVE, NULL, NULL), x1);
    };
    return x1;
};

allocate_stack_frame: (p0) {
    allocate(1);
    x0 = p0;
    if (num_stack() > 0) {
        x0 = ls_cons(mkinst(INST_SUBL, mktup2(OPD_INTEGER, 4*num_stack()), get_esp()), x0);
    };
    return
        ls_cons(mkinst(INST_PUSHL, get_ebp(), NULL),
        ls_cons(mkinst(INST_MOVL, get_esp(), get_ebp()),
            x0));
};

(% p0: instructions
 % if two operands are both memory references, insert temporal register
 % op a b => movl a t; op t b
 %);

(% p0: instruction %);
need_temporal_register: (p0) {
    allocate(3);
    if (p0[INST_OPERAND1] == NULL) { return FALSE; };
    if (p0[INST_OPERAND2] == NULL) { return FALSE; };
    if (is_memory_access(p0[INST_OPERAND1]) == FALSE) {
	(% XXX: ad-hoc register management :( %);
	if (is_memory_access(p0[INST_OPERAND2])) {
	    set_pseudo_type(p0[INST_OPERAND1], LOCATION_REGISTER);
	};
        return FALSE;
    };
    if (is_memory_access(p0[INST_OPERAND2]) == FALSE) {
	(% XXX: ad-hoc register management :( %);
	if (is_memory_access(p0[INST_OPERAND1])) {
	    set_pseudo_type(p0[INST_OPERAND2], LOCATION_REGISTER);
	};
        return FALSE;
    };
    x0 = p0[INST_OPERAND1];
    x1 = p0[INST_OPERAND2];
    if (x0[0] == OPD_LABEL) {
	return TRUE;
    };
    if (x1[0] == OPD_LABEL) {
	return TRUE;
    };
    x2 = vec_at(conflicts, x0[1]);
    if (iset_contains(x2, x1[1])) {
        return TRUE;
    };
    if (x1[0] == OPD_PSEUDO) {
        x0 = ls_singleton(x0);
        assign_pseudo(x1, x0);
        update_tables(x1, x0);
        return FALSE;
    };
    return TRUE;
};

(% p0: program list, p1: instruction %);
insert: (p0, p1) {
    allocate(3);
    if (need_temporal_register(p1)) {
        x0 = create_pseudo(1, LOCATION_REGISTER);
        p0 = ls_cons(mkinst(INST_MOVL, p1[INST_OPERAND1], x0), p0);
        x2 = mkinst(p1[INST_OPCODE], x0, p1[INST_OPERAND2]);
        x2[INST_ARG] = p1[INST_ARG];
        p0 = ls_cons(x2, p0);
        return p0;
    };
    return ls_cons(p1, p0);
};

insert_temporal_register: (p0) {
    allocate(2);
    x0 = p0;
    x1 = NULL;
    while (x0 != NULL) {
        x1 = insert(x1, ls_value(x0));
        x0 = ls_next(x0);
    };
    return ls_reverse(x1);
};

(% p0: TCODE_FUNC object %);
regalloc: (p0) {
    allocate(1);

    (% liveness analysis %);
    liveness(p0);
    compute_conflicts(p0[3]);
    p0[3] = insert_temporal_register(p0[3]);
    liveness(p0);

    x0 = p0[3]; (% instructions %);
    if (num_pseudo() > 0) {
        compute_conflicts(x0);
        assign_locations();
    };
    x0 = update_instructions(x0);
    x0 = allocate_stack_frame(x0);
    p0[3] = x0;
};
