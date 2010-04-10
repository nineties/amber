import stdlib;

make_counter: (n) {
    return () {
        return n++;
    }
};

export
fact: (n) {
    if (n <= 0) {
        return 1;
    } else {
        return n*fact(n-1);
    }
};

export
main: () {
    counter: make_counter(1);
    x: counter() + counter() + counter();
    sys_exit(x); (% -> 6 %)
};
