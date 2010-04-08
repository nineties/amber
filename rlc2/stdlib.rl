import sys;

MaxExitCallback => 256;
exit_callbacks: static_array(0, MaxExitCallback);
num_exit_callback: 0;

export type exit_status
    : ExitSuccess
    | ExitFailure
    ;

export
exit: (status @ exit_status) {
    sys_exit(cast(int, status));
};

export
at_exit: (fn @ ()->()) {
    if (num_exit_callback >= MaxExitCallback) {
        exit(ExitFailure);
    };
    exit_callbacks[num_exit_callback] = cast(int, fn);
    num_exit_callback++;
};
