(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: lex.rl 2010-05-26 23:28:40 nineties $
 %);

include(stddef, code);
include(token);

export(lexer_test);
export(lexer_init, lexer_push, lexer_pop);
export(fputloc);
export(token_text, token_len, token_val);
export(lex, unput);


(%
 % regular expressions:
 % spaces     : [\n\r\t ]
 % letter     : [A-Za-z]
 % decimal    : -?[1-9][0-9]*
 % octal      : 0[0-7]*
 % hex        : ("0x"|"0X")[0-9a-fA-F]+
 % escape     : \\['"\\abfnrtv0]
 % character  : \'({escape}|[^\\\'\n])\'
 % string     : \"({escape}|[^\\\"\n])*\" | \(\/ .* \/\)
 % opchar     : [!#$%&=--^|@+*:/?<>.\,_]
 % symbol     : ({letter}|{opchar})({letter}|{opchar}|[0-9])*
 %);

(% character group  %);
CH_EOF       => 0;  (% \0 %);
CH_INVALID   => 1;
CH_SPACES    => 2;  (% [\t\r ]   %);
CH_NL        => 3;  (% '\n   %);
CH_ZERO      => 4;  (% 0   %);
CH_1_7       => 5;  (% [1-7]   %);
CH_8_9       => 6;  (% [89]   %);
CH_abf       => 7;  (% [abf]  %);
CH_rtv       => 8;  (% [rtv]  %);
CH_HEXCH     => 9;  (% [A-Fa-f]/[abf]   %);
CH_OTHERCH   => 10; (% [G-Zg-z_]/[nrtv]   %);
CH_X         => 11; (% x|X   %);
CH_N         => 12; (% n  %);
CH_SQUOTE    => 13; (% \' %);
CH_DQUOTE    => 14; (% \" %);
CH_BACKSLASH => 16; (% \\ %);
CH_LPAREN    => 17; (% (  %);
CH_RPAREN    => 18; (% )  %);
CH_SEMI      => 19; (% ;  %);
CH_SPECIAL   => 20; (% `@. %);
CH_SYMBOL    => 21; (% other characters %);

chgroup : [
     0,  1,  1,  1,  1,  1,  1,  1,  1,  2,  3,  1,  1,  2,  1,  1,
     1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
     2, 21, 14, 21, 21, 15, 21, 13, 17, 18, 21, 21, 21, 21, 20, 21,
     4,  5,  5,  5,  5,  5,  5,  5,  6,  6, 21, 19, 21, 21, 21, 21,
    20,  9,  9,  9,  9,  9,  9, 10, 10, 10, 10, 10, 10, 10, 10, 10,
    10, 10, 10, 10, 10, 10, 10, 10, 11, 10, 10, 21, 16, 21, 21, 10,
    20,  7,  7,  9,  9,  9,  7, 10, 10, 10, 10, 10, 10, 10, 12, 10,
    10, 10,  8, 10,  8, 10,  8, 10, 11, 10, 10, 21, 21, 21, 21,  1,
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
 %
 %
 %
 %    spaces
 %   +---+
 %   v   |
 % +---+ |   EOF +---+
 % | 0 +-+------>|@1 | (end)
 % +---+ |       +---+
 %       | ;     +---+       +---+
 %       +------>| 2 +--+--->| 0 | (comment)
 %       |       +---+  |    +---+
 %       |         ^    |[^\n]
 %       |         +----+
 %       | `@()  +---+
 %       +------>|@3 | (special symbol)
 %       |       +---+                         (hexadecimal integer)
 %       | 0     +---+ xX      +---+ hexdigit +---+
 %       +------>|@4 +-------->| 5 +--------->|@6 +--+
 %       |       +-+-+         +---+          +---+  | hexdigit
 %       |         |[0-7]                       ^    |
 %       |         v                            +----+
 %       |       +---+ (octal integer)
 %       |       |@7 |--+
 %       |       +-+-+  |[0-7]
 %       |         ^    |
 %       |         +----+
 %       | [1-9] +---+ (decimal integer)
 %       +------>|@8 +--+
 %       |       +---+  |[0-9]
 %       |         ^    |
 %       |         +----+
 %       | -     +---+ [1-9]  +---+ (negative decimal integer)
 %       +------>|@9 +------->|@10+-+
 %       |       +---+        +---+ |[0-9]
 %       |  (operator -)        ^   |
 %       |                      +---+
 %       |'        +---+ [^\\\n]    +---+ '     +---+
 %       +-------->| 11+----------->| 12+------>|@13|
 %       |         +-+-+            +---+       +---+
 %       |           |\   +---+['"\\abfnrtv0] +---+'   +---+
 %       |           +--->| 14+-------------->| 15+--->|@16|
 %       |                +---+               +---+    +---+
 %       |"        +---+   "          +---+
 %       +-------->| 17+--+---------->|@19|
 %       |         +---+  |           +---+
 %       |           ^    |[^\\\"\n]
 %       |           +----+
 %       |           |    |\
 %       |           |    v
 %       |           |  +---+
 %       |           +--+ 18|
 %       |['"\\abfnrtv0]+---+
 %       |
 %       |        +---+
 %       +------->|@20+-+
 %                +---+ |^({spaces}|[;)
 %                  ^   |
 %                  +---+
 %
 % error state:
 %   e1: invalid character
 %   e2: junk letters after integer
 %   e3: octal digit is expected
 %   e4: hexadecimal digit is expected
 %   e5: invalid escape sequence
 %   e6: unterminated character literal
 %   e7: unterminated string literal
 %   e8: invalid symbol character
 %);

(% === jump table ==== %);
(%
 C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C
 H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H   H
 _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _
 E   I   S   N   Z   1   8   a   r   H   O   X   N   S   D   S   B   L   R   S   S   S
 O   N   P   L   E   _   _   b   t   E   T   :   :   Q   Q   L   A   P   P   E   P   Y
 F   V   A   :   R   7   9   f   v   X   H   :   :   U   U   A   C   A   A   M   E   M
 :   A   C   :   O   :   :   :   :   C   E   :   :   O   O   S   K   R   R   I   C   B
 :   L   E   :   :   :   :   :   :   H   R   :   :   T   T   H   S   E   E   :   I   O
 :   I   S   :   :   :   :   :   :   :   C   :   :   E   E   :   L   N   N   :   A   L
 :   D   :   :   :   :   :   :   :   :   H   :   :   :   :   :   A   :   :   :   L   :
 :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   S   :   :   :   :   :
 :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   H   :   :   :   :   :
 :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :   :
%);
s0next: [
 s1, e1, s0, s0, s4, s8, s8,s20,s20,s20,s20,s20,s20,s11,s17,s20, e1, s3, s3, s2, s3,s20
];
s2next: [
 s1, e1, s2, s0, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2, s2
];
s4next: [
fin, e1,fin,fin, s7, s7, e3, e3, e3, e3, e3, s5, e3, e3, e3, e3, e3, e3,fin,fin, e8, e3
];
s5next: [
fin, e1,fin,fin, s6, s6, s6, e4, e4, s6, e4, e4, e4, e4, e4, e4, e4, e4, e4,fin, e8, e4
];
s6next: [
fin, e1,fin,fin, s6, s6, s6, e4, e4, s6, e4, e4, e4, e4, e4, e4, e4, e4,fin,fin, e8, e4
];
s7next: [
fin, e1,fin,fin, s7, s7, e3, e3, e3, e3, e3, e3, e3, e3, e3, e3, e3, e3,fin,fin, e8, e3
];
s8next: [
fin, e1,fin,fin, s8, s8, s8, e2, e2, e2, e2, e2, e2, e2, e2, e2, e2, e2,fin,fin, e8, e2
];
s9next: [
fin, e1,fin,fin, e1,s10,s10, e2, e2, e2, e2, e2, e2, e2, e2, e2, e2, e2,fin,fin, e8, e2
];
s10next: [
fin, e1,fin,fin,s10,s10,s10, e2, e2, e2, e2, e2, e2, e2, e2, e2, e2, e2,fin,fin, e8, e2
];
s11next: [
 e6, e1,s12, e6,s12,s12,s12,s12,s12,s12,s12,s12,s12,s12,s12,s12,s14,s12,s12,s12,s12,s12
];
s14next: [
 e5, e1, e5, e5,s15, e5, e5,s15,s15, e5, e5, e5,s15,s15,s15, e5,s15, e5, e5, e5, e5, e5
];
s17next: [
 e7, e1,s17, e7,s17,s17,s17,s17,s17,s17,s17,s17,s17,s17,s19,s17,s18,s17,s17,s17,s17,s17
];
s18next: [
 e5, e1, e5, e5,s17, e5, e5,s17,s17, e5, e5, e5,s17,s17,s17, e5,s17, e5, e5, e5, e5, e5
];
s20next: [
fin, e1,fin,fin,s20,s20,s20,s20,s20,s20,s20,s20,s20, e8, e8,s20, e8, e8,fin,fin, e8,s20
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
};

init_tokbuf: () {
    toktag = 0;
    tokval = 0;
    cvec_resize(tokbuf, 0);
    cvec_pushback(tokbuf, '\0');
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
    if (lookahead() == CH_SPACES) {
        consume();
        goto &s0;
    };
    if (lookahead() == CH_NL) {
        consume();
        goto &s0;
    };
    init_tokbuf();
    goto s0next[lookahead()];
label s1;
    accept(TOK_END);
    return TOK_END;
label s2;
    consume();
    goto s2next[lookahead()];
label s3;
    accept(consume()); (% ( or ) %);
    goto &fin;
label s4;
    consume();
    tokval = 0;
    accept(TOK_INT);
    goto s4next[lookahead()];
label s5;
    consume();
    goto s5next[lookahead()];
label s6;
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
    goto s6next[lookahead()];
label s7;
    x0 = consume();
    tokval = tokval * 8 + (x0 - '0');
    accept(TOK_INT);
    goto s7next[lookahead()];
label s8;
    x0 = consume();
    tokval = tokval * 10 + (x0 - '0');
    accept(TOK_INT);
    goto s8next[lookahead()];
label s9;
    consume();
    accept(TOK_SYMBOL); (% operator - %);
    goto s9next[lookahead()];
label s10;
    x0 = consume();
    tokval = - tokval * 10 - (x0 - '0');
    accept(TOK_INT);
    goto s10next[lookahead()];
label s11;
    consume();
    goto s11next[lookahead()];
label s12;
    consume();
    if (lookahead() == CH_SQUOTE) {
        goto &s13;
    } else {
        goto &e6;
    };
label s13;
    consume();
    accept(TOK_CHAR);
    tokval = cvec_at(tokbuf, 1);
    goto &fin;
label s14;
    consume();
    goto s14next[lookahead()];
label s15;
    consume();
    if (lookahead() == CH_SQUOTE) {
        goto &s16;
    } else {
        goto &e6;
    };
label s16;
    consume();
    tokval = esc2val(cvec_at(tokbuf, 2));
    accept(TOK_CHAR);
    goto &fin;
label s17;
    consume();
    goto s17next[lookahead()];
label s18;
    consume();
    goto s18next[lookahead()];
label s19;
    consume();
    accept(TOK_STRING);
    goto &fin;
label s20;
    consume();
    accept(TOK_SYMBOL);
    goto s20next[lookahead()];
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
    lex_error("invalid symbol character");
};

strhash: (p0) {
    allocate(1);
    x0 = 0;
    while (rch(p0, 0) != '\0') {
        x0 = x0 * 7 + rch(p0, 0);
        p0 = p0 + 1;
    };
    return x0;
};

print_token: (p0) {
    if (p0 == TOK_END) {
        puts("<eof>");
        return;
    };
    if (p0 == TOK_CHAR) {
        puts("CHAR:");
        puti(token_val());
        return;
    };
    if (p0 == TOK_INT) {
        puts("INT:");
        puti(token_val());
        return;
    };
    if (p0 == TOK_STRING) {
        puts("STRING:");
        puts(token_text());
        return;
    };
    if (p0 == TOK_SYMBOL) {
        puts("SYMBOL:");
        puts(token_text());
        return;
    };
    putc(p0);
};

(% p0: file name, p1: input channel %);
lexer_test: (p0, p1) {
    allocate(1);
    lexer_init(p0, p1);
    while (1) {
        x0 = lex();
        print_token(x0);
        puts("\n");
        if (x0 == TOK_END) { return; };
    }
}
