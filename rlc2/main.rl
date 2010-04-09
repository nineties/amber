import stdlib;

export
main: () {
    x : new (1, hoge:2);
    y : new_array 100 (1,2);

    y[10] = (1, 3);
    (a, b) : y[10];
    exit(ExitSuccess);
};
