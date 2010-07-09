(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: rowllib.rl 2010-07-10 00:30:59 nineties $
 %);

include(stddef);

(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                  tuple object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%);

export (mktup1, mktup2, mktup3, mktup4, mktup5, mktup6, mktup7);

alloc_tuple: (p0) {
    return memalloc(4*p0);
};

mktup1: (p0) {
    allocate(1);
    x0 = alloc_tuple(1);
    x0[0] = p0;
    return x0;
};

mktup2: (p0, p1) {
    allocate(1);
    x0 = alloc_tuple(2);
    x0[0] = p0;
    x0[1] = p1;
    return x0;
};

mktup3: (p0, p1, p2) {
    allocate(1);
    x0 = alloc_tuple(3);
    x0[0] = p0;
    x0[1] = p1;
    x0[2] = p2;
    return x0;
};

mktup4: (p0, p1, p2, p3) {
    allocate(1);
    x0 = alloc_tuple(4);
    x0[0] = p0;
    x0[1] = p1;
    x0[2] = p2;
    x0[3] = p3;
    return x0;
};

mktup5: (p0, p1, p2, p3, p4) {
    allocate(1);
    x0 = alloc_tuple(5);
    x0[0] = p0;
    x0[1] = p1;
    x0[2] = p2;
    x0[3] = p3;
    x0[4] = p4;
    return x0;
};

mktup6: (p0, p1, p2, p3, p4, p5) {
    allocate(1);
    x0 = alloc_tuple(6);
    x0[0] = p0;
    x0[1] = p1;
    x0[2] = p2;
    x0[3] = p3;
    x0[4] = p4;
    x0[5] = p5;
    return x0;
};

mktup7: (p0, p1, p2, p3, p4, p5, p6) {
    allocate(1);
    x0 = alloc_tuple(7);
    x0[0] = p0;
    x0[1] = p1;
    x0[2] = p2;
    x0[3] = p3;
    x0[4] = p4;
    x0[5] = p5;
    x0[6] = p6;
    return x0;
};

(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                  vector object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%);

export(mkvec);
export(vec_ptr, vec_size, vec_at, vec_back, vec_put);
export(vec_resize, vec_pushback, vec_popback);

VEC_SIZE => 0;
VEC_CAPA => 1;
VEC_BUF  => 2;

(% vector = (size, capa, buf) %);

(% p0: size, p1: capa %);
mkvec_with_capa: (p0, p1) {
    allocate(1);
    x0 = memalloc(4*p1); (% allocate buffer %);
    memset(x0, 0, 4*p1);
    return mktup3(p0, p1, x0);
};


(% p0: number of elements %);
mkvec: (p0) {
    if (p0 != 0) {
        return mkvec_with_capa(p0, p0);
    } else {
        return mkvec_with_capa(p0, 10);
    }
};

vec_ptr: (p0)  { return p0[VEC_BUF]; };
vec_size: (p0) { return p0[VEC_SIZE]; };

(% p0: vector, p1:index %);
vec_at: (p0, p1) {
    allocate(1);
    if (p1 < 0) {
        *0 = 1;
    };
    if (p1 >= p0[VEC_SIZE]) {
        *0 = 1;
    };
    x0 = p0[VEC_BUF];
    return x0[p1];
};

vec_back: (p0) {
    return vec_at(p0, vec_size(p0)-1);
};

(% p0: vector, p1:index, p2:value %);
vec_put: (p0, p1, p2) {
    allocate(1);
    x0 = p0[VEC_BUF];
    x0[p1] = p2;
};

(% p0: vector, p1: capa %);
vec_reserve: (p0, p1) {
    allocate(1);
    if (p0[VEC_CAPA] < p1) {
        x0 = memalloc(4*p1); (% new buffer %);
        memset(x0, 0, 4*p1);
        memcpy(x0, p0[VEC_BUF], 4*p0[VEC_SIZE]);
        p0[VEC_BUF] = x0;
        p0[VEC_CAPA] = p1;
    };
};

(% p0: vector, p1: new size %);
vec_resize: (p0, p1) {
    if (p1 > p0[VEC_SIZE]) {
        vec_reserve(p0, p1);
    };
    p0[VEC_SIZE] = p1;
};

(% p0: vector, p1: value %);
vec_pushback: (p0, p1) {
    if (p0[VEC_SIZE] == p0[VEC_CAPA]) {
        vec_reserve(p0, p0[VEC_CAPA] * 2);
    };
    p0[VEC_SIZE] = p0[VEC_SIZE] + 1;
    vec_put(p0, p0[VEC_SIZE]-1, p1);
};

(% p0: vector %);
vec_popback: (p0, p1) {
    p0[VEC_SIZE] = p0[VEC_SIZE] - 1;
};

(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            character vector object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%);

export(mkcvec);
export(cvec_ptr, cvec_size, cvec_at, cvec_put);
export(cvec_resize, cvec_pushback);

VEC_SIZE => 0;
VEC_CAPA => 1;
VEC_BUF  => 2;

(% cvector = (size, capa, buf) %);

(% p0: size, p1: capa %);
mkcvec_with_capa: (p0, p1) {
    allocate(1);
    x0 = memalloc(p1); (% allocate buffer %);
    memset(x0, 0, p1);
    return mktup3(p0, p1, x0);
};


(% p0: number of elements %);
mkcvec: (p0) {
    if (p0 != 0) {
        return mkcvec_with_capa(p0, p0);
    } else {
        return mkcvec_with_capa(p0, 10);
    }
};

cvec_ptr: (p0)  { return p0[VEC_BUF]; };
cvec_size: (p0) { return p0[VEC_SIZE]; };

(% p0: cvector, p1:index %);
cvec_at: (p0, p1) {
    allocate(1);
    x0 = p0[VEC_BUF];
    return rch(x0, p1);
};

(% p0: cvector, p1:index, p2:value %);
cvec_put: (p0, p1, p2) {
    allocate(1);
    x0 = p0[VEC_BUF];
    wch(x0, p1, p2);
};

(% p0: cvector, p1: capa %);
cvec_reserve: (p0, p1) {
    allocate(1);
    if (p0[VEC_CAPA] < p1) {
        x0 = memalloc(p1); (% new buffer %);
        memset(x0, 0, p1);
        memcpy(x0, p0[VEC_BUF], p0[VEC_SIZE]);
        p0[VEC_BUF] = x0;
        p0[VEC_CAPA] = p1;
    };
};

(% p0: cvector, p1: new size %);
cvec_resize: (p0, p1) {
    if (p1 > p0[VEC_CAPA]) {
        cvec_reserve(p0, p1);
    };
    p0[VEC_SIZE] = p1;
};

(% p0: cvector, p1: value %);
cvec_pushback: (p0, p1) {
    if (p0[VEC_SIZE] == p0[VEC_CAPA]) {
        cvec_reserve(p0, p0[VEC_CAPA] * 2);
    };
    cvec_put(p0, p0[VEC_SIZE], p1);
    p0[VEC_SIZE] = p0[VEC_SIZE] + 1;
};

(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                  list object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%);

export(ls_cons, ls_singleton, ls_append, ls_value, ls_set, ls_next, ls_length, ls_reverse,
    ls_copy, ls_at);

(% list = (value, next) %);
LS_VALUE => 0;
LS_NEXT  => 1;

(% p0: value, p1: list %);
ls_cons: (p0, p1) {
    return mktup2(p0, p1);
};

ls_singleton: (p0) {
    return ls_cons(p0, NULL);
};

(% p0, p1: list %);
ls_append: (p0, p1) {
    if (p0 == NULL) { return p1; };
    return ls_cons(ls_value(p0), ls_append(ls_next(p0), p1));
};

(% p0: list %);
ls_value: (p0) {
    return p0[LS_VALUE];
};

(% p0: list %);
ls_set: (p0, p1) {
    p0[LS_VALUE] = p1;
};

(% p0: list %);
ls_next: (p0) {
    return p0[LS_NEXT];
};

(% p0: list %);
ls_length: (p0) {
    allocate(1);
    x0 = 0;
    while (p0 != NULL) {
        p0 = ls_next(p0);
        x0 = x0 + 1;
    };
    return x0;
};

(% p0: list %);
ls_reverse: (p0) {
    allocate(2);
    x0 = NULL;
    x1 = NULL;
    while (p0 != NULL) {
        x0 = ls_next(p0);
        p0[LS_NEXT] = x1;
        x1 = p0;
        p0 = x0;
    };
    return x1;
};

(% p0: list %);
ls_copy: (p0) {
    if (p0 == NULL) { return NULL; };
    return ls_cons(ls_value(p0), ls_copy(ls_next(p0)));
};

(% p0: list, p1: index %);
ls_at: (p0, p1) {
    if (p1 == 0) { return ls_value(p0); };
    assert(p0 != NULL);
    return ls_at(ls_next(p0), p1-1);
};

(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                hashtable object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%);

export(mkht, ht_add, ht_del, ht_find);

(% hashtable = (hashfunc, equalfunc, keyfunc, size, buckets) %);
HT_HASH   => 0;
HT_KEYEQ  => 1;
HT_GETKEY => 2;
HT_SIZE   => 3;
HT_BUCKET => 4;

prime_numbers : [
      53,         97,         193,       389,       769,
      1543,       3079,       6151,      12289,     24593,
      49157,      98317,      196613,    393241,    786433,
      1572869,    3145739,    6291469,   12582917,  25165843,
      50331653,   100663319,  201326611, 402653189, 805306457,
      1610612741, 3221225473, 4294967291
      ];

NUM_PRIME => 28;

(% returns first prime number greater than p0 %);
next_prime: (p0) {
    allocate(1);
    x0 = 0;
    while (x0 < NUM_PRIME) {
        if (prime_numbers[x0] >= p0) {
            return prime_numbers[x0];
        };
        x0 = x0 + 1;
    };
    return prime_numbers[NUM_PRIME-1];
};

(% p0: hash func, p1: key, p2: bucket_size %);
calc_index: (p0, p1, p2) {
    return p0(p1) % p2 
};

(% p0: hashtable, p1: new size %);
resize_bucket: (p0, p1) {
    allocate(5);
    x0 = vec_size(p0[HT_BUCKET]); (% old size %);
    if (p1 > x0) {
        p1 = next_prime(p1);
        x1 = mkvec(p1); (% new bucket %);
        x2 = 0;
        while (x2 < x0) {
            x3 = vec_at(p0[HT_BUCKET], x2); (% x3 : list of entries %);
            while (x3 != NULL) {
                x4 = calc_index(p0[HT_HASH], p0[HT_GETKEY](ls_value(x3)),
                    p1);
                vec_put(x1, x4,
                    ls_cons(ls_value(x3), vec_at(x1, x4)));
                x3 = ls_next(x3);
            };
            x2 = x2 + 1;
        };
        p0[HT_BUCKET] = x1;
    }
};

(% p0: hash func, p1: keyequal func, p2: getkey func, p3: size hint %);
mkht: (p0, p1, p2, p3) {
    return mktup5(p0, p1, p2, 0, mkvec(next_prime(p3)));
};

(% p0: hashtable, p1: entry %);
ht_add: (p0, p1) {
    allocate(1);
    resize_bucket(p0, p0[HT_SIZE]+1);
    x0 = calc_index(p0[HT_HASH], p0[HT_GETKEY](p1), vec_size(p0[HT_BUCKET]));
    vec_put(p0[HT_BUCKET], x0, ls_cons(p1, vec_at(p0[HT_BUCKET], x0)));
    p0[HT_SIZE] = p0[HT_SIZE]+1;
};

(% p0: hashtable, p1: key %);
ht_del: (p0, p1) {
    allocate(3);
    x0 = calc_index(p0[HT_HASH], p1, vec_size(p0[HT_BUCKET]));
    x1 = NULL;
    x2 = vec_at(p0[HT_BUCKET], x0);
    while (x2 != NULL) {
        if (p0[HT_KEYEQ](p0[HT_GETKEY](ls_value(x2)), p1)) {
            p0[HT_SIZE] = p0[HT_SIZE] - 1;
            if (x1 != NULL) {
                x1[LS_NEXT] = ls_next(ls_next(x1));
                x1 = x2;
                x2 = ls_next(x1);
            } else {
                vec_put(p0[HT_BUCKET], x0, ls_next(x2));
                x2 = ls_next(x2);
            }
        } else {
            x1 = x2;
            x2 = ls_next(x2);
        }
    }
};

(% p0: hashtable, p1: key %);
ht_find: (p0, p1) {
    allocate(2);
    x0 = calc_index(p0[HT_HASH], p1, vec_size(p0[HT_BUCKET]));
    x1 = vec_at(p0[HT_BUCKET], x0);
    while (x1 != NULL) {
        if (p0[HT_KEYEQ](p0[HT_GETKEY](ls_value(x1)), p1)) {
            return ls_value(x1);
        };
        x1 = ls_next(x1);
    };
    return NULL;
};

export(identity, simple_hash, simple_equal);

identity: (p0) {
    return p0;
};

simple_hash: (p0) {
    return p0;
};

simple_equal: (p0, p1) {
    return p0 == p1;
};

(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                 hashset object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%);

export(mkset, set_add, set_del, set_contains);

(% p0: hash func, p1: keyequal func, p2: size hint %);
mkset: (p0, p1, p2) {
    return mkht(p0, p1, &identity, p2);
};

(% p0: set, p1: value %);
set_add: (p0, p1) {
    ht_add(p0, p1);
};

(% p0: set, p1: value %);
set_del: (p0, p1) {
    ht_del(p0, p1);
};

(% p0: set, p1: value %);
set_contains: (p0, p1) {
    return ht_find(p0, p1) != NULL;
};

(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                 hashmap object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%);

export(mkmap, map_add, map_del, map_find);

first: (p0) {
    return p0[0];
};

(% p0: hash func, p1: keyequal, p2: size hint %);
mkmap: (p0, p1, p2) {
    return mkht(p0, p1, &first, p2);
};

(% p0: map, p1: key, p2: value %);
map_add: (p0, p1, p2) {
    ht_add(p0, mktup2(p1, p2));
};

(% p0: map, p1: key %);
map_del: (p0, p1) {
    ht_del(p0, p1);
};

(% p0: map, p1: key %);
map_find: (p0, p1) {
    allocate(1);
    x0 = ht_find(p0, p1);
    if (x0 == NULL) { return NULL; };
    return x0[1];
};

(%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                               integer-set object
                           sorted-list implementation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%);

export(mkiset, iset_size, iset_singleton, iset_copy, iset_add, iset_del, iset_contains,
    iset_union, iset_intersection, iset_subtract, iset_eq);
mkiset: () { return NULL; };
iset_size: (p0) { return ls_length(p0); };
iset_singleton: (p0) { return ls_cons(p0, NULL); };

iset_copy: (p0) { return ls_copy(p0); };

(% p0: set, p1: value %);
iset_add: (p0, p1) {
    if (p0 == NULL) { return ls_cons(p1, NULL); };
    if (ls_value(p0) == p1) { return p0; };
    if (ls_value(p0) < p1) {
        p0[LS_NEXT] = iset_add(ls_next(p0), p1);
        return p0;
    };
    return ls_cons(p1, p0);
};

(% p0: set, p1: value %);
iset_del: (p0, p1) {
    if (p0 == NULL) { return p0; };
    if (ls_value(p0) == p1) { return ls_next(p0); };
    p0[LS_NEXT] = iset_del(ls_next(p0), p1);
    return p0;
};

(% p0: set, p1: value %);
iset_contains: (p0, p1) {
    while (p0 != NULL) {
        if (ls_value(p0) == p1) { return TRUE; };
        p0 = ls_next(p0);
    };
    return FALSE;
};

x:0;
(% p0,p1: set %);
iset_union: (p0, p1) {
    if (p0 == NULL) { return ls_copy(p1); };
    if (p1 == NULL) { return ls_copy(p0); };
    if (ls_value(p0) == ls_value(p1)) {
        return ls_cons(ls_value(p0), iset_union(ls_next(p0), ls_next(p1)));
    };
    if (ls_value(p0) < ls_value(p1)) {
        return ls_cons(ls_value(p0), iset_union(ls_next(p0), p1));
    } else {
        return ls_cons(ls_value(p1), iset_union(p0, ls_next(p1)));
    }
};

(% p0,p1: set %);
iset_intersection: (p0, p1) {
    if (p0 == NULL) { return NULL; };
    if (p1 == NULL) { return NULL; };
    if (ls_value(p0) == ls_value(p1)) {
        return ls_cons(ls_value(p0), iset_intersection(ls_next(p0), ls_next(p1)));
    };
    if (ls_value(p0) < ls_value(p1)) {
        return iset_intersection(ls_next(p0), p1);
    } else {
        return iset_intersection(p0, ls_next(p1));
    };
};

(% p0,p1: set (p0-p1)  %);
iset_subtract: (p0, p1) {
    if (p0 == NULL) { return NULL; };
    if (p1 == NULL) { return ls_copy(p0); };
    if (ls_value(p0) == ls_value(p1)) {
        return iset_subtract(ls_next(p0), ls_next(p1));
    };
    if (ls_value(p0) > ls_value(p1)) {
        return iset_subtract(p0, ls_next(p1));
    } else {
        return ls_cons(ls_value(p0), iset_subtract(ls_next(p0), p1));
    }
};

iset_eq: (p0, p1) {
    if (p0 == NULL) { return p1 == NULL; };
    if (p1 == NULL) { return FALSE; };
    if (ls_value(p0) == ls_value(p1)) {
        return iset_eq(ls_next(p0), ls_next(p1));
    };
    return FALSE;
};
