import stdlib;

make_counter: (n) {
    f : () {
        return n++;
    };
    return f;
};

export
main: () {
    exit(ExitSuccess);
};
