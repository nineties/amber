f: (x,y) {
    return x;
};

export
main: () {
    syscall(1, f(100, 200));
};
