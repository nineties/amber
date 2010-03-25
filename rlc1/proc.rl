(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: proc.rl 2010-03-25 18:50:08 nineties $
 %);

include(stddef, code);
export(num_physical_regs, get_physical_reg, init_proc);
export(get_eax, get_ebx, get_ecx, get_edx, get_esi, get_edi, get_ebp, get_esp);

NUM_PHYSICAL_REGS => 8; (% eax, ebx, ecx, edx, esi, edi, ebp, esp %);
REG_EAX => 0;
REG_EBX => 1;
REG_ECX => 2;
REG_EDX => 3;
REG_ESI => 4;
REG_EDI => 5;
REG_EBP => 6;
REG_ESP => 7;

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

get_eax: () { return get_physical_reg(REG_EAX); };
get_ebx: () { return get_physical_reg(REG_EBX); };
get_ecx: () { return get_physical_reg(REG_ECX); };
get_edx: () { return get_physical_reg(REG_EDX); };
get_esi: () { return get_physical_reg(REG_ESI); };
get_edi: () { return get_physical_reg(REG_EDI); };
get_ebp: () { return get_physical_reg(REG_EBP); };
get_esp: () { return get_physical_reg(REG_ESP); };

create_pseudo_reg: () {
    allocate(1);
    x0 = mktup2(OPD_PSEUDO, new_location_id());
    vec_pushback(locations, x0);
    return x0;
};

init_proc: () {
    allocate(1);
    locations = mkvec(NUM_PHYSICAL_REGS);
    x0 = 0;
    while (x0 < NUM_PHYSICAL_REGS) {
        vec_put(locations, x0, mktup3(OPD_REGISTER, new_location_id(), x0));
        x0 = x0 + 1;
    };
};
