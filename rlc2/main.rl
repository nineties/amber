t: (x:1,y:2,z:3);


f: () {
    return (x:1, y:(a:2, b:3));
};

export
main: () {
    p:f();
    p.x = 2;
    t.z = 1;
    syscall(1, p.x + p.y.a + p.y.b + t.z);
};
