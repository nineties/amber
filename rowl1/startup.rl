(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: startup.rl 2010-04-05 13:03:15 nineties $
 %);

export _start;

_start: (p0) {
    init_io();
    exit(main(*(&p0-4), &p0));    (% argc and argv %);
};
