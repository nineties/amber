import stdlib;

make_counter: (n) {
    f : () {
        return n++;
    };
    return f;
};

export
main: () {
    x : new (1, hoge:2);
    (% exit(ExitSuccess); %);
    sys_exit(x->hoge);
};
