plus: (a, b) { return a + b; };
f: () { return plus; };

export
main: () {
    g : f();

    syscall(1, g(1,2));
};
