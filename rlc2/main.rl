f: () {
    return 100;
};

export
main: () {
    syscall(1, f());
};
