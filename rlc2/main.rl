import stdlib;

export
main: () {
    x : new (1, hoge:2);
    y : new_array 1 1;

    (% exit(ExitSuccess); %);
    sys_exit(x->hoge);
};
