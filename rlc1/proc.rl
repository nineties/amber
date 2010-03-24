(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: proc.rl 2010-03-25 02:47:02 nineties $
 %);

include(stddef, code);
export(num_physical_regs, get_physical_reg, init_proc);

NUM_PHYSICAL_REGS => 4; (% eax, ebx, ecx, edx %);

locations: NULL;
location_id: 0;

new_location_id: () {
    location_id = location_id + 1;
    return location_id-1;
};

num_physical_regs: () {
    return NUM_PHYSICAL_REGS;
};

get_physical_reg: (p0) {
    if (p0 >= NUM_PHYSICAL_REGS) {
	fputs(stderr, "ERROR: physical register (index=");
	fputi(stderr, p0);
	fputs(stderr, ") does not exist\n");
	exit(1);
    };
    return vec_at(locations, p0);
};

create_pseudo_reg: () {
    allocate(1);
    x0 = mktup2(OPD_PSEUDO, new_location_id());
    vec_pushback(locations, x0);
    return x0;
};

init_proc: () {
    locations = mkvec(0);
    vec_pushback(locations, mktup3(OPD_REGISTER, new_location_id(), 0));
    vec_pushback(locations, mktup3(OPD_REGISTER, new_location_id(), 1));
    vec_pushback(locations, mktup3(OPD_REGISTER, new_location_id(), 2));
    vec_pushback(locations, mktup3(OPD_REGISTER, new_location_id(), 3));
};
