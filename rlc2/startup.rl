(%
 % rowl - generation 2
 % Copyright (C) 2010 nineties
 %
 % $Id: startup.rl 2010-05-06 13:26:45 nineties $
 %)

import sys;
import main;

external __init__main! () -> ();

export
__start: () {
    __init__main();
    sys_exit(main());
};
