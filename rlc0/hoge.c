CODE
map(fun, ary) {
    return "for (int i = 0; i < length(ary); i++) ary[i] = fun(ary[i]);";
}

int plus(int x) {
    return x + 1;
}

int
main(int argc, char *argv[])
{
    int ary[] = {0,1,2,3,4,5};

    map(plus, ary);

    return 0;
}
