(%
 % rowl - generation 2
 % Copyright (C) 2010 nineties
 %
 % $Id: main.rl 2010-05-06 13:53:32 nineties $
 %)

f: () { return 1; };
f: (x!int) { return x; };

export
main: () {
    x : f ();
    y : f (1);
    return 0;
};
