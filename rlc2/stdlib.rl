import sys;
import alloc;

MaxExitCallback => 256;
exit_callbacks: static_array(0, MaxExitCallback);
num_exit_callback: 0;

export type exit_status
    : ExitSuccess
    | ExitFailure
    ;

export
exit: (status ! exit_status) {
    sys_exit(cast(int) status);
};

export
atexit: (callback ! ()->()) {
    if (num_exit_callback >= MaxExitCallback) {
        exit(ExitFailure);
    };
    exit_callbacks[num_exit_callback] = cast(int) callback;
    num_exit_callback++;
};
