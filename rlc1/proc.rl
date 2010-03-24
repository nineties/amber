(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: proc.rl 2010-03-24 23:00:41 nineties $
 %);

export(physical_regs, num_physical_regs, init_physical_regs);

NUM_PHYSICAL_REGS => 4; (% eax, ebx, ecx, edx %);
physical_regs: int [NUM_PHYSICAL_REGS];
register_id: NUM_PHYSICAL_REGS;

num_physical_regs: () {
    return NUM_PHYSICAL_REGS;
};

init_physical_regs: () {
    physical_regs[0] = mktup3("%eax", 0, 0);
    physical_regs[1] = mktup3("%ebx", 1, 1);
    physical_regs[2] = mktup3("%ecx", 2, 2);
    physical_regs[3] = mktup3("%edx", 3, 3);
};
