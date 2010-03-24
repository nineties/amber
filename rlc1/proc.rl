(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: proc.rl 2010-03-25 00:48:31 nineties $
 %);

include(stddef, code);
export(physical_regs, num_physical_regs, init_proc);

NUM_PHYSICAL_REGS => 4; (% eax, ebx, ecx, edx %);
physical_regs: int [NUM_PHYSICAL_REGS];
locations: NULL;

location_id: 0;
new_location_id: () {
    location_id = location_id + 1;
    return location_id-1;
};

num_physical_regs: () {
    return NUM_PHYSICAL_REGS;
};

create_pseudo_reg: () {
    allocate(1);
    x0 = mktup2(LOC_UNKNOWN, new_location_id());
    vec_pushback(locations, x0);
    return x0;
};

init_proc: () {
    locations = mkvec(0);

    physical_regs[0] = mktup3(LOC_REGISTER, new_location_id(), 0);
    physical_regs[1] = mktup3(LOC_REGISTER, new_location_id(), 1);
    physical_regs[2] = mktup3(LOC_REGISTER, new_location_id(), 2);
    physical_regs[3] = mktup3(LOC_REGISTER, new_location_id(), 3);
    vec_pushback(locations, physical_regs[0]);
    vec_pushback(locations, physical_regs[1]);
    vec_pushback(locations, physical_regs[2]);
    vec_pushback(locations, physical_regs[3]);
};
