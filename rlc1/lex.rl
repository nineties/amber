(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: lex.rl 2010-04-08 21:57:40 nineties $
 %);

include(stddef, code);
include(token);

export(lexer_init, lexer_push, lexer_pop);
export(fputloc);
export(token_text, token_len, token_val);
export(lex, unput);
export(add_constr);


(%
 % regular expressions:
 % spaces     : [\n\r\t ]
 % letter     : [A-Za-z_]
 % decimal    : [1-9][0-9]*
 % octal      : 0[0-7]*
 % hex        : ("0x"|"0X")[0-9a-fA-F]+
 % dont care  : _
 % identifier : {letter}({letter)|{digit})*
 % escape     : \\['"\\abfnrtv0]
 % character  : \'({escape}|[^\\\'\n])\'
 % string     : \"({escape}|[^\\\"\n])*\" | \(\/ .* \/\)
 % opchar     : [!#$%&=-~^|`@+*:/?<>.]
 % operator   : opchar+
 %);

(% character group  %);
CH_EOF       => 0;  (%   \0   %);
CH_INVALID   => 1;
CH_SPACES    => 2;  (%   [\t\r ]   %);
CH_NL        => 3;  (%   '\n   %);
CH_ZERO      => 4;  (%   0   %);
CH_1_7       => 5;  (%   [1-7]   %);
CH_8_9       => 6;  (%   [89]   %);
CH_abf       => 7;  (%   [abf]  %);
CH_rtv       => 8;  (%   [rtv]  %);
CH_HEXCH     => 9;  (%   [A-Fa-f]/[abf]   %);
CH_OTHERCH   => 10; (%   [G-Zg-z_]/[nrtv]   %);
CH_X         => 11; (%   x|X   %);
CH_N         => 12; (%   n   %);
CH_SQUOTE    => 13; (%   \'   %);
CH_DQUOTE    => 14; (%   \"   %);
CH_PERCENT   => 15; (%   %   %);
CH_BACKSLASH => 16; (%   \\   %);
CH_LPAREN    => 17; (%   (   %);
CH_RPAREN    => 18; (%   )   %);
CH_OPCHAR    => 19; (%   [!#$%&=-~^|`@+*:?<>.]   %);
CH_SYMBOL    => 20; (%   other characters   %);

chgroup : [
     0,  1,  1,  1,  1,  1,  1,  1,  1,  2,  3,  1,  1,  2,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     2, 19, 14, 19, 19, 15, 19, 13, 17, 18, 19, 19, 20, 19, 19, 19,
     4,  5,  5,  5,  5,  5,  5,  5,  6,  6, 19, 20, 19, 19, 19, 19,
    19,  9,  9,  9,  9,  9,  9, 10, 10, 10, 10, 10, 10, 10, 10, 10,
    10, 10, 10, 10, 10, 10, 10, 10, 11, 10, 10, 20, 16, 20, 19, 10,
    19,  7,  7,  9,  9,  9,  7, 10, 10, 10, 10, 10, 10, 10, 12, 10,
    10, 10,  8, 10,  8, 10,  8, 10, 11, 10, 10, 20, 19, 20, 19,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1
];

(% === state transition diagram ===
 % +---+  null     +---+
 % | 0 +-+-------->|@1 |
 % +---+ |         +---+
 %       |space    +---+      +---+
 %       +-------->| 2 +--+-->| 0 |
 %       |         +---+  |   +---+
 %       |           ^    |space
 %       |           +----+
 %       |0        +---+   xX   +---+ hexdigit +---+
 %       +-------->|@3 +------->| 4 +--------->|@5 +--+
 %       |         +-+-+        +---+          +---+  |
 %       |           |[0-7]                      ^    | hexdigit
 %       |           v                           +----+
 %       |         +---+
 %       |         |@6 +--+
 %       |         +---+  |[0-7]
 %       |           ^    |
 %       |           +----+
 %       |[1-9]    +---+
 %       +-------->|@7 +--+
 %       |         +---+  |
 %       |           ^    |[0-9]
 %       |           +----+
 %       |letter   +---+
 %       +-------->|@8 +--+
 %       |         +---+  |
 %       |           ^    |letter|digit
 %       |           +----+
 %       |'        +---+ [^\\\n]    +---+ '     +---+
 %       +-------->| 9 +----------->| 10+------>|@11|
 %       |         +-+-+            +---+       +---+
 %       |           |\   +---+['"\\abfnrtv0] +---+'   +---+
 %       |           +--->| 12+-------------->| 13+--->|@14|
 %       |                +---+               +---+    +---+
 %       |"        +---+   "          +---+
 %       +-------->| 15+--+---------->|@17|
 %       |         +---+  |           +---+
 %       |           ^    |[^\\\"\n]
 %       |           +----+
 %       |           |    |\
 %       |           |    v
 %       |           |  +---+
 %       |           +--+ 16|
 %       |['"\\abfnrtv0]+---+
 %       |         +---+
 %       +-------->|@18+--+                            depth++
 %       |opchar   +---+  |opchar          (   +---+ %   +---+
 %       |           ^    |     +----------+-->| 22+---->| 20|
 %       |           +----+     |          |   +---+     +---+
 %       |(        +---+ %    +-+-+ %    +-+-+ )    +---+
 %       +-------->|@19+----->| 20+-+--->| 21+-+-+->|@23|
 %       |depth=0  +---+      +---+ |    +---+ | |  +---+
 %       |                      ^   |    % ^   | |  depth==0
 %       |                other +---+      +---+ |
 %       |                      +--------------+ |
 %       |                      +----------------+depth--
 %       |other symbol  +---+
 %       +------------->|@24|
 %                      +---+
 % error state:
 %   e1: invalid character
 %   e2: junk letters after integer
 %   e3: octal digit is expected
 %   e4: hexadecimal digit is expected
 %   e5: invalid escape sequence
 %   e6: unterminated character literal
 %   e7: unterminated string literal
 %   e8: unterminated comment literal
 %);

(% === jump table ==== %);
(%
 C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C 
 H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H
 _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _ 
 E   I   S   N   Z   1   8   a   r   H   O   X   N   S   D   S   B   L   R   O   S 
 O   N   P   L   E   _   _   b   t   E   T   :   :   Q   Q   L   A   P   P   P   Y 
 F   V   A   :   R   7   9   f   v   X   H   :   :   U   U   A   C   A   A   C   M 
 :   A   C   :   O   :   :   :   :   C   E   :   :   O   O   S   K   R   R   H   B 
 :   L   E   :   :   :   :   :   :   H   R   :   :   T   T   H   S   E   E   A   O 
 :   I   S   :   :   :   :   :   :   :   C   :   :   E   E   :   L   N   N   R   L 
 :   D   :   :   :   :   :   :   :   :   H   :   :   :   :   :   A   :   :   :   : 
 :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   S   :   :   :   : 
 :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   H   :   :   :   : 
 :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   : 
%);
s0next: [
 s1, e1, s2, s2, s3, s7, s7, s8, s8, s8, s8, s8, s8, s9,s15,s18, e1,s19,s24,s18,s24
];
s3next: [
fin, e1,fin,fin, s6, s6, e3, e2, e2, e2, e2, s4, e2,fin,fin,fin,fin,fin,fin,fin,fin
];
s4next: [
 e4, e1, e4, e4, s5, s5, s5, s5, e4, s5, e4, e4, e4, e4, e4, e4, e4, e4, e4, e4, e4
];
s5next: [
fin, e1,fin,fin, s5, s5, s5, s5, e4, s5, e4, e4, e4,fin,fin,fin,fin,fin,fin,fin,fin
];
s6next: [
fin, e1,fin,fin, s6, s6, e3, e3, e3, e3, e3, e3, e3,fin,fin,fin,fin,fin,fin,fin,fin
];
s7next: [
fin, e1,fin,fin, s7, s7, s7, e2, e2, e2, e2, e2, e2,fin,fin,fin,fin,fin,fin,fin,fin
];
s8next: [
s25, e1,s25,s25, s8, s8, s8, s8, s8, s8, s8, s8, s8,s25,s25,s25,s25,s25,s25,s25,s25
];
s9next: [
 e6, e1,s10, e6,s10,s10,s10,s10,s10,s10,s10,s10,s10,s10,s10,s10,s12,s10,s10,s10,s10
];
s12next: [
 e5, e1, e5, e5,s13, e5, e5,s13,s13, e5, e5, e5,s13,s13,s13, e5,s13, e5, e5, e5, e5
];
s15next: [
 e7, e1,s15, e7,s15,s15,s15,s15,s15,s15,s15,s15,s15,s15,s17,s15,s16,s15,s15,s15,s15
];
s16next: [
 e5, e1, e5, e5,s15, e5, e5,s15,s15, e5, e5, e5,s15,s15,s15, e5,s15, e5, e5, e5, e5
];

srcfile  : NULL;
srcline  : 1;
srcclmn  : 1;
lexichan : NULL;
tokbuf   : NULL;  (% character array %);
tokval   : 0;
toktag   : 0;
unputted : FALSE;

inbuf : NULL;
inbuf_beg : 0;
last_pos : 0;
last_file: NULL;
last_line: 0;
last_clmn: 0;

lexer_stack: NULL;

(% p0: file name, p1: input channel %);
lexer_init: (p0, p1) {
    srcfile = p0;
    srcline = 1;
    srcclmn = 1;
    lexichan = p1;
    tokbuf = mkcvec(0);
    cvec_pushback(tokbuf, '\0');
    tokval = 0;
    toktag = 0;
    unputted = FALSE;
    inbuf  = mkcvec(0);
    inbuf_beg = 0;
    last_pos = 0;
    last_file = p0;
    last_line = 1;
    last_clmn = 1;

    keyword_init();
    operator_init();
    constr_set = mkset(&strhash, &streq, 10);
};

(% p0: new filename, p1: new input channel %);
lexer_push: (p0, p1) {
    allocate(1);
    x0 = mktup6(srcfile, srcline, srcclmn, lexichan, inbuf, inbuf_beg);
    lexer_stack = ls_cons(x0, lexer_stack);
    srcfile = p0;
    srcline = 1;
    srcclmn = 1;
    lexichan = p1;
    inbuf = mkvec(0);
    inbuf_beg = 0;
};

lexer_pop: () {
    allocate(1);
    assert(lexer_stack != NULL);
    x0 = ls_value(lexer_stack);
    lexer_stack = ls_next(lexer_stack);
    srcfile   = x0[0];
    srcline   = x0[1];
    srcclmn   = x0[2];
    lexichan  = x0[3];
    inbuf     = x0[4];
    inbuf_beg = x0[5];
};

token_text: () {
    return cvec_ptr(tokbuf);
};

token_len: () {
    return cvec_size(tokbuf) - 1;
};

token_val: () {
    return tokval;
};

lookahead: () {
    allocate(1);
    if (inbuf_beg == cvec_size(inbuf)) {
        cvec_pushback(inbuf, fgetc(lexichan));
    };
    x0 = cvec_at(inbuf, inbuf_beg);
    if (x0 == EOF) { return CH_EOF; };
    return chgroup[x0];
};

consume: () {
    allocate(1);
    if (inbuf_beg == cvec_size(inbuf)) {
        cvec_pushback(inbuf, fgetc(lexichan));
    };
    x0 = cvec_at(inbuf, inbuf_beg);
    inbuf_beg = inbuf_beg + 1;
    if (x0 == '\n') {
        srcline = srcline + 1;
        srcclmn = 1;
    } else {
        srcclmn = srcclmn + 1;
    };
    cvec_put(tokbuf, cvec_size(tokbuf)-1, x0);
    cvec_pushback(tokbuf, '\0');
    return x0;
};

(% p0: position %);
rewind: (p0) {
    cvec_put(tokbuf, p0, '\0');
    inbuf_beg = inbuf_beg - (cvec_size(tokbuf) - p0);
    srcfile = last_file;
    srcline = last_line;
    srcclmn = last_clmn;
};

unput: () {
    if (unputted) {
        fputs(stderr, "ERROR: try to unput two or more tokens\n");
        exit(1);
    };
    unputted = TRUE;
};


(% p0: output channel %);
fputloc: (p0) {
    fputs(p0, srcfile);
    fputc(p0, ':');
    fputi(p0, srcline);
    fputc(p0, ':');
    fputi(p0, srcclmn);
};

(% p0: token tag %);
accept: (p0) {
    toktag = p0;
    last_pos = cvec_size(tokbuf);
    last_file = srcfile;
    last_line = srcline;
    last_clmn = srcclmn;
};

accept_ident: () {
    allocate(1);
    x0 = token_text();
    if (rch(x0, 0) == '_') {
        if (rch(x0, 1) == '\0') {
            (% don't care pattern %);
            accept('_');
            return;
        };
    };
    x0 = map_find(keyword_map, token_text());
    if (x0 != NULL) {
        accept(x0);
        return;
    };
    x0 = map_find(operator_map, token_text());
    if (x0 != 0) {
        accept(x0);
        return;
    };
    if (set_contains(constr_set, token_text())) {
        accept(TOK_CONSTR);
        return;
    };
    accept(TOK_IDENT);
};

init_tokbuf: () {
    toktag = 0;
    tokval = 0;
    cvec_resize(tokbuf, 0);
    cvec_pushback(tokbuf, '\0');
    last_pos = 0;
};

(% p0: message %);
lex_error: (p0) {
    flush(stdout);
    fputloc(stderr);
    fputs(stderr, ": ");
    fputs(stderr, p0);
    fputc(stderr, '\n');
    exit(1);
};

(% escape sequence to its value %);
esc2val_table: [
 34, 0, 0, 0, 0, 39, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 92, 0, 0, 0, 0, 7, 8, 0, 0, 0, 12, 0,
 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 13, 0, 9, 0, 11
];

esc2val: (p0) {
    return esc2val_table[p0 - '"'];
};

lex: () {
    allocate(2);
    if (unputted) {
        unputted = FALSE;
        return toktag;
    };
label s0;
    init_tokbuf();
    goto s0next[lookahead()];
label s1;
    accept(TOK_END);
    return TOK_END;
label s2;
    consume();
    x0 = lookahead();
    if (x0 == CH_SPACES) { goto &s2; };
    if (x0 == CH_NL)     { goto &s2; };
    goto &s0;
label s3;
    consume();
    accept(TOK_INT);
    goto s3next[lookahead()];
label s4;
    consume();
    goto s4next[lookahead()];
label s5;
    x0 = consume();
    if ('a' <= x0) {
        x0 = x0 - 'a' + 10;
    } else {
        if ('A' <= x0) {
            x0 = x0 - 'A' + 10;
        } else {
            x0 = x0 - '0';
        }
    };
    tokval = tokval * 16 + x0;
    accept(TOK_INT);
    goto s5next[lookahead()];
label s6;
    x0 = consume();
    tokval = tokval * 8 + (x0 - '0');
    accept(TOK_INT);
    goto s6next[lookahead()];
label s7;
    x0 = consume();
    tokval = tokval * 10 + (x0 - '0');
    accept(TOK_INT);
    goto s7next[lookahead()];
label s8;
    consume();
    goto s8next[lookahead()];
label s9;
    consume();
    goto s9next[lookahead()];
label s10;
    consume();
    if (lookahead() == CH_SQUOTE) {
        goto &s11;
    } else {
        goto &e6;
    };
label s11;
    consume();
    accept(TOK_CHAR);
    tokval = cvec_at(tokbuf, 1);
    goto &fin;
label s12;
    consume();
    goto s12next[lookahead()];
label s13;
    consume();
    if (lookahead() == CH_SQUOTE) {
        goto &s14;
    } else {
        goto &e6;
    };
label s14;
    consume();
    tokval = esc2val(cvec_at(tokbuf, 2));
    accept(TOK_CHAR);
    goto &fin;
label s15;
    consume();
    goto s15next[lookahead()];
label s16;
    consume();
    goto s16next[lookahead()];
label s17;
    consume();
    accept(TOK_STRING);
    goto &fin;
label s18;
    consume();
    x0 = map_find(operator_map, token_text());
    if (x0 != 0) {
        accept(x0);
    };
    x0 = lookahead();
    if (x0 == CH_OPCHAR)  { goto &s18; };
    if (x0 == CH_PERCENT) { goto &s18; };
    if (last_pos == 0) {
        goto &e1;
    };
    rewind(last_pos);
    goto &fin;
label s19;
    consume();
    if (lookahead() == CH_PERCENT) {
        x1 = 0;  (% init depth %);
        goto &s20;
    } else {
        accept('(');
        goto &fin;
    };
label s20;
    consume();
    x0 = lookahead();
    if (x0 == CH_LPAREN)  { goto &s22; };
    if (x0 == CH_PERCENT) { goto &s21; };
    if (x0 == CH_INVALID) { goto &e1; };
    if (x0 == CH_EOF)     { goto &e8; };
    goto &s20;
label s21;
    consume();
    x0 = lookahead();
    if (x0 == CH_LPAREN)  { goto &s22; };
    if (x0 == CH_PERCENT) { goto &s21; };
    if (x0 == CH_RPAREN) {
        if (x1 == 0) {
            goto &s23;
        };
        x1 = x1 - 1; (% decrement depth %);
        goto &s20;
    };
    if (x0 == CH_INVALID) { goto &e1; };
    if (x0 == CH_EOF)     { goto &e8; };
    goto &s20;
label s22;
    consume();
    x0 = lookahead();
    if (x0 == CH_PERCENT) {
        x1 = x1 + 1;
        goto &s20;
    };
    if (x0 == CH_INVALID) { goto &e1; };
    if (x0 == CH_EOF)     { goto &e8; };
    goto &s20;
label s23;
    consume();
    (% finished comment block %);
    goto &s0;
label s24;
    accept(consume());
    goto &fin;
label s25;
    accept_ident();
    goto &fin;
label fin;
    return toktag;
label e1;
    lex_error("invalid character");
label e2;
    lex_error("junk letter(s) after integer");
label e3;
    lex_error("octal digit is expected");
label e4;
    lex_error("hexadecimal digit is expected");
label e5;
    lex_error("invalid escape sequence");
label e6;
    lex_error("unterminated character literal");
label e7;
    lex_error("unterminated string literal");
label e8;
    lex_error("unterminated comment literal");
};

keyword_map : NULL;
constr_set  : NULL;

strhash: (p0) {
    allocate(1);
    x0 = 0;
    while (rch(p0, 0) != '\0') {
        x0 = x0 * 7 + rch(p0, 0);
        p0 = p0 + 1;
    };
    return x0;
};

(% p0: name %);
add_constr: (p0) {
    if (set_contains(constr_set, p0)) {
        fputs(stderr, "ERROR: duplicated declaration of constructor '");
        fputs(stderr, p0);
        fputs(stderr, "'\n");
        exit(1);
    };
    set_add(constr_set, p0);
};

keyword_init: () {
    keyword_map = mkmap(&strhash, &streq, 10);
    map_add(keyword_map, "export", TOK_EXPORT);
    map_add(keyword_map, "import", TOK_IMPORT);
    map_add(keyword_map, "external", TOK_EXTERNAL);
    map_add(keyword_map, "return", TOK_RETURN);
    map_add(keyword_map, "syscall", TOK_SYSCALL);
    map_add(keyword_map, "char", TOK_CHAR_T);
    map_add(keyword_map, "int", TOK_INT_T);
    map_add(keyword_map, "float", TOK_FLOAT_T);
    map_add(keyword_map, "double", TOK_DOUBLE_T);
    map_add(keyword_map, "void", TOK_VOID_T);
    map_add(keyword_map, "type", TOK_TYPE);
    map_add(keyword_map, "if", TOK_IF);
    map_add(keyword_map, "else", TOK_ELSE);
    map_add(keyword_map, "static_array", TOK_SARRAY);
    map_add(keyword_map, "cast", TOK_CAST);
};

operator_map : NULL;
operator_init: () {
    operator_map = mkmap(&strhash, &streq, 20);
    map_add(operator_map, "#", '#');
    map_add(operator_map, "!", '!');
    map_add(operator_map, "%", '%');
    map_add(operator_map, "&", '&');
    map_add(operator_map, "=", '=');
    map_add(operator_map, "-", '-');
    map_add(operator_map, "~", '~');
    map_add(operator_map, "^", '^');
    map_add(operator_map, "|", '|');
    map_add(operator_map, "*", '*');
    map_add(operator_map, ":", ':');
    map_add(operator_map, "+", '+');
    map_add(operator_map, "<", '<');
    map_add(operator_map, ">", '>');
    map_add(operator_map, ".", '.');
    map_add(operator_map, "/", '/');
    map_add(operator_map, "@", '@');
    map_add(operator_map, "=>", TOK_REWRITE);
    map_add(operator_map, "+=", TOK_ADDASGN);
    map_add(operator_map, "-=", TOK_SUBASGN);
    map_add(operator_map, "*=", TOK_MULASGN);
    map_add(operator_map, "/=", TOK_DIVASGN);
    map_add(operator_map, "%=", TOK_MODASGN);
    map_add(operator_map, "|=", TOK_ORASGN);
    map_add(operator_map, "^=", TOK_XORASGN);
    map_add(operator_map, "&=", TOK_ANDASGN);
    map_add(operator_map, "<<=", TOK_LSHIFTASGN);
    map_add(operator_map, ">>=", TOK_RSHIFTASGN);
    map_add(operator_map, "<<", TOK_LSHIFT);
    map_add(operator_map, ">>", TOK_RSHIFT);
    map_add(operator_map, "==", TOK_EQ);
    map_add(operator_map, "!=", TOK_NE);
    map_add(operator_map, "<=", TOK_LE);
    map_add(operator_map, ">=", TOK_GE);
    map_add(operator_map, "&&", TOK_SEQAND);
    map_add(operator_map, "||", TOK_SEQOR);
    map_add(operator_map, "++", TOK_INCR);
    map_add(operator_map, "--", TOK_DECR);
    map_add(operator_map, "->", TOK_ARROW);
};
