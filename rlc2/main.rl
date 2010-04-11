import stdlib;

fact: (n) {
    if (n <= 0) {
        return 1;
    } else {
        return n*fact(n-1);
    }
};


export
main: () {
    sys_exit(fact(3)); (% -> 6 %)
};
