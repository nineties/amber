return_tuple: () { return (1, 2) };

export
main: () {
    (a, b) : return_tuple();
    syscall(1, a + b);
}
