import stdlib;

make_counter: (n) {
    f : () {
        return n++;
    };
    return f;
};

export
main: () {
    counter : make_counter(1);
    counter();
    counter();
    counter();
    sys_exit(counter());
};
