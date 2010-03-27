
export
main: () {
    x      : (1,(2,4));
    (p, q) : x;
    (r,s)  : q;
    syscall(1, s);
}
