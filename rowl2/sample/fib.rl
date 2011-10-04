fib1(n): if (n < 3) 1 else fib1(n-1) + fib1(n-2)

fib2(n): fib2(n-1) + fib2(n-2)
fib2(1): 1
fib2(2): 1

puts(fib1(36))
puts(fib2(36))
