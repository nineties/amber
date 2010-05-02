import io;
import stdlib;

f: () { return 1; };
f: (x!int) { return x; };

export
main: () {
    x : f ();
    y : f (1);
    exit(ExitSuccess);
};
