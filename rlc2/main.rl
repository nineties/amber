import stdlib;

fib: (n) {
    if (n) {
	return n * fib(n-1);
    };
    return 1;
};

export
main: () {
    exit(fib(30));
};
