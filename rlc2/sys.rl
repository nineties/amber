(%
 % rowl - generation 2
 % Copyright (C) 2010 nineties
 %
 % $Id: sys.rl 2010-04-08 19:59:16 nineties $
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
sys_exit: (status @ int) {
    syscall(SysExit, status) @ void;
};

export
sys_fork: () {
    pid : syscall(SysFork) @ int;
    if (pid >= 0) {
        return pid;
    };
    sys_exit(-pid);
};

ProtRead  => 1;
ProtWrite => 2;
ProtExec  => 4;
ProtSem   => 8;
ProtNone  => 0;

MapShared    => 1;
MapPrivate   => 2;
MapType      => 15;
MapFixed     => 16;
MapAnonymous => 32;

export
sys_mmap2: (addr @ int, size @ int) {
    ret : syscall(SysMmap2, addr, size, ProtRead|ProtWrite|ProtExec,
        MapAnonymous|MapPrivate, -1, 0) @ int;
    if (ret >= 0) {
        return ret;
    };
    sys_exit(-ret);
};

export
sys_munmap: (addr @ int, size @ int) {
    syscall(SysMunmap, addr, size);
};
