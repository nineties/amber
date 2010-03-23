(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: rewrite.rl 2010-03-24 03:31:43 nineties $
 %);

include(stddef);

scopeid: 0;
scopeid_stack: NULL;
rwmap: NULL; (% rewrite rules %);

strhash: (p0) {
    allocate(1);
    x0 = 0;
    while (rch(p0, 0) != '\0') {
        x0 = x0 * 7 + rch(p0, 0);
        p0 = p0 + 1;
    };
    return x0;
};

(% p0: (scopeid-id, name) %);
rwmap_hash: (p0) {
    return strhash(p0[1]) * 3+ p0[0];
};

rwmap_keyequal: (p0, p1) {
    if (p0[0] != p1[0]) { return FALSE; };
    return streq(p0[1], p1[1]);
};

rwmap_push: () {
    scopeid = scopeid + 1;
    vec_pushback(scopeid_stack, scopeid);
};

rwmap_pop: () {
    vec_popback(scopeid_stack);
};

(% p0: name, p1: value %);
rwmap_add: (p0, p1) {
    map_add(rwmap, mktup2(scopeid, p0), p1);
};

(% p0: name %);
rwmap_find: (p0) {
    allocate(3);
    x0 = vec_size(scopeid_stack)-1;
    while (x0 >= 0) {
        x1 = vec_at(scopeid_stack, x0); (% scopeid-id %);
        x2 = map_find(rwmap, mktup2(x1, p0));
        if (x2 != NULL) { return x2; };
        x0 = x0 - 1;
    };
    return NULL;
};

init_rewrite: () {
    rwmap = mkmap(&rwmap_hash, &rwmap_keyequal, 100);
    scopeid_stack = mkvec(0);
    rwmap_push();
};

export(init_rewrite);
export(register_rewriterule);
export(rewrite);

(% p0: symbol-name, p1: argument types, p2: item %);
register_rewrite_item: (p0, p1, p2) {
    rwmap_add(p0, mktup3(p1, FALSE, p2));
};

(% p0: symbol-name, p1: argument type, p2: function %);
register_rewrite_function: (p0, p1, p2) {
    rwmap_add(p0, mktup3(p1, TRUE, p2));
};

(% p0: left, p1: right %);
register_rewriterule: (p0, p1) {
    register_rewrite_item(p0[1], NULL, p1);
};

(% p0: pattern %);
rewrite: (p0) {
    allocate(1);
    x0 = rwmap_find(p0[1]);
    if (x0 == NULL) {
        return p0;
    };
    if (x0[1]) {
        fputs(stderr, "not implemented\n");
        exit(1);
    } else {
        (% it is not a rewrite function %);
        return x0[2];
    };
};
