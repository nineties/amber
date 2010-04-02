identity: (x) { return x; };



export
main: () {
    x : identity(1);
    y : identity("Hello World");

    syscall(1, 0);
};
