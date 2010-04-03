identity: (a) { return a; };

export
main: () {
    x : identity(1);
    y : identity("Hello World");

    syscall(1, 0);
};
