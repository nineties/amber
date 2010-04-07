export
exit: (status!int) {
    syscall(1, status) ! void;
};
