import stdlib;

make_counter: (n) {
    return () {
        return n++;
    }
};

export
main: () {
    counter : make_counter(1);
    x : counter() + counter() + counter();
    sys_exit(x); (% -> 6 %)
};
