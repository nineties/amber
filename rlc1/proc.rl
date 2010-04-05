(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: proc.rl 2010-04-05 15:22:14 nineties $
 %);

include(stddef, code);
export(init_proc, reset_proc);
export(num_physical_regs, num_normal_regs, num_locations, num_pseudo, num_stack);
export(get_reg, get_physical_reg, get_stack, get_stack_array, get_arg);
export(get_eax, get_ebx, get_ecx, get_edx, get_esi, get_edi, get_ebp, get_esp);
export(create_pseudo, get_pseudo, assign_pseudo, get_at);
export(get_register_repr);
export(is_constant_operand, is_local_operand);

NUM_PHYSICAL_REGS => 8; (% eax, ebx, ecx, edx, esi, edi, ebp, esp %);
NUM_NORMAL_REGS   => 4; (% eax, ebx, ecx, edx %);
REG_EAX => 0;
REG_EBX => 1;
REG_ECX => 2;
REG_EDX => 3;
REG_ESI => 4;
REG_EDI => 5;
REG_EBP => 6;
REG_ESP => 7;

locations: NULL;
stackregs: NULL;
argregs: NULL;
pseudoregs: NULL;
location_id: 0;
pseudo_id: 0;

new_pseudo_id: () {
    pseudo_id = pseudo_id + 1;
    return pseudo_id - 1;
};

new_location_id: () {
    location_id = location_id + 1;
    return location_id-1;
};

num_physical_regs: () { return NUM_PHYSICAL_REGS; };
num_normal_regs:   () { return NUM_NORMAL_REGS; };
num_locations: () { return vec_size(locations); };
num_pseudo: () { return vec_size(pseudoregs); };
num_stack: () { return vec_size(stackregs); };

get_reg: (p0) {
    if (p0 >= vec_size(locations)) {
	fputs(stderr, "ERROR: register (index=");
	fputi(stderr, p0);
	fputs(stderr, ") does not exist\n");
	exit(1);
    };
    return vec_at(locations, p0);
};

get_physical_reg: (p0) {
    if (p0 >= NUM_PHYSICAL_REGS) {
	fputs(stderr, "ERROR: physical register (index=");
	fputi(stderr, p0);
	fputs(stderr, ") does not exist\n");
	exit(1);
    };
    return vec_at(locations, p0);
};

get_eax: () { return get_physical_reg(REG_EAX); };
get_ebx: () { return get_physical_reg(REG_EBX); };
get_ecx: () { return get_physical_reg(REG_ECX); };
get_edx: () { return get_physical_reg(REG_EDX); };
get_esi: () { return get_physical_reg(REG_ESI); };
get_edi: () { return get_physical_reg(REG_EDI); };
get_ebp: () { return get_physical_reg(REG_EBP); };
get_esp: () { return get_physical_reg(REG_ESP); };

(% p0: offset %);
create_stack: (p0) {
    allocate(1);
    x0 = mktup3(OPD_STACK, new_location_id(), p0);
    vec_pushback(locations, x0);
    return x0;
};

(% p0: offset %);
get_stack: (p0) {
    allocate(1);
    if (p0 < vec_size(stackregs)) {
        return vec_at(stackregs, p0);
    };
    x0 = create_stack(p0);
    vec_pushback(stackregs, x0);
    return x0;
};

(% p0: offset, p1: length %);
get_stack_array: (p0, p1) {
    allocate(2);
    x0 = NULL;
    x1 = p0 + p1;
    while (p0 < x1) {
        x0 = ls_cons(get_stack(p0), x0);
        p0 = p0 + 1;
    };
    return ls_reverse(x0);
};

(% p0: offset %);
create_arg: (p0) {
    allocate(1);
    x0 = mktup3(OPD_ARG, new_location_id(), p0);
    vec_pushback(locations, x0);
    return x0;
};

(% p0: offset %);
get_arg: (p0) {
    allocate(1);
    if (p0 < vec_size(argregs)) {
        return vec_at(argregs, p0);
    };
    x0 = create_arg(p0);
    vec_pushback(argregs, x0);
    return x0;
};

register_8_repr: ["%al", "%bl", "%cl", "dl"];
register_32_repr: ["%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi", "%ebp", "%esp"];
(% p0: register, p1: precision %);
get_register_repr: (p0, p1) {
    allocate(1);
    assert(p0[0] == OPD_REGISTER);
    x0 = p0[2];
    if (p1 == 8) {
	assert(x0 < NUM_NORMAL_REGS);
	return register_8_repr[x0];
    };
    if (p1 == 32) {
	assert(x0 < NUM_PHYSICAL_REGS);
	return register_32_repr[x0];
    };
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

(% p0: length, p1: location type %);
create_pseudo: (p0, p1) {
    allocate(1);
    x0 = mktup6(OPD_PSEUDO, new_location_id(), new_pseudo_id(), p0, p1, NULL);
    vec_pushback(locations, x0);
    vec_pushback(pseudoregs, x0);
    return x0;
};

get_pseudo: (p0) {
    assert(p0 < vec_size(pseudoregs));
    return vec_at(pseudoregs, p0);
};

get_at: (p0, p1) {
    allocate(1);
    x0 = mktup4(OPD_AT, new_location_id(), p0, p1);
    vec_pushback(locations, x0);
    return x0;
};

(% p0: pseudo register, p1: memory locations %);
assign_pseudo: (p0, p1) {
    allocate(1);
    assert(p0[PSEUDO_LENGTH] == ls_length(p1));
    x0 = p0[2]; (% pseudo-id %);
    assert(x0 < vec_size(pseudoregs));
    vec_put(pseudoregs, x0, NULL);
    p0[PSEUDO_LOCATION] = p1;
};

init_proc: () {
    allocate(1);
    locations  = mkvec(NUM_PHYSICAL_REGS);
    stackregs  = mkvec(0);
    argregs    = mkvec(0);
    pseudoregs = mkvec(0);

    x0 = 0;
    while (x0 < NUM_PHYSICAL_REGS) {
        vec_put(locations, x0, mktup3(OPD_REGISTER, new_location_id(), x0));
        x0 = x0 + 1;
    };
};

reset_proc: () {
    stackregs  = mkvec(0);
    argregs    = mkvec(0);
    pseudoregs = mkvec(0);
    vec_resize(locations, num_physical_regs());
    location_id = num_physical_regs();
    pseudo_id = 0;
};

is_constant_operand: (p0) {
    assert(p0);
    if (p0[0] == OPD_PSEUDO)   { return FALSE; };
    if (p0[0] == OPD_REGISTER) { return FALSE; };
    if (p0[0] == OPD_STACK)    { return FALSE; };
    if (p0[0] == OPD_ARG)      { return FALSE; };
    if (p0[0] == OPD_AT)       { return FALSE; };
    return TRUE;
};

is_local_operand: (p0) {
    if (p0[0] == OPD_ADDRESS) { return FALSE; };
    if (p0[0] == OPD_LABEL) { return FALSE; };
    if (p0[0] == OPD_AT) {
	return is_local_operand(p0[2]);
    };
    return TRUE;
};
