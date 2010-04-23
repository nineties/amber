export type string;
type string: (ptr:char[], len:int)*;

export
length: (str!string) {
    return str->len;
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