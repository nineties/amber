(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % $Id: alloc.rl 2010-06-02 09:04:57 nineties $
 %);

include(stddef);

export(memalloc, finalize_mem);

SYS_MMAP2  => 192;
SYS_MUNMAP => 91;
PROT_READ  => 1;
PROT_WRITE => 2;
PROT_EXEC  => 4;
PROT_SEM   => 8;
PROT_NONE  => 0;

MAP_SHARED    => 1;
MAP_PRIVATE   => 2;
MAP_TYPE      => 15;
MAP_FIXED     => 16; (% 0x10 %);
MAP_ANONYMOUS => 32; (% 0x20 %);

BLOCK_SIZE => 1048576;  (% 1Mbyte %);
BLOCK_MASK => 1048575;  (% BLOCK_SIZE - 1 %);
MAX_BLOCKS => 4096;     (% 4096 is enough for 32-bit machine %);

block_used : int [MAX_BLOCKS];
next_addr : 0;
num_bytes: 0;
num_block : 0;
free_first : 0;
free_last  : 0;

(% mmap2(void *addr, int size) %);
mmap2: (p0, p1) {
    allocate(1);
    x0 = syscall(SYS_MMAP2, p0, p1, PROT_READ|PROT_WRITE|PROT_EXEC,
        MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
    if (-128 <= x0) {
        if (x0 < 0) {
            panic("mmap2 failed");
        }
    };
    return x0;
};

(% munmap(void *addr, int size) %);
munmap: (p0, p1) {
    return syscall(SYS_MUNMAP, p0, p1);
};


(% alloc_block(size) %);
alloc_block: (p0) {
    allocate (2); (% x0: address of new block %);
    p0 = p0 + BLOCK_SIZE;
    x0 = mmap2(0, p0);
    x1 = x0 & BLOCK_MASK;
    if (munmap(x0, BLOCK_SIZE - x1) < 0) {
        panic("munmap failed");
    };
    if (x1 > 0) {
        if (munmap(x0 + p0 - x1, x1) < 0) {
            panic("munmap failed");
        }
    };
    x0 = x0 + BLOCK_SIZE - x1;
    num_block = num_block + 1;
    return x0;
};

alloc_block_fast: () {
    allocate(1); (% x0: address of new block %);
    if (num_block + 1 > MAX_BLOCKS) { panic("too many blocks"); };
    if (next_addr == 0) {
        x0 = alloc_block(BLOCK_SIZE);
    } else {
        x0 = mmap2(next_addr, BLOCK_SIZE);
        if (x0 & BLOCK_MASK != 0) {
            if (munmap(x0, BLOCK_SIZE) < 0) {
                panic("munmap failed");
            };
            x0 = alloc_block(BLOCK_SIZE);
        }
    };
    next_addr = x0 + BLOCK_SIZE;
    block_used[x0/BLOCK_SIZE] = TRUE;
    free_first = x0;
    free_last  = next_addr;
};

(% memalloc(n): allocate heap memory of n byte %);
memalloc: (p0) {
    allocate(1); (% return addr %);
    if (p0 == 0) { return NULL; };
    if (free_first + p0 >= free_last) {
        alloc_block_fast();
    };
    x0 = free_first;
    free_first = free_first + p0;
    num_bytes = num_bytes + p0;
    return x0;
};

(% munmap all blocks %);
finalize_mem: () {
    allocate(1);

    fputs(stderr, "[DEBUG] total memory : ");
    fputi(stderr, num_bytes);
    fputs(stderr, "bytes (");
    fputi(stderr, num_block);
    fputs(stderr, " blocks)\n");

    x0 = 0;
    while (x0 < MAX_BLOCKS) {
        if (block_used[x0]) {
            munmap(x0*BLOCK_SIZE, BLOCK_SIZE);
        };
        x0 = x0 + 1;
    };
};
