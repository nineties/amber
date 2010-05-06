(%
 % rowl - generation 2
 % Copyright (C) 2010 nineties
 %
 % $Id: main.rl 2010-05-06 03:27:11 nineties $
 %)

import stdlib;

f: () { return 1; };
f: (x!int) { return x; };

export
main: () {
    x : f ();
    y : f (1);
    exit(ExitSuccess);
};
