mod: (x,y) {
    return x%y;
};

export
main: () {
    syscall(1, mod(5, 3));
};
