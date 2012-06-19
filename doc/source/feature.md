---
layout: page
title: Features
date: 2012-06-14 00:42
comments: true
sharing: true
footer: true
lang: en
---

Amber has following characteristics which supports self-extension programming powerfully. In fact, Amber itself is implemented by self-extension from simple core language (Amber Core).

Scripting Language
------------------
Amber is a dynamic scripting language. You can write programs easily and flexibly, and can run programs instantly without compilation.

Note: I will develop a standard library for changing Amber into static typed language in case that such language is optimal. For example, the next version of Amber's virtual machine will be implemented using the library.


Program = Data
--------------
Amber can treat programs seamlessly as usual data.

    amber:1> 1 + 2             # normal expression
    => 3
    amber:2> \(1 + 2)          # (quotation) return given expression without evaluation
    => Add{1, 2}
    amber:3> `(1 + !(2 + 3))   # (quasi-quotation, unquotation) evaluate unquoted expressions only
    => Add{1, 5}
    amber:4> eval( \(1 + 2) )  # evaluate given data as a program
    => 3

See [Reference/Quotation](reference/quotation.html) for details.

Note: The format of outputs is the internal format of expressions. It will be prettified in the next release version.

First-Class Function
--------------------
Amber's functions are all first-class objects.
Therefore, you can use them in the same manner as usual data: assigning variables, passing to functions and so on.

    amber:1> map(x -> x + 1, [1,2,3,4]) # x -> x + 1 is an anonymous function
    => [2, 3, 4, 5]

Amber's following capabilities make functions powerful program components.

* Anonymous function
* Partial function
* Closure
* Vertical and Horizontal Composition

See [Reference/Function](reference/function.html) for details.

Pattern-Matching
----------------
Amber supports function definitions with pattern-matching as follows.

    fib(n) : fib(n-1) + fib(n-2)
    fib(0) : 0
    fib(1) : 1
    puts(fib(20))   # => 6765

Note: The latter definitions have higher priority in case of Amber.

You can use more complex patterns and guard clauses.
See [Reference/Pattern-Matching](reference/pattern-matching.html) for details.

### Dynamic Pattern-Matching Mechanism
The most characteristic point of Amber's pattern-matching engine is that it supports dynamic modification.
In fact, the example program of `fib` does not define one function but defines horizontal composition of three functions, and you can composite new function definition to it as follows. 

    fib(n) : fib(n-1) + fib(n-2)
    fib(0) : 0
    fib(1) : 1
    puts(fib(20))       # => 6765

    {
        fib(0) : 1      # composite new definition only in this block
        puts(fib(20))   # => 10946
    }

Following picture depicts this mechanism.

{% img images/fib.png 500 "Dynamic pattern-matching mechanism" %}

Note: When no definition matches with given arguments, Amber treats the case as an error. It will be an exception in the next version.
The reason is because Amber emphasizes its convenience over strictness.
It is possible to write a library so as to enable completeness check of patterns.

Partial Function
----------------
Amber's dynamic pattern-matching mechanism is realized by partial functions and their horizontal composition. A "Partial Function" is a function which receives limited range of arguments. Every function defined using pattern-matching will be a partial function.

Multiple functions can be composited horizontally.
By composing functions `f` and `g` using horizontal-composition operator like `f | g`, you can create a function which tries `f` and `g` in sequence.

    amber:1> map(x@Int -> "Int" | x@String -> "String", [1,2,"three"]
    => ["Int", "Int", "String"]

This mechanism enables us to extend existing functions easily. 

    amber:1> map(to_s, [1,2,"three"])
    => ["1", "2", "three"]
    amber:2> map(x@String -> "String:"+to_s(x) | to_s, [1,2,"three"])   # extend to_s() for strings
    => ["1", "2", "String:three"]

See [Reference/Function](reference/function.html) for details.

Extensible Parser
-----------------
You can replace existing syntaxes or define new syntaxes.
Amber's parser has following characteristics.

* Parsing Expression Grammer (PEG)
* Packrat Parsing
* Scannerless Parsing
* Support Left-Recursion

PEG is a simple and expressive syntax either equaling or surpassing LL syntaxes and LR syntaxes. So, you can be sure that almost any kind of languages can be implemented inside Amber.
Following simple example defines C-style single comment syntax.

    amber:1> comment [spacesensitive] ::= "//" [^\n]*   # C-style single line comment
    => nil
    amber:2> puts("hoge") // Now, you can use the new comment syntax
    hoge
    => nil

See [Reference/Parser](reference/parser.html) for details.

Macros
------
You can apply macros to expressions before executing them.
Definitions of macros can be written as `pattern => expression` in the default Amber's syntax. Expressions match with the `pattern` will be replaced with the results of `expression`.

    amber:1> x + y => `((!x + !y) % 10)     # definition of a macro
    => nil
    amber:2> 5 + 6
    => 1

See [Reference/Macros](reference/macros.html) for details.
