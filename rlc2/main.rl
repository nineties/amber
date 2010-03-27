export
main: () {
    x      : (1,(2,4));
    (_, q) : x;
    (_, s) : q;
    syscall(1, s);
}
