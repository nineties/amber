plus: (x,y) {
    return x+y;
};

export
main: () {
    syscall(1, plus(1, 2));
};
