f: () {
    return (x:1, y:(a:2, b:3));
};

export
main: () {
    p:f();
    p.x = 2;
    syscall(1, p.x + p.y.a + p.y.b);
};
