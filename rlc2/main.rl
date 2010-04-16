import io;
import stdlib;

type test: Hoge (x:int, int);

export
main: () {
    x : new Hoge (2, 1);
    sys_exit(x->x);
};
