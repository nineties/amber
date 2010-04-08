import stdlib;

fib: (n) {
    if (n > 0) {
	return n * fib(n-1);
    };
    return 1;
};

export
main: () {
    exit(fib(3));
};
