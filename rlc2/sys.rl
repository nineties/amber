(%
 % rowl - generation 2
 % Copyright (C) 2010 nineties
 %
 % $Id: sys.rl 2010-04-08 10:33:02 nineties $
 %)

(% system calls %)

SysExit    => 1;
SysFork    => 2;
SysRead    => 3;
SysWrite   => 4;
SysOpen    => 5;
SysClose   => 6;
SysWaitpid => 7;
SysUnlink  => 10;
SysExecve  => 11;
SysMmap2   => 192;
SysMunmap  => 91;

export
exit: (status @ int) {
    syscall(SysExit, status) @ void;
};

export
fork: () {
    pid : syscall(SysFork) @ int;
    if (pid >= 0) {
        return pid;
    };
    exit(-pid);
};
