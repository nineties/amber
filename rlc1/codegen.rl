(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: codegen.rl 2010-02-22 18:06:25 nineties $ 
 %);

include(stddef, code);
export(codegen);

not_reachable: (p0) {
    fputs(stderr, "ERROR: not reachable here\n");
    exit(1);
};

not_implemented: (p0) {
    fputs(stderr, "ERROR: not implemented\n");
    exit(1);
};

ext_funcs: [not_implemented ,not_implemented ,not_implemented ,not_implemented
    ,not_implemented ,not_implemented ,not_implemented ,not_implemented ,ext_decl
    ,not_implemented ,not_implemented ,not_implemented ,not_implemented ,not_implemented
    ,not_implemented ,not_implemented ,not_implemented
];

(% the label of i-th string literal is L.str[i] %);
string_literals : NULL; (% vector of string literals %);

(% p1: index %);
put_string_label: (p0, p1) {
    fputs(p0, "L.str");
    fputi(p0, p1);
};

(% p0: NODE_STRING %);
new_string_literal: (p0) {
    vec_pushback(string_literals, p0);
    return vec_size(string_literals)-1;
};

gen_string_literals: (p0) {
    allocate(3);
    x0 = 0;
    x1 = vec_size(string_literals);
    while (x0 < x1) {
        x2 = vec_at(string_literals, x0);
        put_string_label(p0, x0);
        fputs(p0, ": .string ");
        fputc(p0, '"');
        fputs(p0, x2[2]);
        fputc(p0, '"');
        fputc(p0, '\n');
        x0 = x0 + 1;
    }
};

(% p1: var, p2: value %);
ext_char_decl: (p0, p1, p2) {
    fputs(p0, p1[2]);
    fputs(p0, ":\t.byte ");
    fputi(p0, p2[3]);
    fputc(p0, '\n');
};

ext_int_decl: (p0, p1, p2) {
    fputs(p0, p1[2]);
    fputs(p0, ":\t.long ");
    fputi(p0, p2[3]);
    fputc(p0, '\n');
};

emit_static_value: (p0, p1) {
    allocate(3);
    if (p1[0] == NODE_INTEGER) {
        if (p1[2] == 8) {
            fputs(p0, "\t.byte ");
            fputi(p0, p1[3]);
            fputc(p0, '\n');
            return;
        };
        if (p1[2] == 32) {
            fputs(p0, "\t.long ");
            fputi(p0, p1[3]);
            fputc(p0, '\n');
            return;
        };
        not_implemented();
    };
    if (p1[0] == NODE_STRING) {
        x0 = new_string_literal(p1);
        fputs(p0, "\t.long ");
        put_string_label(p0, x0);
        fputc(p0, '\n');
        return;
    };
    if (p1[0] == NODE_ARRAY) {
        x0 = p1[2]; (% length %);
        x1 = p1[3]; (% ptr %);
        x2 = 0;
        while (x2 < x0) {
            emit_static_value(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return;
    };
    if (p1[0] == NODE_TUPLE) {
        x0 = p1[2]; (% length %);
        x1 = p1[3]; (% ptr %);
        x2 = 0;
        while (x2 < x0) {
            emit_static_value(p0, x1[x2]);
            x2 = x2 + 1;
        };
        return;
    };
    not_implemented();
};

ext_pointer_decl: (p0, p1, p2) {
    fputs(p0, p1[2]);
    fputs(p0, ":\n");
    emit_static_value(p0, p2);
};

ext_array_decl: (p0, p1, p2) {
    allocate(3);
    fputs(p0, p1[2]);
    fputs(p0, ":\n");
    x0 = p2[2]; (% length %);
    x1 = p2[3]; (% ptr %);
    x2 = 0;
    while (x2 < x0) {
        emit_static_value(p0, x1[x2]);
        x2 = x2 + 1;
    };
};

ext_tuple_decl: (p0, p1, p2) {
    allocate(3);
    fputs(p0, p1[2]);
    fputs(p0, ":\n");
    x0 = p2[2]; (% length %);
    x1 = p2[3]; (% ptr %);
    x2 = 0;
    while (x2 < x0) {
        emit_static_value(p0, x1[x2]);
        x2 = x2 + 1;
    };
};

ext_decl: (p0, p1) {
    allocate(1);
    x0 = p1[1]; (% type %);
    if (x0[0] == NODE_CHAR_T) { return ext_char_decl(p0, p1[2], p1[3]); };
    if (x0[0] == NODE_INT_T)  { return ext_int_decl(p0, p1[2], p1[3]); };
    if (x0[0] == NODE_POINTER_T) { return ext_pointer_decl(p0, p1[2], p1[3]); };
    if (x0[0] == NODE_ARRAY_T) { return ext_array_decl(p0, p1[2], p1[3]); };
    if (x0[0] == NODE_TUPLE_T) { return ext_tuple_decl(p0, p1[2], p1[3]); };
    not_implemented();
};

codegen_external_item: (p0, p1) {
    allocate(1);
    x0 = ext_funcs[p1[0]];
    x0(p0, p1);
};

(% p0: output channel, p1: NODE_PROG %);
codegen: (p0, p1) {
    allocate(1);

    string_literals = mkvec(0);

    x0 = p1[1];
    while (x0 != NULL) {
        codegen_external_item(p0, ls_value(x0));
        x0 = ls_next(x0);
    };

    gen_string_literals(p0);
};
