(%
 % rowl - generation 2
 % Copyright (C) 2010 nineties
 %
 % $Id: stdlib.rl 2010-05-03 00:17:32 nineties $
 %)

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
