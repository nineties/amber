# Copyright (C) 2010 nineties
#
# $Id: io.rl 2011-12-14 01:14:08 nineties $

module stdlib::io {

print(obj): print(stdout, obj)
print(\fullform, obj): print(stdout, \fullform, obj)

read_char(): read_char(stdin)
read_string(): read_string(stdin)
read_line(): read_line(stdin)
read_int(): read_int(stdin)

puts(io@OutputFileStream, obj): {
    print(io, obj)
    print(io, '\n')
}
puts(io@OutputFileStream, \fullform, obj): {
    print(io, \fullform, obj)
    print(io, '\n')
}
puts(obj): puts(stdout, obj)
puts(\fullform, obj): puts(stdout, \fullform, obj)

}
