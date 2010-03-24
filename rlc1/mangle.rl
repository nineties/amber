(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: mangle.rl 2010-03-24 13:46:12 nineties $
 %);

(% name mangling %);

include(code);
export(mangle);

(%
 % type-suffix:
 % void   -> v
 % char   -> c
 % int    -> i
 % float  -> f
 % double -> d
 % pointer(T) -> mangle(T) P
 % array(len,T) -> mangle(T) len A
 % tuple(len,types) -> mangle(types) len T
 % lambda(P,R) -> mangle(P) mangle(R) L
 %);

(% p0: type, p1: name %);

BUFLEN => 128;
namebuf: char [BUFLEN];
namebuf_idx: 0;

reset_namebuf: () {
    namebuf_idx = 0;
    wch(namebuf, 0, '\0');
};

put_namechar: (p0) {
    if (namebuf_idx >= BUFLEN-1) {
	fputs(stderr, "ERROR: too long label name");
	fputs(stderr, namebuf);
	fputs(stderr, "...\n");
	exit(1);
    };
    wch(namebuf, namebuf_idx, p0);
    namebuf_idx = namebuf_idx + 1;
    wch(namebuf, namebuf_idx, '\0');
};

put_namestr: (p0) {
    while (rch(p0, 0) != '\0') {
	put_namechar(rch(p0, 0));
	p0 = p0 + 1;
    };
};

nameint_digits: char [10]; (% 32bit decimal integers are less than 11 digits %);
put_nameint: (p0, p1) {
    allocate(1);

    wch(nameint_digits, 0, p1%10 + '0');
    p1 = p1/10;
    x0 = 0;
    while (p1 != 0) {
        x0 = x0 + 1;
        wch(nameint_digits, x0, p1%10 + '0');
        p1 = p1/10;
    };

    while (x0 >= 0) {
	put_namechar(rch(nameint_digits, x0));
        x0 = x0 - 1;
    };
};

(% p0: type %);
gen_type_suffix: (p0) {
    allocate(3);
    if (p0[0] == NODE_VOID_T) { return put_namechar('v'); };
    if (p0[0] == NODE_CHAR_T) { return put_namechar('c'); };
    if (p0[0] == NODE_INT_T)  { return put_namechar('i'); };
    if (p0[0] == NODE_FLOAT_T) { return put_namechar('f'); };
    if (p0[0] == NODE_DOUBLE_T) { return put_namechar('d'); };
    if (p0[0] == NODE_POINTER_T) {
	gen_type_suffix(p0[POINTER_T_BASE]);
	put_namechar('P');
	return;
    };
    if (p0[0] == NODE_ARRAY_T) {
	gen_type_suffix(p0[ARRAY_T_ELEMENT]);
	put_nameint(p0[ARRAY_T_LENGTH]);
	put_namechar('A');
	return;
    };
    if (p0[0] == NODE_TUPLE_T) {
	x0 = p0[TUPLE_T_ELEMENTS];
	x1 = p0[TUPLE_T_LENGTH];
	x2 = 0;
	while (x2 < x1) {
	    gen_type_suffix(x0[x2]);
	    x2 = x2 + 1;
	};
	put_nameint(x1);
	put_namechar('T');
	return;
    };
    if (p0[0] == NODE_LAMBDA_T) {
	gen_type_suffix(p0[LAMBDA_T_PARAM]);
	gen_type_suffix(p0[LAMBDA_T_RETURN]);
	put_namechar('L');
	return;
    };
    fputs(stderr, "ERROR: not reachable\n");
    exit(1);
};

mangle: (p0, p1) {
    reset_namebuf();
    put_namechar('_');
    put_namestr(p1);
    put_namechar('.');
    gen_type_suffix(p0);
    return strdup(namebuf);
};

