f: () { return (1, (2, 3)) };

export
main: () {
    x : f();
    (a, (b, c)) : x;
    syscall(1, c);
}
