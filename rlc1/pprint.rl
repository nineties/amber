(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: pprint.rl 2010-02-22 18:06:31 nineties $ 
 %);

include(stddef,code);

export(put_prog, put_item, put_type, put_tyscheme);

ppfuncs: [put_prog, put_rewrite, put_integer, put_string, put_identifier, put_array,
    put_tuple, put_code, put_decl, put_callop, put_subsop, put_codeop, put_unexpr, put_binexpr,
    put_assign, put_ret, put_retval
];

(% priority of expressions %);
PRI_PRIMARY        => 0;
PRI_POSTFIX        => 1;
PRI_ELSE           => 2;
PRI_PREFIX         => 3;
PRI_MULTIPLICATIVE => 4;
PRI_ADDITIVE       => 5;
PRI_SHIFT          => 6;
PRI_RELATIONAL     => 7;
PRI_EQUALITY       => 8;
PRI_AND            => 9;
PRI_XOR            => 10;
PRI_OR             => 13;
PRI_SEQAND         => 14;
PRI_SEQOR          => 15;
PRI_ASSIGNMENT     => 16;
PRI_COMMAND        => 17;
PRI_DECLARATION    => 18;
PRI_REWRITE        => 19;
PRI_EXTERNAL       => 20;

priority: [0, 0, 0, 0, 0, 0, 0, 0, 14, 3];

indent_depth : 0;
put_indent: (p0) {
    allocate(1);
    x0 = 0;
    while (x0 < indent_depth) {
        fputc(p0, ' ');
        x0 = x0 + 1;
    };
};

(% p0: output channel p1: item %);
put_item: (p0, p1) {
    return ppfuncs[p1[0]](p0, p1, 0);
};

(% p0: output channel, p1: item, p2: priority %);
put_subitem: (p0, p1, p2) {
    allocate(2);
    x0 = priority[p1[0]];
    if (x0 > p2) { fputc(p0, '('); };
    put_item(p0, p1);
    if (x0 > p2) { fputc(p0, ')'); };
};

(% p0: output channel, p1: program %);
put_prog: (p0, p1) {
    allocate(1);
    indent_depth = 0;
    x0 = p1[1];
    while (x0 != NULL) {
        put_item(p0, ls_value(x0));
        fputs(p0, ";\n");
        x0 = ls_next(x0);
    };
    indent_depth = 0;
};

put_integer: (p0, p1) {
    fputi(p0, p1[3]);
};

put_string: (p0, p1) {
    fputs(p0, p1[2]);
};

put_identifier: (p0, p1) {
    fputs(p0, p1[2]);
};

put_symbol: (p0, p1) {
    fputs(p0, p1[2]);
};

put_array: (p0, p1) {
    allocate(3);
    fputc(p0, '[');
    x0 = 0;
    x1 = p1[2];
    while (x0 < x1) {
        x2 = p1[3];
        put_item(p0, x2[x0]);
        if (x0 < x1 - 1) {
            fputc(p0, ',');
        };
        x0 = x0 + 1;
    };
    fputc(p0, ']');
};

put_code: (p0, p1) {
    allocate(1);
    fputc(p0, '{');

    indent_depth = indent_depth + 4;
    x0 = p1[2];
    while (x0 != NULL) {
        fputc(p0, '\n');
        put_indent(p0);
        put_item(p0, ls_value(x0));
        fputc(p0, ';');
        x0 = ls_next(x0);
    };
    indent_depth = indent_depth - 4;

    fputc(p0, '\n');
    put_indent(p0);
    fputc(p0, '}');
};

put_tuple: (p0, p1) {
    allocate(3);
    fputc(p0, '(');
    x0 = 0;
    x1 = p1[2];
    while (x0 < x1) {
        x2 = p1[3];
        put_item(p0, x2[x0]);
        if (x0 < x1 - 1) {
            fputc(p0, ',');
        };
        x0 = x0 + 1;
    };
    fputc(p0, ')');
};

put_pattern: (p0, p1) {
    allocate(2);
    fputc(p0, '(');
    fputs(p0, p1[1]);
    x0 = 0;
    x1 = p1[2];
    while (x0 < x1) {
        fputc(p0, ' ');
        put_subitem(p0, p1[x0+3], PRI_PRIMARY);
        x0 = x0 + 1;
    };
    fputc(p0, ')');
};

put_rewrite: (p0, p1) {
    put_subitem(p0, p1[1], PRI_DECLARATION);
    fputs(p0, " => ");
    put_subitem(p0, p1[2], PRI_REWRITE);
};

put_decl: (p0, p1) {
    put_subitem(p0, p1[2], PRI_COMMAND);
    fputc(p0, ':');
    put_subitem(p0, p1[3], PRI_DECLARATION);
};

put_callop: (p0, p1) {
    put_subitem(p0, p1[2], PRI_POSTFIX);
    put_subitem(p0, p1[3], PRI_PRIMARY);
};

put_subsop: (p0, p1) {
    put_subitem(p0, p1[2], PRI_POSTFIX);
    put_subitem(p0, p1[3], PRI_PRIMARY);
};

put_codeop: (p0, p1) {
    put_subitem(p0, p1[2], PRI_POSTFIX);
    put_subitem(p0, p1[3], PRI_PRIMARY);
};

unop_string: ["+", "-", "~", "!", "&", "*", "++", "--", "++", "--"];
unop_arg_priority: [PRI_POSTFIX, PRI_POSTFIX, PRI_POSTFIX, PRI_POSTFIX, PRI_POSTFIX,
    PRI_POSTFIX, PRI_POSTFIX, PRI_POSTFIX, PRI_POSTFIX, PRI_POSTFIX];

binop_string: ["", "+", "-", "*", "/", "%", "|", "^", "&", "<<", ">>", "==", "!=", "<", ">",
    "<=", ">=", "||", "&&"];
binop_lhs_priority: [0, PRI_ADDITIVE, PRI_ADDITIVE, PRI_MULTIPLICATIVE, PRI_MULTIPLICATIVE,
    PRI_MULTIPLICATIVE, PRI_OR, PRI_XOR, PRI_AND, PRI_SHIFT, PRI_EQUALITY, PRI_EQUALITY,
    PRI_RELATIONAL, PRI_RELATIONAL, PRI_RELATIONAL, PRI_RELATIONAL, PRI_SEQOR, PRI_SEQAND];
binop_rhs_priority: [0, PRI_MULTIPLICATIVE, PRI_MULTIPLICATIVE, PRI_PREFIX, PRI_PREFIX,
    PRI_PREFIX, PRI_XOR, PRI_AND, PRI_EQUALITY, PRI_ADDITIVE, PRI_ADDITIVE, PRI_RELATIONAL,
    PRI_RELATIONAL, PRI_SHIFT, PRI_SHIFT, PRI_SHIFT, PRI_SHIFT, PRI_SEQAND, PRI_OR];


put_unexpr: (p0, p1) {
    allocate(1);
    x0 = p1[2]; (% operator %);
    if (x0 == UNOP_POSTINCR) {
        put_subitem(p0, unop_arg_priority[x0], p1[3]);
        fputs(p0, unop_string[x0]);
        return;
    };
    if (x0 == UNOP_POSTDECR) {
        put_subitem(p0, unop_arg_priority[x0], p1[3]);
        fputs(p0, unop_string[x0]);
        return;
    };
    fputs(p0, unop_string[x0]);
    put_subitem(p0, unop_arg_priority[x0], p1[3]);
};

put_binexpr: (p0, p1) {
    allocate(1);
    x0 = p1[2]; (% operator %);
    put_subitem(p0, binop_lhs_priority[x0], p1[3]);
    fputc(p0, ' ');
    fputs(p0, binop_string[x0]);
    fputc(p0, ' ');
    put_subitem(p0, binop_rhs_priority[x0], p1[4]);
};

put_assign: (p0, p1) {
    allocate(1);
    x0 = p1[2]; (% operator %);
    put_subitem(p0, PRI_SEQOR, p1[3]);
    fputc(p0, ' ');
    fputs(p0, binop_string[x0]);
    fputs(p0, "= ");
    put_subitem(p0, PRI_ASSIGNMENT, p1[4]);
};

put_ret: (p0, p1) {
    fputs(p0, "return");
};

put_retval: (p0, p1) {
    fputs(p0, "return ");
    put_subitem(p0, PRI_ASSIGNMENT, p1[2]);
};

pptype_funcs: [ put_void_t, put_bool_t, put_char_t, put_int_t, put_int64_t, put_float_t, put_double_t, put_array_t, put_code_t, put_tuple_t, put_function_t, put_tyvar];

put_type: (p0, p1) {
    allocate(1);
    x0 = pptype_funcs[p1[0]];
    x0(p0, p1);
};

put_void_t: (p0, p1) {
    fputs(p0, "void");
};

put_bool_t: (p0, p1) {
    fputs(p0, "bool");
};

put_char_t: (p0, p1) {
    fputs(p0, "char");
};

put_int_t: (p0, p1) {
    fputs(p0, "int");
};

put_int64_t: (p0, p1) {
    fputs(p0, "int64");
};

put_float_t: (p0, p1) {
    fputs(p0, "float");
};

put_double_t: (p0, p1) {
    fputs(p0, "double");
};

put_array_t: (p0, p1) {
    fputc(p0, '[');
    put_type(p0, p1[1]);
    fputc(p0, ']');
};

put_code_t: (p0, p1) {
    fputc(p0, '{');
    put_type(p0, p1[1]);
    fputc(p0, '}');
};

put_tuple_t: (p0, p1) {
    allocate(2);
    fputc(p0, '(');
    x0 = p1[1]; (% length %);
    x1 = 0;
    while (x1 < x0) {
        put_type(p0, (p1[2])[x2]);
        x1 = x1 + 1;
        if (x1 < x0 ) { fputc(p0, ','); };
    };
    fputc(p0, ')');
};

put_function_t: (p0, p1) {
    put_type(p0, p1[1]);
    fputc(p0, ' ');
    put_type(p0, p1[2]);
};

put_tyvar: (p0, p1) {
    fputc(p0, 't');
    fputi(p0, p1[1]);
};

put_tyscheme: (p0, p1) {
    allocate(1);
    x0 = p1[0]; (% id set %);
    if (x0 == NULL) { return put_type(p0, p1[1]); };
    while (x0 != NULL) {
        fputc(p0, 't');
        fputi(p0, ls_value(x0));
        x0 = ls_next(x0);
        if (x0 != NULL) { fputc(p0, ' '); };
    };
    fputc(p0, '.');
    put_type(p0, p1[1]);
};
