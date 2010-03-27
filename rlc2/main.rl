export
main: () {
    x      : (1,(2,3));
    (_, y) : x;
    (z, _) : y;
    syscall(1, z);
}
