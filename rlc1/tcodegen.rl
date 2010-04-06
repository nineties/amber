(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: tcodegen.rl 2010-04-06 13:55:46 nineties $
 %);

(% translate typed rowlcore to Three-address Code %);

include(stddef, code);
export(tcodegen, mkinst);

vtable: NULL; (% variable table. variable id to corresponding operand %);

binop_table: ["", "+", "-", "*", "/", "%", "|", "^", "&", "<<", ">>", "==", "!=", "<", ">",
"<=", ">=", "||", "&&"];
unop_table: ["+", "-", "~", "!", "&", "*", "++", "--", "++", "--"];

is_global_identifier: (p0) {
    if (p0[0] != NODE_IDENTIFIER) { return FALSE; };
    return p0[5];
};

(% p0: type.  returns number of required register for the type %);
type_size: (p0) {
    allocate(4);
    if (p0[0] == NODE_CHAR_T) { return 1; };
    if (p0[0] == NODE_INT_T)  { return 1; };
    if (p0[0] == NODE_FLOAT_T) { return 1; };
    if (p0[0] == NODE_DOUBLE_T) { return 2; };
    if (p0[0] == NODE_POINTER_T) { return 1; };
    if (p0[0] == NODE_ARRAY_T) {
        return type_size(p0[ARRAY_T_ELEMENT]) * p0[ARRAY_T_LENGTH];
    };
    if (p0[0] == NODE_TUPLE_T) {
        x0 = p0[TUPLE_T_LENGTH];
        x1 = p0[TUPLE_T_ELEMENTS];
        x2 = 0;
        x3 = 0;
        while (x2 < x0) {
            x3 = x3 + type_size(x1[x2]);
            x2 = x2 + 1;
        };
        return x3;
    };
    if (p0[0] == NODE_LAMBDA_T) {
        return 1;
    };
    if (p0[0] == NODE_NAMED_T) {
        return type_size(p0[2]);
    };
    not_reachable();
};

(% p0: identifier, p1: operand list %);
set_operand: (p0, p1) {
    allocate(1);
    x0 = p0[3]; (% identifier-id %);
    assert(x0 < vec_size(vtable));
    vec_put(vtable, x0, p1);
};

(% p0: identifier %);
get_operand: (p0) {
    allocate(2);
    x0 = p0[3]; (% identifier-id %);
    assert(x0 < vec_size(vtable));
    x1 = vec_at(vtable, x0);
    assert(x1 != NULL);
    return x1;
};

get_operand_single: (p0) {
    allocate(1);
    x0 = get_operand(p0);
    assert(ls_length(x0) == 1);
    return ls_value(x0);
};

(% p0: opcode, p1: operand1, p2, operand2 %);
mkinst: (p0, p1, p2) {
    return mktup6(TCODE_INST, p0, p1, p2, mkiset(), 0);
};



LABEL_BUF_SIZE => 128;
labelbuf : char [LABEL_BUF_SIZE];
label_id : 0;
labelbuf_idx : 0;

reset_labelbuf: () {
    labelbuf_idx = 0;
    wch(labelbuf, 0, '\0');
};

put_labelchar: (p0) {
    if (labelbuf_idx >= LABEL_BUF_SIZE-1) {
	fputs(stderr, "ERROR: too long label name");
	fputs(stderr, labelbuf);
	fputs(stderr, "...\n");
	exit(1);
    };
    wch(labelbuf, labelbuf_idx, p0);
    labelbuf_idx = labelbuf_idx + 1;
    wch(labelbuf, labelbuf_idx, '\0');
};

put_labelstr: (p0) {
    while (rch(p0, 0) != '\0') {
	put_labelchar(rch(p0, 0));
	p0 = p0 + 1;
    };
};

labelint_digits: char [10]; (% 32bit decimal integers are less than 11 digits %);
put_labelint: (p0, p1) {
    allocate(1);

    wch(labelint_digits, 0, p1%10 + '0');
    p1 = p1/10;
    x0 = 0;
    while (p1 != 0) {
        x0 = x0 + 1;
        wch(labelint_digits, x0, p1%10 + '0');
        p1 = p1/10; };

    while (x0 >= 0) {
	put_labelchar(rch(labelint_digits, x0));
        x0 = x0 - 1;
    };
};

new_label: () {
    reset_labelbuf();
    put_labelstr("L.");
    put_labelint(label_id);
    label_id = label_id + 1;
    return strdup(labelbuf);
};

topdecl : NULL;
add_topdecl: (p0) {
    topdecl = ls_cons(p0, topdecl);
};

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

transl_funcs: [
    not_reachable, not_implemented, transl_integer, transl_string, not_implemented,
    transl_identifier, not_implemented, transl_tuple, transl_code, transl_decl,
    transl_call, not_implemented, not_implemented, transl_unexpr, transl_binexpr,
    transl_assign, not_implemented, transl_ret, transl_retval, transl_syscall, transl_field,
    transl_fieldref, not_reachable, transl_variant, transl_void
];

transl_integer: (p0, p1, p2) {
    allocate(1);
    x0 = p1[1]; (% type %);
    if (x0[0] == NODE_CHAR_T) {
        *p2 = ls_singleton(mktup2(OPD_CHAR, p1[3]));
        return p0;
    };
    if (x0[0] == NODE_INT_T) {
        *p2 = ls_singleton(mktup2(OPD_INTEGER, p1[3]));
        return p0;
    };
    not_reachable();
};

transl_string: (p0, p1, p2) {
    allocate(1);
    x0 = new_label();
    add_topdecl(mktup4(TCODE_DATA, x0, mktup2(DATA_STRING, p1[2]), FALSE));
    *p2 = ls_singleton(mktup2(OPD_ADDRESS, x0));
    return p0;
};

transl_identifier: (p0, p1, p2) {
    allocate(5);
    if (p1[5]) {
        (% this is a global variable %);
        if (p1[1][0] == NODE_LAMBDA_T) {
            *p2 = ls_singleton(mktup2(OPD_ADDRESS, mangle(p1[1], get_ident_name(p1))));
            return p0;
        };
        x0 = type_size(p1[1]);
        if (x0 == 1) {
            *p2 = ls_singleton(mktup2(OPD_LABEL, get_ident_name(p1)));
            return p0;
        };
        x1 = mktup2(OPD_LABEL, get_ident_name(p1));
        x2 = 0;
        x3 = NULL;
        while (x2 < x0) {
            x4 = get_at(x1, x2);
            x3 = ls_cons(x4, x3);
            x2 = x2 + 1;
        };
        *p2 = ls_reverse(x3);
        return p0;
    };
    *p2 = get_operand(p1);
    return p0;
};

(% p1: argument tuple, p2: offset %);
set_arguments: (p0, p1, p2, p3) {
    allocate(6);
    x0 = p1[TUPLE_LENGTH];
    x1 = p1[TUPLE_ELEMENTS];
    x2 = 0;
    x3 = p2; (% offset of argument in stack %);
    x4 = NULL;
    while (x2 < x0) {
        p0 = transl_item(p0, x1[x2], &x5);
	while (x5 != NULL) {
	    x4 = ls_cons(mkinst(INST_MOVL, ls_value(x5), get_stack(x3)), x4);
	    x3 = x3 + 1;
	    x5 = ls_next(x5);
	};
        x2 = x2 + 1;
    };
    *p3 = x3;
    return ls_append(x4, p0);
};

transl_call2: (p0, p1, p2) {
    allocate(9);
    x0 = p1[2]; (% function %);
    x1 = (x0[1])[LAMBDA_T_RETURN]; (% return type %);
    x2 = type_size(x1);
    x3 = p1[3]; (% argument %);
    x4 = create_pseudo(x2, LOCATION_MEMORY);
    if (is_global_identifier(x0)) {
        (% immediate call %);
        x5 = mangle(x0[1], get_ident_name(x0));
        x6 = create_pseudo(1, LOCATION_REGISTER); (% address of region for return value %);
        p0 = ls_cons(mkinst(INST_LEAL, x4, x6), p0);
        p0 = ls_cons(mkinst(INST_MOVL, x6, get_stack(0)), p0);
        p0 = set_arguments(p0, x3, 1, &x7);
        x8 = mkinst(INST_CALL_IMM, mktup2(OPD_LABEL, x5), NULL);
        x8[INST_ARG] = x7;
        p0 = ls_cons(x8, p0);
    } else {
        (% indirect call %);
        p0 = transl_item_single(p0, x0, &x5);
        x6 = create_pseudo(1, LOCATION_REGISTER); (% address of region for return value %);
        p0 = ls_cons(mkinst(INST_LEAL, x4, x6), p0);
        p0 = ls_cons(mkinst(INST_MOVL, x6, get_stack(0)), p0);
        p0 = set_arguments(p0, x3, 1, &x7);
        x8 = mkinst(INST_CALL_IND, x5, NULL);
        x8[INST_ARG] = x7;
        p0 = ls_cons(x8, p0);
    };
    x0 = 0;
    x3 = NULL;
    while (x0 < x2) {
        x3 = ls_cons(get_at(x4, x0), x3);
        x0 = x0 + 1;
    };
    *p2 = ls_reverse(x3);
    return p0;
};

transl_call: (p0, p1, p2) {
    allocate(6);
    x0 = p1[2]; (% function %);
    x1 = type_size(p1[1]);
    if (x1 > 1) {
        (% the function returns composite data %);
        return transl_call2(p0, p1, p2);
    };
    x2 = p1[3]; (% argument %);

    if (is_global_identifier(x0)) {
        (% immediate call %);
        x3 = mangle(x0[1], get_ident_name(x0));
        p0 = set_arguments(p0, x2, 0, &x4);
        x5 = mkinst(INST_CALL_IMM, mktup2(OPD_LABEL, x3), NULL);
        x5[INST_ARG] = x4;
        p0 = ls_cons(x5, p0);
    } else {
        (% indirect call %);
        p0 = transl_item_single(p0, x0, &x3);
        p0 = set_arguments(p0, x2, 0, &x4);
        x5 = mkinst(INST_CALL_IND, x3, NULL);
        x5[INST_ARG] = x4;
        p0 = ls_cons(x5, p0);
    };
    x4 = create_pseudo(1, LOCATION_ANY);
    p0 = ls_cons(mkinst(INST_MOVL, get_eax(), x4), p0);
    *p2 = ls_singleton(x4);
    return p0;
};

transl_unexpr: (p0, p1, p2) {
    allocate(2);
    if (p1[2] == UNOP_PLUS) {
	p0 = transl_item_single(p0, p1[3], &x0);
	x1 = create_pseudo(1, LOCATION_ANY);
	*p2 = ls_singleton(x1);
	p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
	return p0;
    };
    if (p1[2] == UNOP_MINUS) {
        p0 = transl_item_single(p0, p1[3], &x0);

        x1 = create_pseudo(1, LOCATION_ANY);
        *p2 = ls_singleton(x1);

        p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
        p0 = ls_cons(mkinst(INST_NEGL, x1, NULL), p0);
        return p0;
    };
    if (p1[2] == UNOP_INVERSE) {
        p0 = transl_item_single(p0, p1[3], &x0);
        x1 = create_pseudo(1, LOCATION_ANY);
        *p2 = ls_singleton(x1);
        p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
        p0 = ls_cons(mkinst(INST_NOTL, x1, NULL), p0);
        return p0;
    };
    if (p1[2] == UNOP_PREINCR) {
        p0 = transl_item_single(p0, p1[3], &x0);
        *p2 = ls_singleton(x0);
        p0 = ls_cons(mkinst(INST_INCL, x0, NULL), p0);
        return p0;
    };
    if (p1[2] == UNOP_PREDECR) {
        p0 = transl_item_single(p0, p1[3], &x0);
        *p2 = ls_singleton(x0);
        p0 = ls_cons(mkinst(INST_DECL, x0, NULL), p0);
        return p0;
    };
    if (p1[2] == UNOP_POSTINCR) {
        p0 = transl_item_single(p0, p1[3], &x0);
        x1 = create_pseudo(1, LOCATION_ANY);
        *p2 = ls_singleton(x1);
        p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
        p0 = ls_cons(mkinst(INST_INCL, x0, NULL), p0);
        return p0;
    };
    if (p1[2] == UNOP_POSTDECR) {
        p0 = transl_item_single(p0, p1[3], &x0);
        x1 = create_pseudo(1, LOCATION_ANY);
        *p2 = ls_singleton(x1);
        p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
        p0 = ls_cons(mkinst(INST_DECL, x0, NULL), p0);
        return p0;
    };
    not_implemented();
};

bininst: [0, INST_ADDL, INST_SUBL, INST_IMUL, INST_IDIV, INST_IDIV, INST_ORL, INST_XORL,
    INST_ANDL, INST_SHLL, INST_SHRL
];

transl_binexpr: (p0, p1, p2) {
    allocate(3);
    if (p1[2] == BINOP_DIV) {
        return transl_divexpr(p0, p1, p2);
    };
    if (p1[2] == BINOP_MOD) {
        return transl_modexpr(p0, p1, p2);
    };
    (% t = x op y
     %
     % <->
     %
     % t = x;
     % t op= y;
     %);
    p0 = transl_item_single(p0, p1[3], &x0);
    p0 = transl_item_single(p0, p1[4], &x1);
    x2 = create_pseudo(1, LOCATION_ANY);
    *p2 = ls_singleton(x2);
    p0 = ls_cons(mkinst(INST_MOVL, x0, x2), p0);
    p0 = ls_cons(mkinst(bininst[p1[2]], x1, x2), p0);
    return p0;
};

transl_simple_assign: (p0, p1, p2) {
    allocate(5);
    x0 = p1[3]; (% lhs %);
    x1 = p1[4]; (% rhs %);
    p0 = transl_item(p0, x0, &x2);
    p0 = transl_item(p0, x1, &x3);
    assert(ls_length(x2) == ls_length(x3));
    x4 = x2;
    while (x3 != NULL) {
        p0 = ls_cons(mkinst(INST_MOVL, ls_value(x3), ls_value(x4)), p0);
        x4 = ls_next(x4);
        x3 = ls_next(x3);
    };
    *p2 = x4;
    return p0;
};

transl_arith_assign: (p0, p1, p2) {
    allocate(5);
    x0 = p1[3]; (% lhs %);
    x1 = p1[4]; (% rhs %);
    p0 = transl_item(p0, mktup5(NODE_BINEXPR, p1[1], p1[2], p1[3], p1[4]), &x2);
    x3 = NULL;
    while (x2 != NULL) {
	x4 = create_pseudo(1, LOCATION_ANY);
	x3 = ls_cons(x4, x3);
	p0 = ls_cons(mkinst(INST_MOVL, ls_value(x2), x4), p0);
	x2 = ls_next(x2);
    };
    x3 = ls_reverse(x3);
    set_operand(x0, x3);
    *p2 = x3;
    return p0;
};

transl_tuple_assign_helper: (p0, p1, p2, p3) {
    allocate(5);
    if (p1[0] == NODE_DONTCARE) {
        x0 = type_size(p1[1]); (% number of registers required by this pattern %);
        x1 = NULL;
        while (x0 > 0) {
            x1 = ls_cons(ls_value(*p2), x1);
            *p2 = ls_next(*p2);
            x0 = x0 - 1;
        };
        *p3 = ls_reverse(x1);
        return p0;
    };
    if (p1[0] == NODE_IDENTIFIER) {
        x0 = type_size(p1[1]); (% number of registers required by this variable %);
        x1 = 0;
        x2 = NULL;
        while (x1 < x0) {
            x3 = create_pseudo(1, LOCATION_ANY);
            x2 = ls_cons(x3, x2);
            p0 = ls_cons(mkinst(INST_MOVL, ls_value(*p2), x3), p0);
            *p2 = ls_next(*p2);
            x1 = x1 + 1;
        };
        x2 = ls_reverse(x2);
        assert(x2 != NULL);
        set_operand(p1, x2);
        *p3 = x2;
        return p0;
    };
    if (p1[0] == NODE_TUPLE) {
        x0 = p1[TUPLE_LENGTH];
        x1 = p1[TUPLE_ELEMENTS];
        x2 = 0;
        x3 = NULL;
        while (x2 < x0) {
            p0 = transl_tuple_assign_helper(p0, x1[x2], p2, &x4);
            x3 = ls_append(x3, x4);
            x2 = x2 + 1;
        };
        *p3 = x3;
        return p0;
    };
    not_reachable();
};

transl_tuple_assign: (p0, p1, p2) {
    allocate(3);
    x0 = p1[3]; (% lhs %);
    x1 = p1[4]; (% rhs %);
    p0 = transl_item(p0, x1, &x2);
    p0 = transl_tuple_assign_helper(p0, x0, &x2, p2);
    assert(ls_length(x2) == 0);
    return p0;
};

transl_assign: (p0, p1, p2) {
    allocate(1);
    x0 = p1[3]; (% lhs %);
    if (x0[0] == NODE_IDENTIFIER) {
        if (p1[2] == BINOP_NONE) {
            return transl_simple_assign(p0, p1, p2);
        };
        return transl_arith_assign(p0, p1, p2);
    };
    if (x0[0] == NODE_TUPLE) {
        assert(p1[2] == BINOP_NONE);
        return transl_tuple_assign(p0, p1, p2);
    };
    if (x0[0] == NODE_FIELDREF) {
        if (p1[2] == BINOP_NONE) {
            return transl_simple_assign(p0, p1, p2);
        };
        return transl_arith_assign(p0, p1, p2);
    };
    not_reachable();
};

must_be_register_or_immediate: (p0, p1) {
    allocate(2);
    x0 = *p1;
    if (x0[0] == OPD_PSEUDO) {
        if (x0[PSEUDO_TYPE] != LOCATION_ANY) {
            x1 = create_pseudo(x0[PSEUDO_LENGTH], LOCATION_REGISTER);
            p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
            *p1 = x1;
            return p0;
        };
        x0[PSEUDO_TYPE] = LOCATION_REGISTER;
        return p0;
    };
    if (x0[0] == OPD_STACK) {
        x1 = create_pseudo(1, LOCATION_REGISTER);
        p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
        *p1 = x1;
        return p0;
    };
    if (x0[0] == OPD_ARG) {
        x1 = create_pseudo(1, LOCATION_REGISTER);
        p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
        *p1 = x1;
        return p0;
    };
    if (x0[0] == OPD_AT) {
        if (x0[2][0] == OPD_LABEL) {
            x1 = create_pseudo(1, LOCATION_REGISTER);
            p0 = ls_cons(mkinst(INST_MOVL, x0, x1), p0);
            *p1 = x1;
            return p0;
        };
    };
    return p0;
};

transl_divexpr: (p0, p1, p2) {
    allocate(3);
    (% t = x / y
     %
     % <->
     %
     % %eax = x
     % idiv y
     % t = %eax
     %);
    p0 = transl_item_single(p0, p1[3], &x0);
    p0 = transl_item_single(p0, p1[4], &x1);
    x2 = create_pseudo(1, LOCATION_ANY);
    *p2 = ls_singleton(x2);
    p0 = ls_cons(mkinst(INST_MOVL, x0, get_eax()), p0);
    p0 = ls_cons(mkinst(INST_MOVL, mktup2(OPD_INTEGER, 0), get_edx()), p0);
    p0 = must_be_register_or_immediate(p0, &x1);
    p0 = ls_cons(mkinst(INST_IDIV, x1, NULL), p0);
    p0 = ls_cons(mkinst(INST_MOVL, get_eax(), x2), p0);
    return p0;
};

transl_modexpr: (p0, p1, p2) {
    allocate(3);
    (% t = x % y
     %
     % <->
     %
     % %eax = x
     % idiv y
     % t = %edx
     %);
    p0 = transl_item_single(p0, p1[3], &x0);
    p0 = transl_item_single(p0, p1[4], &x1);
    x2 = create_pseudo(1, LOCATION_ANY);
    *p2 = ls_singleton(x2);
    p0 = ls_cons(mkinst(INST_MOVL, x0, get_eax()), p0);
    p0 = ls_cons(mkinst(INST_MOVL, mktup2(OPD_INTEGER, 0), get_edx()), p0);
    p0 = must_be_register_or_immediate(p0, &x1);
    p0 = ls_cons(mkinst(INST_IMOD, x1, NULL), p0);
    p0 = ls_cons(mkinst(INST_MOVL, get_edx(), x2), p0);
    return p0;
};

(% p0: output tcode, p1: tuple %);
transl_tuple: (p0, p1, p2) {
    allocate(5);
    x0 = p1[TUPLE_LENGTH];
    x1 = p1[TUPLE_ELEMENTS];
    x2 = 0;
    x3 = NULL;
    while (x2 < x0) {
	p0 = transl_item(p0, x1[x2], &x4);
	x3 = ls_append(x3, x4);
	x2 = x2 + 1;
    };
    *p2 = x3;
    return p0;
};

transl_code: (p0, p1, p2) {
    allocate(3);
    x0 = p1[2];
    x1 = NULL;
    while (x0 != NULL) {
        p0 = transl_item(p0, ls_value(x0), &x2);
        x0 = ls_next(x0);
    };
    return p0;
};

transl_var_decl: (p0, p1, p2) {
    allocate(5);
    x0 = p1[2]; (% lhs %);
    x1 = p1[3]; (% rhs %);
    p0 = transl_item(p0, x1, &x2);
    x3 = NULL;
    while (x2 != NULL) {
	x4 = create_pseudo(1, LOCATION_ANY);
	x3 = ls_cons(x4, x3);
	p0 = ls_cons(mkinst(INST_MOVL, ls_value(x2), x4), p0);
	x2 = ls_next(x2);
    };
    x3 = ls_reverse(x3);
    set_operand(x0, x3);
    *p2 = x3;
    return p0;
};

transl_tuple_decl_helper: (p0, p1, p2, p3) {
    allocate(5);
    if (p1[0] == NODE_DONTCARE) {
        x0 = type_size(p1[1]); (% number of registers required by this pattern %);
        x1 = NULL;
        while (x0 > 0) {
            x1 = ls_cons(ls_value(*p2), x1);
            *p2 = ls_next(*p2);
            x0 = x0 - 1;
        };
        *p3 = ls_reverse(x1);
        return p0;
    };
    if (p1[0] == NODE_IDENTIFIER) {
        x0 = type_size(p1[1]); (% number of registers required by this variable %);
        x1 = 0;
        x2 = NULL;
        while (x1 < x0) {
            x3 = create_pseudo(1, LOCATION_ANY);
            x2 = ls_cons(x3, x2);
            p0 = ls_cons(mkinst(INST_MOVL, ls_value(*p2), x3), p0);
            *p2 = ls_next(*p2);
            x1 = x1 + 1;
        };
        x2 = ls_reverse(x2);
        assert(x2 != NULL);
        set_operand(p1, x2);
        *p3 = x2;
        return p0;
    };
    if (p1[0] == NODE_TUPLE) {
        x0 = p1[TUPLE_LENGTH];
        x1 = p1[TUPLE_ELEMENTS];
        x2 = 0;
        x3 = NULL;
        while (x2 < x0) {
            p0 = transl_tuple_decl_helper(p0, x1[x2], p2, &x4);
            x3 = ls_append(x3, x4);
            x2 = x2 + 1;
        };
        *p3 = x3;
        return p0;
    };
    not_reachable();
};

transl_tuple_decl: (p0, p1, p2) {
    allocate(3);
    x0 = p1[2]; (% lhs %);
    x1 = p1[3]; (% rhs %);
    p0 = transl_item(p0, x1, &x2);
    p0 = transl_tuple_decl_helper(p0, x0, &x2, p2);
    assert(ls_length(x2) == 0);
    return p0;
};

transl_decl: (p0, p1, p2) {
    allocate(1);
    x0 = p1[2]; (% lhs %);
    if (x0[0] == NODE_IDENTIFIER) {
        return transl_var_decl(p0, p1, p2);
    };
    if (x0[0] == NODE_TUPLE) {
        return transl_tuple_decl(p0, p1, p2);
    };
    not_reachable();
};

transl_ret: (p0, p1, p2) {
    return ls_cons(mkinst(INST_RET, NULL, NULL), p0);
};

transl_retval: (p0, p1, p2) {
    allocate(4);
    p0 = transl_item(p0, p1[2], &x0);
    if (ls_length(x0) == 1) {
        p0 = ls_cons(mkinst(INST_MOVL, ls_value(x0), get_eax()), p0);
        x1 = mkinst(INST_RET, NULL, NULL);
        x1[INST_ARG] = TRUE;
        return ls_cons(x1, p0);
    } else {
        (% return composite value %);
        (% first argument is the address of the region to store it %);

        x1 = create_pseudo(1, LOCATION_REGISTER); (% for address %);
        p0 = ls_cons(mkinst(INST_MOVL, get_arg(0), x1), p0);
        x2 = 0; (% offset %);
        while (x0 != NULL) {
            x3 = mkinst(INST_STORE, ls_value(x0), x1);
            x3[INST_ARG] = x2; (% save offset %);
            p0 = ls_cons(x3, p0);
            x2 = x2 + 1;
            x0 = ls_next(x0);
        };
        x3 = mkinst(INST_RET, NULL, NULL);
        return ls_cons(x3, p0);
    };
};

transl_syscall: (p0, p1, p2) {
    allocate(7);
    x0 = p1[2]; (% argument tuple %);
    x1 = x0[TUPLE_LENGTH];
    x2 = x0[TUPLE_ELEMENTS];
    x3 = memalloc(4*x1); (% translated operands %);
    x4 = 0;

    while (x4 < x1) {
        p0 = transl_item_single(p0, x2[x4], &x5);
        x3[x4] = x5;
        x4 = x4 + 1;
    };

    (% save values of special purpose registers %);
    if (x1 > num_normal_regs()) {
	x4 = num_normal_regs();
	while (x4 < x1) {
	    p0 = ls_cons(mkinst(INST_PUSHL, get_physical_reg(x4), NULL), p0);
	    x4 = x4 + 1;
	};
    };

    x4 = 0;
    while (x4 < x1) {
        p0 = ls_cons(mkinst(INST_MOVL, x3[x4], get_physical_reg(x4)), p0);
        x4 = x4 + 1;
    };
    x6 = mkinst(INST_INT, mktup2(OPD_INTEGER, 128), NULL);
    x6[INST_ARG] = x1;

    p0 = ls_cons(x6, p0);

    (% restore special purpose registers %);
    if (x1 > num_normal_regs()) {
	x4 = num_normal_regs();
	while (x4 < x1) {
	    p0 = ls_cons(mkinst(INST_POPL, get_physical_reg(x4), NULL), p0);
	    x4 = x4 + 1;
	};
    };
    return p0;
};

transl_field: (p0, p1, p2) {
    transl_item(p0, p1[3], p2);
};

(% p0: type, p1: field name %);
get_field: (p0, p1) {
    allocate(5);
    x0 = 0; (% offset %);
    x1 = p0[TUPLE_T_LENGTH];
    x2 = p0[TUPLE_T_ELEMENTS];
    x3 = 0;
    while (x3 < x1) {
        x4 = x2[x3];
        if (has_name(x4, p1)) {
            return mktup2(x0, type_size(x4));
        };
        x0 = x0 + type_size(x4);
        x3 = x3 + 1;
    };
};

transl_fieldref: (p0, p1, p2) {
    allocate(7);
    x0 = p1[2]; (% lhs %);
    x1 = p1[3]; (% fiel name %);
    x2 = get_field(x0[1], x1); (% offset, length %);
    p0 = transl_item(p0, x0, &x3);
    x4 = x2[0]; (% offset %);
    x5 = x2[1]; (% length %);
    while (x4 > 0) {
        x3 = ls_next(x3);
        x4 = x4 - 1;
    };
    x6 = NULL;
    while (x5 > 0) {
        x6 = ls_cons(ls_value(x3), x6);
        x3 = ls_next(x3);
        x5 = x5 - 1;
    };
    *p2 = ls_reverse(x6);
    return p0;
};

transl_variant: (p0, p1, p2) {
    allocate(2);
    x0 = p1[3]; (% variant id %);
    p0 = transl_item(p0, p1[4], &x1); (% translate arg %);
    x1 = ls_cons(mktup2(OPD_INTEGER, x0), x1);
    *p2 = x1;
    return p0;
};

transl_void: (p0, p1, p2) {
    *p2 = NULL;
    return p0;
};

(% p0: output tcode, p1: item, p2: pointer to store p1's value  %);
transl_item: (p0, p1, p2) {
    allocate(1);
    x0 = transl_funcs[p1[0]];
    return x0(p0, p1, p2);
};

transl_item_single: (p0, p1, p2) {
    allocate(1);
    p0 = transl_item(p0, p1, &x0);
    assert(ls_length(x0) == 1);
    *p2 = ls_value(x0);
    return p0;
};

transl_extfuncs: [
    not_reachable, not_reachable, not_reachable, not_reachable, not_reachable,
    not_reachable, not_reachable, not_reachable, not_reachable, transl_extdecl,
    not_reachable, not_reachable, not_reachable, not_reachable, not_reachable,
    not_reachable, transl_export, not_reachable, not_reachable, not_reachable,
    not_reachable, not_reachable, transl_typedecl, not_reachable, not_reachable
];

(% p0: item %);
transl_fundecl: (p0) {
    allocate(7);

    reset_proc();
    puts("> compiling '");
    puts(get_ident_name(p0[2]));
    puts("' ...\n");

    x0 = mangle(p0[1], get_ident_name(p0[2]));
    x1 = p0[3]; (% lambda %);

    x2 = x1[2]; (% argument %);
    x3 = x2[TUPLE_LENGTH];
    x4 = x2[TUPLE_ELEMENTS];
    x5 = 0;
    while (x5 < x3) {
        set_operand(x4[x5], ls_singleton(create_pseudo(1, LOCATION_ANY)));
        x5 = x5 + 1;
    };

    x6 = ls_reverse(transl_code(NULL, x1[3]));
    x5 = 0;
    while (x5 < x3) {
        x6 = ls_cons(mkinst(INST_MOVL, get_arg(x5), get_operand_single(x4[x5])), x6);
        x5 = x5 + 1;
    };

    x6 = mktup5(TCODE_FUNC, x0, x1[2], x6, FALSE);

    (% deadcode elimination %);
    puts("> removing dead-instructions ...\n");
    eliminate_deadcode(x6);

    (% allocate registers %);
    puts("> allocating registers ...\n");
    regalloc(x6);

    return x6;
};

transl_static_data: (p0) {
    allocate(4);
    if (p0[0] == NODE_INTEGER) {
        if (p0[2] == 8) { return mktup2(DATA_CHAR, p0[3]); };
        if (p0[2] == 32) { return mktup2(DATA_INT, p0[3]); };
        not_reachable();
    };
    if (p0[0] == NODE_ARRAY) {
        x0 = p0[2]; (% length %);
        x1 = p0[3]; (% elements %);
        x2 = memalloc(4*x0); (% new elements %);
        x3 = 0;
        while (x3 < x0) {
            x2[x3] = transl_static_data(x1[x3]);
            x3 = x3 + 1;
        };
        return mktup3(DATA_ARRAY, x0, x2);
    };
    if (p0[0] == NODE_TUPLE) {
        x0 = p0[2]; (% length %);
        x1 = p0[3]; (% elements %);
        x2 = memalloc(4*x0); (% new elements %);
        x3 = 0;
        while (x3 < x0) {
            x2[x3] = transl_static_data(x1[x3]);
            x3 = x3 + 1;
        };
        return mktup3(DATA_TUPLE, x0, x2);
    };
    if (p0[0] == NODE_STRING) {
        x0 = new_label();
        add_topdecl(mktup4(TCODE_DATA, x0, mktup2(DATA_STRING, p0[2]), FALSE));
        return mktup2(DATA_LABEL, x0);
    };
    if (p0[0] == NODE_FIELD) {
        transl_static_data(p0[3]);
        return;
    };
    not_implemented();
};

(% p0: item %);
transl_extdecl: (p0) {
    allocate(3);

    if (p0[2][0] != NODE_IDENTIFIER) {
        fputs(stderr, "ERROR: does not support external declaration with pattern\n");
        exit(1);
    };

    x0 = p0[1]; (% type %);
    (% generate label %);
    if (x0[0] == NODE_LAMBDA_T) {
        return transl_fundecl(p0);
    };

    x1 = get_ident_name(p0[2]);

    set_operand(p0[2], ls_singleton(mktup2(OPD_LABEL, x1)));

    (% flatten nested static data and translate to tcode %);
    x2 = transl_static_data(p0[3]);

    return mktup4(TCODE_DATA, x1, x2, FALSE);
};

(% p0: item %);
transl_export: (p0) {
    allocate(1);
    x0 = transl_extitem(p0[1]);
    if (x0[0] == TCODE_DATA) {
        x0[3] = TRUE;
        return x0;
    };
    if (x0[0] == TCODE_FUNC) {
        x0[4] = TRUE;
        return x0;
    };
    fputs(stderr, "ERROR: invalid export directive\n");
    exit(1);
};

transl_typedecl: (p0) {
    return NULL;
};


(% p0: item %);
transl_extitem: (p0) {
    allocate(1);
    x0 = transl_extfuncs[p0[0]];
    return x0(p0);
};

(% p0: program %);
tcodegen: (p0) {
    allocate(3);

    init_proc();

    vtable = mkvec(num_variable());

    topdecl = NULL;

    x0 = p0[1];
    x1 = NULL;
    while (x0 != NULL) {
        x2 = transl_extitem(ls_value(x0));
        if (x2 != NULL) {
            x1 = ls_cons(x2, x1);
        };
        x0 = ls_next(x0);
    };
    return ls_append(ls_reverse(x1), ls_reverse(topdecl));
};
