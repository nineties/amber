import stdlib;

mkcls: () {
    return (a, b) {
        return a + b;
    };
};

export
main: () {
    exit(mkcls()(1,2));
};
