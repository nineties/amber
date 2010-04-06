type test
    : A
    | B (int)
    | C (char, int)
    ;

export
main: () {
    x : B(2);
    syscall(1, A);
};


(%
t: (x:1,y:2,z:3);

f: () {
    return (x:1, y:(a:2, b:3));
};

export
main: () {
    t.z = 1;
    syscall(1, f().x + f().y.a + f().y.b + t.z); (% 1 + 2 + 3 + 1 %)
};
%)
