import sys;

MaxExitCallback => 256;
exit_callbacks: static_array(0, MaxExitCallback);
num_exit_callback: 0;

export
exit: (status) {
    sys_exit(status);
};

export
at_exit: (fn @ ()->()) {
    exit_callbacks[num_exit_callback] = cast(int, fn);
    num_exit_callback++;
};
