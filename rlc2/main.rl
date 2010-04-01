plus: (x, y) { return x + y; };

export
main: () {
    y : plus(1, 2);
    syscall(1, y);
};
