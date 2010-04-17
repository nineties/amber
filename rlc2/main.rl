import io;
import stdlib;

type test: Hoge (x:int, int);

export
main: () {
    x : new_array(13) '\0';
    x[0]  = 'H';
    x[1]  = 'e';
    x[2]  = 'l';
    x[3]  = 'l';
    x[4]  = 'o';
    x[5]  = ' ';
    x[6]  = 'W';
    x[7]  = 'o';
    x[8]  = 'r';
    x[9]  = 'l';
    x[10] = 'd';
    x[11] = '\n';
    x[12] = '\0';
    sys_write(1, x, 12);
    sys_exit(0);
};
