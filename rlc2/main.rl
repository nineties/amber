f: () {
    return (x:1, y:2);
};

export
main: () {
    p : f();
    syscall(1, p.x + p.y);
};
