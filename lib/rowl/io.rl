# Copyright (C) 2010 nineties
#
# $Id: io.rl 2011-10-05 14:50:54 nineties $

print(obj): print(stdout, obj)
print(`fullform, obj): print(stdout, `fullform, obj)

read_char(): read_char(stdin)
read_string(): read_string(stdin)
read_line(): read_line(stdin)
read_int(): read_int(stdin)

puts(obj): {
    print(obj)
    print('\n')
}

puts(io, obj): {
    print(io, obj)
    print(io, '\n')
}

