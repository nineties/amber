import sys;
import alloc;
import string;

export type ichan;
export type ochan;

type ichan: (fd:int, buf:char[], beg:int, end:int)*;
type ochan: (fd:int, buf:char[], index:int)*;

ReadBufSize  => 512;
WriteBufSize => 512;;

make_ichan: (fd@int) {
    return new (fd, new_array(ReadBufSize) '\0', 0, 0);
};

make_ochan: (fd@int) {
    return new (fd, new_array(WriteBufSize) '\0', 0);
};

export
open_in: (file) {
    return make_ichan(sys_open(to_cstr(file), OpenRDONLY));
};
