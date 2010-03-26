
f: (x) {
    return x++;
};

export
main: () {
    syscall(1, f(1));
};
