import alloc;

make_counter: (n) {
    return () {
        return ++n;
    };
};

export
main: () {
    counter : make_counter(2);
    x : counter();
    x = counter();
    syscall(1, x) @ void;
};
