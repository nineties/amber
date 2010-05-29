(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: stdlib.rl 2010-05-29 12:52:39 nineties $
 %);

include(stddef);

export(init_io);
export(open_in, open_out, close_in, close_out);
export(stdin, stdout, stderr);
export(exit, assert, panic, flush);
export(fgetc, fnextc, fputc, fputs, fputi, fputx);
export(getc, nextc, putc, puts, puti, putx);
export(strhash, strlen, strcpy, strdup, streq);
export(memset, memcpy);
export(fork, waitpid, unlink, execve);

(% system calls %);
SYS_EXIT    => 1;
SYS_FORK    => 2;
SYS_READ    => 3;
SYS_WRITE   => 4;
SYS_OPEN    => 5;
SYS_CLOSE   => 6;
SYS_WAITPID => 7;
SYS_UNLINK  => 10;
SYS_EXECVE  => 11;

O_RDONLY => 0;
O_WRONLY => 1;
O_RDWR   => 2;
O_CREAT  => 64;
O_TRUNC  => 512;
O_APPEND => 1024;

RDBUFSZ => 512;
WRBUFSZ => 512;

(% I/O channel object:
 %   input chan:  (fd, buffer, beg, end)
 %   output chan: (fd, buffer, index)
 %);

ICHAN_FD  => 0;
ICHAN_BUF => 1;
ICHAN_BEG => 2;
ICHAN_END => 3;
OCHAN_FD  => 0;
OCHAN_BUF => 1;
OCHAN_IDX => 2;

STDIN_FD  => 0;
STDOUT_FD => 1;
STDERR_FD => 2;

stdin  : NULL;
stdout : NULL;
stderr : NULL;

ochanv: 0; (% array of output channels %);

(% p0 : file descriptor %);
mkichan: (p0) {
    allocate(1);
    x0 = memalloc(RDBUFSZ);
    x0 = mktup4(p0, x0, 0, 0);
    return x0;
};

(% p0 : file descriptor %);
mkochan: (p0) {
    allocate(1);
    x0 = memalloc(WRBUFSZ);
    x0 = mktup3(p0, x0, 0);
    vec_pushback(ochanv, x0);
    return x0;
};

init_io: () {
    stdin  = mkichan(STDIN_FD);
    ochanv = mkvec(0);
    stdout = mkochan(STDOUT_FD);
    stderr = mkochan(STDERR_FD);
};

(% p0: file name %);
open_in: (p0) {
    allocate(1);
    x0 = syscall(SYS_OPEN, p0, O_RDONLY);
    if (x0 < 0) { panic("open failed"); };
    return mkichan(x0);
};

(% p0: file name %);
open_out: (p0) {
    allocate(1);
    (% 420 == 0644 %);
    x0 = syscall(SYS_OPEN, p0, O_WRONLY|O_CREAT|O_TRUNC, 420);
    if (x0 < 0) { panic("open failed"); };
    return mkochan(x0);
};

(% p0: input channel %);
close_in: (p0) {
    syscall(SYS_CLOSE, p0[ICHAN_FD]);
};

(% p0: output channel %);
close_out: (p0) {
    syscall(SYS_CLOSE, p0[OCHAN_FD]);
};

(% exit(status) %);
exit: (p0) {
    allocate(1);
    x0 = 0;
    while (x0 < vec_size(ochanv)) {
        flush(vec_at(ochanv, x0));
        x0 = x0 + 1;
    };
    finalize_mem();
    syscall(SYS_EXIT, p0);
};

assert: (p0) {
    if (p0 == FALSE) {
        panic("assertion failure");
    };
};

(% panic(char *msg) %);
panic: (p0) {
    fputs(stderr, "PANIC: ");
    fputs(stderr, p0);
    fputc(stderr, '\n');
    exit(1);
};

(% p0: output channel %);
flush: (p0) {
    if (p0[OCHAN_IDX] > 0) {
        syscall(SYS_WRITE, p0[OCHAN_FD], p0[OCHAN_BUF], p0[OCHAN_IDX]);
        p0[OCHAN_IDX] = 0;
    }
};

(% p0: input channel %);
fill_inbuf: (p0) {
    allocate(1);
    if (p0[ICHAN_BEG] == p0[ICHAN_END]) {
        (% input buf is empty %);
        x0 = syscall(SYS_READ, p0[ICHAN_FD], p0[ICHAN_BUF], RDBUFSZ);
        p0[ICHAN_END] = x0;
        p0[ICHAN_BEG] = 0;
    }
};

(% p0: input channel %);
fgetc: (p0) {
    allocate(1);
    fill_inbuf(p0);
    if (p0[ICHAN_BEG] == p0[ICHAN_END]) {
        return EOF;
    };
    x0 = rch(p0[ICHAN_BUF], p0[ICHAN_BEG]);
    p0[ICHAN_BEG] = p0[ICHAN_BEG] + 1;
    return x0;
};

getc: () {
    return fgetc(stdin);
};

(% looks ahead next character
 % p0: input channel
 %);
fnextc: (p0) {
    fill_inbuf(p0);
    if (p0[ICHAN_BEG] == p0[ICHAN_END]) {
        return EOF;
    };
    return rch(p0[ICHAN_BUF], p0[ICHAN_BEG]);
};

nextc: () {
    return fnextc(stdin);
};

(% p0: output channel, p1: character %);
fputc: (p0, p1) {
    if (p0[OCHAN_FD] == STDERR_FD) {
        syscall(SYS_WRITE, STDERR_FD, &p1, 1);
        return;
    };
    wch(p0[OCHAN_BUF], p0[OCHAN_IDX], p1);
    p0[OCHAN_IDX] = p0[OCHAN_IDX] + 1;
    if (p0[OCHAN_IDX] == WRBUFSZ) {
        flush(p0);
        return;
    };
    if (p1 == '\n') {
        flush(p0);
        return;
    }
};

putc: (p0) {
    fputc(stdout, p0);
};

(% p0: output channel, p1: string %);
fputs: (p0, p1) {
    if (p0[OCHAN_FD] == STDERR_FD) {
        syscall(SYS_WRITE, STDERR_FD, p1, strlen(p1));
        return;
    };
    while (rch(p1,0) != '\0') {
        fputc(p0, rch(p1, 0));
        p1 = p1+1;
    }
};

puts: (p0) {
    fputs(stdout, p0);
};

(% p0: output channel, p1: value %);
puti_digits: char [10]; (% 32bit decimal integers are less than 11 digits %);
fputi: (p0, p1) {
    allocate(1);

    if (p1 < 0) {
	fputc(p0, '-');
        fputi(p0, -p1);
        return;
    };

    wch(puti_digits, 0, p1%10 + '0');
    p1 = p1/10;
    x0 = 0;
    while (p1 != 0) {
        x0 = x0 + 1;
        wch(puti_digits, x0, p1%10 + '0');
        p1 = p1/10;
    };

    while (x0 >= 0) {
        fputc(p0, rch(puti_digits, x0));
        x0 = x0 - 1;
    };
};

puti: (p0) {
    fputi(stdout, p0);
};

tohexdigits: "0123456789abcdef";
(% 32 bit hexadecimal integers are less than 9 digits %);
putx_digits: char [8];

(%p0: output channel, p1: value %);
fputx: (p0, p1) {
    allocate(1);

    fputs(p0, "0x");
    x0 = 0;
    while (x0 < 8) {
        wch(putx_digits, x0, rch(tohexdigits, p1%16));
        p1 = p1/16;
        x0 = x0 + 1;
    };

    x0 = x0 - 1;
    while (x0 >= 0) {
        fputc(p0, rch(putx_digits, x0));
        x0 = x0 - 1;
    };
};

putx: (p0) {
    fputx(stdout, p0);
};

(% strhash(char *str) %);
strhash: (p0) {
    allocate(1);
    x0 = 0;
    while (rch(p0, 0) != '\0') {
        x0 = x0 * 7 + rch(p0, 0);
        p0 = p0 + 1;
    };
    return x0;
};

(% strlen(char *str) %);
strlen: (p0) {
    allocate(1);
    x0 = 0;
    while (rch(p0, 0) != '\0') {
        x0 = x0 + 1;
        p0 = p0 + 1;
    };
    return x0;
};

(% strcpy(char *dest, char *src) %);
strcpy: (p0, p1) {
    while (rch(p1, 0) != '\0') {
        wch(p0, 0, rch(p1, 0));
        p0 = p0 + 1;
        p1 = p1 + 1;
    };
    wch(p0, 0, '\0');
};

(% strdup(char *s) %);
strdup: (p0) {
    allocate(1);
    x0 = memalloc(strlen(p0) + 1);
    strcpy(x0, p0);
    return x0;
};

(% streq(char *s0, char *s1) %);
streq: (p0, p1) {
    while (rch(p0, 0) != '\0') {
        if (rch(p0, 0) != rch(p1, 0)) { return FALSE; };
        p0 = p0 + 1;
        p1 = p1 + 1;
    };
    if (rch(p0, 0) == rch(p1, 0)) {
        return TRUE;
    } else {
        return FALSE;
    }
};

(% memset(void *ptr, int val, int size) %);
memset: (p0,p1,p2) {
    allocate(1);
    x0 = 0;
    while (x0 < p2) {
        wch(p0, x0, p1);
        x0 = x0 + 1;
    }
};

(% memcpy(void *dest, void *src, int size) %);
memcpy: (p0,p1,p2) {
    allocate(1);
    x0 = 0;
    while (x0 < p2) {
        wch(p0, x0, rch(p1, x0));
        x0 = x0 + 1;
    }
};

fork: () {
    allocate(1);
    x0 = syscall(SYS_FORK);
    if (x0 < 0) { panic("fork failed"); };
    return x0;
};

waitpid: (p0, p1, p2) {
    allocate(1);
    x0 = syscall(SYS_WAITPID, p0, p1, p2);
    if (x0 < 0) { panic("waitpid failed"); };
};

unlink: (p0) {
    allocate(1);
    x0 = syscall(SYS_UNLINK, p0);
    if (x0 == -2) { (% ENOENT %);
	return;
    };
    if (x0 < 0) { panic("unlink failed"); };
};

execve: (p0, p1, p2) {
    syscall(SYS_EXECVE, p0, p1, p2);
    panic("execve failed");
};
