x: (1, 2);

plus: (a, b) { return a + b; };
f: () { return plus; };

export
main: () {
    g : f();
    (a, b) : x;

    syscall(1, g(a,b));
};
