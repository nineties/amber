exit: (status ! int) {
    syscall(1, status);
};

export
main: () {
    exit(0);
    (% exit("Hello"); type error %);
};
