import sys;
import alloc;
import string;

export type ichan;
export type ochan;

type ichan: Ichan (fd:int, buf:char[], beg:int, end:int);
type ochan: Ochan (fd:int, buf:char[], index:int);

ReadBufSize  => 512;
WriteBufSize => 512;;

make_ichan: (fd@int) {
    return new Ichan(fd, new_array(ReadBufSize) '\0', 0, 0);
};

make_ochan: (fd@int) {
    return new Ochan(fd, new_array(WriteBufSize) '\0', 0);
};

export open_in: (file) {
    return make_ichan(sys_open(to_cstr(file), OpenRDONLY));
};

export close_in: (chan @ ichan*) {
    sys_close(chan->fd);
};

export close_out: (chan @ ochan*) {
    sys_close(chan->fd);
};

export flush: (chan @ ochan*) {
    if (chan->index) {
        sys_write(chan->fd, chan->buf, chan->index);
        chan->index = 0;
    }
};

