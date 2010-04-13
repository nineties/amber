export type string;
type string: (ptr:char[], len:int)*;

length: (str@string) {
    return str->len;
};
