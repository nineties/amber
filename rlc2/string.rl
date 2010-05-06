(%
 % rowl - generation 2
 % Copyright (C) 2010 nineties
 %
 % $Id: string.rl 2010-05-06 15:21:26 nineties $
 %)

export type string;
type string: (ptr:char[], len:int)*;

export
length: (str!string) {
    return str->len;
};

export
at: (str!string, idx!int) {
    return str->ptr[idx];
};

export
to_cstr: (str!string) {
    return str->ptr;
};

export
cstr_len: (str!char[]) {
    i : 0;
    while (str[i] != '\0') {
        i++;
    };
    return i;
};
