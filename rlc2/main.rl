import io;
import stdlib;

f: () { return 0; };
f: (x!int) { return x; };

export
main: () {
    sys_exit(f());
};
