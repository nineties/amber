import stdlib;

make_counter: (n) {
    return () {
        return n++;
    };
};

export
main: () {
    counter : make_counter(1);
    counter();
    counter();
    counter();
    exit(counter());
};
