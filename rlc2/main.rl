import stdlib;

export
main: () {
    y : new_array 100 'a';
    y[0] = 'h';
    a: y[0];
    y[1] = a;
    exit(ExitSuccess);
};
