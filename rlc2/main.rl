import alloc;

make_counter: (n) {
    return () {
        return n++;
    };
};

export
main: () {
    counter : make_counter(1);
    x : counter();
    syscall(1, x) @ void;
};
