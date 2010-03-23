(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: startup.rl 2010-03-24 03:31:50 nineties $
 %);

export _start;

_start: (p0) {
    init_io();
    main(*(&p0-4), &p0);    (% argc and argv %);
};
