f: () {
    return;
};

export
main: () {
    f();
    syscall(1, 100);
};
