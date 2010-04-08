import stdlib;
import alloc;

make_counter: (n) {
    f : () {
        return n++;
    };
    return f;
};

export
main: () {
    x : new 0;
    *x = 1;
    exit(ExitSuccess);
};
