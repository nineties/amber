(%
 % rowl - generation 2
 % Copyright (C) 2010 nineties
 %
 % $Id: io.rl 2010-05-06 17:26:15 nineties $
 %)

import sys;
import alloc;
import string;

export type ichan;
export type ochan;

type ichan: Ichan (fd:int, buf:char[], beg:int, end:int);
type ochan: Ochan (fd:int, buf:char[], index:int);

ReadBufSize  => 512;
WriteBufSize => 512;;

make_ichan: (fd!int) {
    return new Ichan(fd, new_array(ReadBufSize) '\0', 0, 0);
};

make_ochan: (fd!int) {
    return new Ochan(fd, new_array(WriteBufSize) '\0', 0);
};

export
open_in: (file) {
    return make_ichan(sys_open(to_cstr(file), OpenRDONLY));
};

export
open_out: (file) {
    return make_ochan(sys_open(to_cstr(file), 577));
};

export stdin:  make_ichan(0); (% standard input %)
export stdout: make_ochan(1); (% standard output %)
export stderr: make_ochan(2); (% standard error output %)

export
flush: (chan!ochan*) {
    if (chan->index > 0) {
        sys_write(chan->fd, chan->buf, chan->index);
        chan->index = 0;
    };
};

export
close_in: (chan!ichan*) {
    sys_close(chan->fd);
};

export
close_out: (chan!ochan*) {
    flush(chan);
    sys_close(chan->fd);
};

export
put_to: (chan!ochan*, c!char) {
    chan->buf[chan->index++] = c;
    if (chan->index == WriteBufSize) {
        flush(chan);
        return;
    } else if (c == '\n') {
        flush(chan);
        return;
    }
};

export
put_to: (chan!ochan*, s!string) {
    len: length(s);
    for (i:0, i < len, i++) {
        put_to(chan, at(s, i));
    }
};

putnum_digits: static_array('\0', 10); (% 32bit decimal integer are less than 11 digits %);

export
put: (c!char) {
    put_to(stdout, c);
};

export
put: (s!string) {
    put_to(stdout, s);
};
