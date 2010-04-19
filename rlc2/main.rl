import io;
import stdlib;

type test: Hoge (x:int, int);

export
main: () {
    x : open_out("test");
    fputc(x, 'H');
    fputc(x, 'e');
    fputc(x, 'l');
    fputc(x, 'l');
    fputc(x, 'o');
    fputc(x, ' ');
    fputc(x, 'W');
    fputc(x, 'o');
    fputc(x, 'r');
    fputc(x, 'l');
    fputc(x, 'd');
    fputc(x, '\n');
    close_out(x);
    sys_exit(0);
};
