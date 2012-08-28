---
layout: page
title: "Amber Application Example: N-Body Simulation"
date: 2012-08-28 13:00
comments: true
sharing: true
footer: true
lang: en
---

Koichi:
> Hi Douglas and Piet, I'm glad you're interested in my new computer
language, Amber.

Piet:
> Yes, I've heard you talking about it, and I very much like its power
and flexibility.  However, I am not sure whether such a very general
language can be used in an efficient way for practical problems.  So
I brought my colleague Douglas, who is interested in writing codes for
N-body simulations.

Douglas:
> It would be great to see some concrete scientific results, to see
how the advantages of Amber pay off in practice.

Koichi:
> Great!  I am in fact eager to explore some specific applications in
Amber early on, while I am developing the language.  This will help me
to see how the flexibility of Amber can best be presented to users
interested in developing applications.
> To start with, what is an "N-body simulation"?

Douglas:
> The solar system is a good illustration.  Think about modelling the
motion of the eight planets and the sun.  Represent each object by a
point mass, write down the equations of motion (using Newton's Law for
the gravitational attraction, and Newton's Law of motion), and then
integrate the equations with some numerical algorithm.

Koichi:
> I'm not sure exactly what that means, but let's get started, and I
will ask questions as we get along.

Piet:
> And meanwhile we will ask questions about Amber.

Douglas:
> In physics, an equation of motion is a recipe for how a physical
body moves through space, in time.  The mathematical form is a
differential equation.  In order to solve a differential equation, you
need an initial condition, to get started, and also a kind of final
condition, to know when to stop.

Koichi:
> I like to program in a top-down way.  That means that we write down
what we would like the computer to understand, before actually telling
the computer what to do.

Douglas:
> Can you show me what you would write down in this case.

Koichi:
> From what you have just told me, here is how I would write it in
Amber:

    Nbody_simulation {
        initial:  ...
        final:    ...
        equation: d y / d x = ....
    }

Douglas:
> What does that mean?

Koichi:
> This is my way of specifying that an N-body simulation is basically
the solution of a differential equation, given initial and final
conditions.

Douglas:
> What you wrote above, is that a form of pseudocode, or can Amber
directly understand that text, after you add values for the `...`?

Koichi:
> It is just a pseudocode and Amber can not understand that text.
However, we can extend Amber's capability so as to understand our new
language.  Amber supports you to use the most suitable language for
writing problems of your domain.

Piet:
> Ah, that is very nice.  Normally when we try to write a new piece
of code, we may first scribble a piece of pseudocode on a blackboard.
After that, we translate that into actual lines of code of the
computer language we use.  Are you now suggesting to do the exact
opposite?  Not changing the pseudocode into code, but extending the
language in such a way that it can actually run the pseudocode?

Koichi:
> Yes, that's the main idea.  The key here is the development of a
Domain Specific Language, or DSL for short.

Douglas:
> I sort of get it.  Do you have any other examples of DSLs?

Koichi:
> There are two categories of DSLs.  Originally, a DSL was typically
written from scratch, just like any other computer language, but
intended for a more limited range of applications, which allows the
introduction of specific operations for specialized purposes.
Examples would be [SQL](http://en.wikipedia.org/wiki/SQL) for
operating relational-database systems and
[Yacc](http://en.wikipedia.org/wiki/Yacc) for writing parsers.
> However, more recently we have begun to use higher level languages
to write DSLs directly in terms of those languages themselves.  An
example is [Ruby](http://www.ruby-lang.org/en/), that is used to write
the killer application [Ruby on Rails](http://rubyonrails.org/), which
integrates several DSLs for writing web-application systems easily.

Douglas:
> I've heard of SQL and Yacc, but I've never used them.  Do you know
of any DSLs that are scientific applications?  Perhaps Maple would be
an example, as well as Mathematica?

Koichi:
> Yes. There are many kind of DSLs in scientific applications: Formula
manipulation languages (e.g., Maple, Mathematica, Maxima), Numerical
computation languages (e.g., MATLAB, Scilab, Octable), Statistical
computing language (e.g., R) and Data viaualization languages (e.g.,
gnuplot, graphviz).

Piet:
> I understand that most DSLs are written from scratch, based on a
simpler language such as C for example.  Do I understand that Ruby
is high-level enough, or `meta' enough, to allow a DSL to be written
directly in Ruby, while retaining the Ruby syntax?

Koichi:
> Yes.  Examples are Rakefile and Ruby on Rails.  However, at present,
other modern popular languages don't have enough capabilities to
implement internal DSLs.  This is the state of things.

Piet:
> Really?  How about Python?  In may ways Python resembles Ruby, at
least for the average user.

Koichi:
> in fact, there are no famous "internal" DSLs written in Python,
because Python's syntax is rather poor in comparison to Ruby.
Actually, Ruby and LISP are the only ones which support writing
internal DSLs in powerfully ways -- and now amber is the new one.

Piet:
> That is very interesting.  I had not realized that.  And I'm excited
about seeing in practice how you will use a meta-level language like
Amber to write a DSL for us in Amber!
> What is the next step?  Will we
stop now what we are doing, as a top-down way of thinking?  And will
we now write our new DSL, bottom-up?

Koichi:
> No, the nice thing of writing a DSL in Amber is that we can continue
all the way in a top-down fashion.  The next step will be to give
Amber a framework in which it can understand the pseudocode.

Piet:
> Very nice!  Let's do it.

Koichi:
> Well, in order for Amber to understand the pseudocode, we first have
to define a syntax, in which the pseudocode lines will be valid
statements. It can be written like:

    statement ::= [multiline]
        "Nbody_simulation" "{"
            aligned(nbody_simulation_component)
        "}"
     
    nbody_simulation_component
        ::= "initial" ":" aligned(statement)
          | "final" ":" expr
          | "equation" ":" aligned(differential_equation)
    
    differential_equation  ::= "d" symbol "/" "d" symbol "=" expr

Piet:
> In what context do these lines appear?  Will this be part of Amber?
Or is it part of a new library?  It looks quite different from the
first piece of code that you wrote, which was much simpler.

Koichi:
> It will be part of our new library for N-body simulation.
The notation I use is based on
[Backus-Naur Form (BNF)](http://en.wikipedia.org/wiki/Backus-Naur_Form)
with several extensions, which is commonly-used notation for defining
syntaxes of languages.

Douglas:
> What is the status of the word `statement` here?

Koichi:
> The symbols at the left-hand side of the operator `::=` form a
category of the syntax
which Amber understands. Amber adds the right-hand side new syntaxes
into the left-hand side categories. Since Amber parses programs as
lines of statements, we have to begin with defining our new
statement.

Douglas:
> Please explain this particular statement definition.

Koichi:
> Our new statement begins with a string "Nbody_simulation", followed
by a number of elements (`nbody_simulation_component`) enclosed within
bracesk, which constitute the simulation.

> Amber's parser distinguish syntax elements based on "indentation-level"
and `aligned` and `[multiline]` are Amber's extension for defining
syntaxes related indentation. `aligned(...)` parses elements which
have same indentation-level and `[multiline]` tells the parser that
some elements of the syntax could be placed in same level. In this
case, the string "Nbody_simulation" and the closing brace "}" will
be.

> The definition of `nbody_simulation_component` consists of "initial
condition", "final condition" and "equation".  The initial condition
consists of a header string "initial", a delimiter ":" and several
statements, initialization of variables.  Definitions of final
condition and equation are similar.

Piet:
> It does not seem to be so difficult. So, can Amber understand our
pseudocode now?

Koichi:
> Only syntaxes. Because we haven't tell Amber the meaning of our program.
> Well, before going next step, let's see how Amber understand our
pseudocode with the current definitions using Amber's interactive
shell. Save the definitions above to a file named "nbody-lib.ab" and
launch Amber-shell from command-line:

    $ amber
    amber:1>

> Then, load the "nbody-lib.ab" like this:

    amber:1> include "nbody-lib.ab";
    => nil
    amber:2>

> Now, Amber has the capability of understanding our pseudocode. Input
a program like this:


    amber:2> Nbody_simulation {
    amber:2~     initial:
    amber:2~         x: Vector[0.0, 1.0, 0.0]
    amber:2~         v: Vector[1.0, 0.0, 0.0]
    amber:2~         t: 0.0
    amber:2~         dt: 0.01
    amber:2~     final:
    amber:2~         t >= 10.0
    amber:2~     equation:
    amber:2~         d x / d t = v
    amber:2~         d v / d t = -x/|x|^3
    amber:2~ };
    => ["Nbody_simulation", "{", [["initial", ":", [DefineVariable{x, Vector{0.0, 1.0, 0.0}},
    DefineVariable{v, Vector{1.0, 0.0, 0.0}}, DefineVariable{t, 0.0}, DefineVariable{dt, 0.01}]],
    ["final", ":", t >= 1.0.], ["equation", ":", [["d", x, "/", "d", t, "=", v], ["d", v, "/",
    "d", t, "=", -x/|x|^3]]]], "}"]

Koichi:
> You can see that Amber understands our language just as a sequence
of tokens.  Tokens like "{" or "d" are not necessary for Amber. So it is
better to re-form tokens.  Re-formation of tokens can be written like:

-----
(Following parts are under edit.)


statement ::= [multiline]
    "Nbody_simulation" "{"
        initial_condition
        final_condition
        equation
    "}"
    { `Nbody_simulation{!$2,!$3, !$4} }

initial_condition ::= "initial" ":" aligned(statement) { $2 }
final_condition   ::= "final" ":" expr { $2 }
equation ::= "equation" ":" aligned(differential_equation) { $2 }

differential_equation
    ::= "d" symbol "/" "d" symbol "=" expr
        { `DiffEqn{!$1, !$4, !$6} }

(Qs and As)



 The initial and final conditions consist of a corresponding header string (e.g., "initial" ":") and an expression. The symbol `Nbody_simulation' is just a unique name of the statement so that Amber can understand the statement. Next, We have to define the internal representation of the new syntaxes.

    statement ::= "Nbody_simulation" "{"
        initial_condition
        final_condition
        equation
        "}"
        { `Nbody_simulation{!$2, !$3, !$4} }
    
    initial_condition ::= "initial" ":" expr    { $2 }
    final_condition   ::= "final" ":" expr      { $2 }
    equation ::= "equation" ":" differential_equation   { $2 }
    
    differential_equation ::= "d" symbol "/" "d" symbol "=" expr
        { `DiffEqn{!$1, !$4, !$6} }

Douglas:
> I notice you've added an extra expression (in braces) to each piece of syntax. I'll ask you about that in a minute, but what is the analogous concept for the syntax `1 + 2` which you mentioned previously?

Koichi:
> For example `1 + 2` and `add(1, 2)` have different syntaxes but their internal representation can be same, like `Add{1, 2}`.

Douglas:
> So, is `Nbody_simulation{...}` the internal representation of my problem?.

Koichi:
> Correct.

Douglas:
> OK. Now can you please explain what `` ` `` `!` and `$` mean?

Koichi:
> `$n` represents "nth-element of the syntax". For example, when amber parses `d y / d x = ...` using the syntax definition,

    differential_equation ::= "d" symbol "/" "d" symbol "=" expr

> `$0` will be a string `"d"`, `$1` will be a symbol `y`, `$2` will be a string `"/"` and so on.

> `` ` `` and `!` represent operations called quasi-quotation and unquotation. `` `( some expression )`` means "do not evaluate this expression" and `!( some expression )` means "evaluate only this expression". For example, when you write `` `(1 + !(2 + 3)) `` amber evaluates it to `Add{1, 5}`

Koichi:
> Finally, we have to define the meanings attached to these internal representations, like this:

    NbodySim{ini, fin, eqation} => `compile("C") {
        !ini
        while (not !fin) {
            !eqation
        }
    }
     
    DiffEqn{y, x, fun} => `{
        !y += !fun * !("d" + x)
    }

Koichi:
> These definitions mean that the patterns on the left hand side of `=>`, like `NbodySim{init, fin, equation}`, will be translated into the corresponding programs on the right. `compile("C") { ... }`, from standard library of Amber, translates the program into a C-program.

Douglas:
> How does Amber execute `ini`?

Koichi:
> It doesn't: Amber does not execute the actual simulation.  It just generates the code for the simulation. 

Douglas:
> So, what form does `ini` take?

Koichi:
> It would be easier to explain with a specific N-body problem.  Can you suggest one?

---------------

Douglas:
> How about the Kepler problem.  This is the motion of a test particle under an inverse square attractive force.  In the x,y plane (z = 0) you could, for example, start with initial position (1,0,0), initial velocity (0,1,0), and then the body will move in a circle about the origin (if G times the mass of the central body is 1)
> So what does this Kepler problem look like if we implement it in amber?  

Koichi:
> Simple:

    include "nbody-lib.ab"
    Nbody_simulation {
        initial: v: Vector[0.0, 1.0, 0.0], x: Vector[1.0, 0.0, 0.0]
        final:   t >= 1.0
        equation:
            d x / d t = v
            d v / d t = - x/|x|^3
    }

Douglas:
> I assume that amber has `Vector` as a built-in type, or in some standard mathematical library?

Koichi:
> It's in a library

Douglas:
> How about `|x|` and `|x|^3`?

Koichi:
> It's also in a library. `|x|` is the absolute value of the `x`, that is the euclidean norm of the vector `x` in this case. And `|x|^3` is the cube of `|x|`. 

---------------

Douglas:
> That didn't seem too hard.  But remember I am really interested in the general gravitational N-body problem

Koichi:
> Shall we implement it now?

    include "nbody-lib.ab"
    Nbody_simulation {
        initial:  v: Vector(....) * N : Vector(...) * N
        final:    t >= 1.0
        equation: {
            d x[i] / d t = v[i] (forall i in 0 .. N-1)
            d v[i] / d t = ...  (forall i in 0 .. N-1)
        }
    }
