(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: startup.rl 2010-02-22 18:06:35 nineties $ 
 %);

export _start;

_start: (p0) {
    init_io();
    main(*(&p0-4), &p0);    (% argc and argv %);
};
