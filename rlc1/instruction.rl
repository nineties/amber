(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: instruction.rl 2010-04-10 01:17:07 nineties $
 %);

include(code, stddef);
export(get_opd1_type, get_opd2_type);
export(opd1_is_input, opd2_is_input, opd1_is_output, opd2_is_output);
export(register_add, register_del, input_add, output_del);

opd1_type: [
    OPD_INPUT, OPD_INPUT, OPD_OUTPUT, OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE,
    OPD_INPUT, OPD_INPUT, OPD_INPUT, OPD_INPUT, OPD_INPUT, OPD_INPUT, OPD_INPUT,
    OPD_INPUT, OPD_INPUT, OPD_INPUT, OPD_INPUT, OPD_INOUT, OPD_INOUT, OPD_INOUT,
    OPD_INOUT, OPD_NONE, OPD_INPUT, OPD_INPUT, OPD_INPUT, OPD_NONE, OPD_NONE,
    OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE, OPD_INPUT
];

opd2_type: [
    OPD_OUTPUT, OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE,
    OPD_NONE, OPD_INOUT, OPD_INOUT, OPD_INOUT, OPD_NONE, OPD_NONE, OPD_INOUT,
    OPD_INOUT, OPD_INOUT, OPD_INOUT, OPD_INOUT, OPD_NONE, OPD_NONE, OPD_NONE,
    OPD_NONE, OPD_OUTPUT, OPD_INPUT, OPD_INPUT, OPD_INPUT, OPD_NONE, OPD_NONE,
    OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE, OPD_NONE, OPD_INPUT
];

get_opd1_type: (p0) {
    return opd1_type[p0[INST_OPCODE]];
};

get_opd2_type: (p0) {
    return opd2_type[p0[INST_OPCODE]];
};

opd1_is_input: (p0) {
    allocate(1);
    x0 = get_opd1_type(p0);
    if (x0 == OPD_INPUT) { return TRUE; };
    if (x0 == OPD_INOUT) { return TRUE; };
    return FALSE;
};

opd2_is_input: (p0) {
    allocate(1);
    x0 = get_opd2_type(p0);
    if (x0 == OPD_INPUT) { return TRUE; };
    if (x0 == OPD_INOUT) { return TRUE; };
    return FALSE;
};

opd1_is_output: (p0) {
    allocate(1);
    x0 = get_opd1_type(p0);
    if (x0 == OPD_OUTPUT) { return TRUE; };
    if (x0 == OPD_INOUT) { return TRUE; };
    return FALSE;
};

opd2_is_output: (p0) {
    allocate(1);
    x0 = get_opd2_type(p0);
    if (x0 == OPD_OUTPUT) { return TRUE; };
    if (x0 == OPD_INOUT) { return TRUE; };
    return FALSE;
};

(% p0: register set (iset), p1: operand %);
register_add: (p0, p1) {
    if (p1 == NULL) { return p0; };
    if (is_constant_operand(p1)) { return p0; };
    if (p1[0] == OPD_OFFSET) {
	return register_add(p0, p1[2]);
    };
    return iset_add(p0, p1[1]);
};

(% p0: register set (iset), p1: operand %);
register_del: (p0, p1) {
    if (p1 == NULL) { return p0; };
    if (is_constant_operand(p1)) { return p0; };
    return iset_del(p0, p1[1]);
};

(% p0: register set (iset), p1: instruction %);
output_del: (p0, p1) {
    if (opd1_is_output(p1)) {
	p0 = register_del(p0, p1[INST_OPERAND1]);
    };
    if (opd2_is_output(p1)) {
	p0 = register_del(p0, p1[INST_OPERAND2]);
    };
    return p0;
};

(% p0: register set (iset), p1: instruction %);
input_add: (p0, p1) {
    if (opd1_is_input(p1)) {
	p0 = register_add(p0, p1[INST_OPERAND1]);
    };
    if (opd2_is_input(p1)) {
	p0 = register_add(p0, p1[INST_OPERAND2]);
    };
    return p0;
};
