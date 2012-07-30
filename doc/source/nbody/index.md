---
layout: page
title: "Amber Application Example: N-Body Simulation"
date: 2012-07-28 08:56
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
> Is this analogous to a function or subroutine which takes some
arguments and produces some result?

Koichi:
> No, we have to create libraries so that Amber can understand it. For example, if you type `1 + 2` in amber, there is a little library in Amber which understand the syntax and meaning of `1` and `2` and `+`. So, I first have to define the syntax of this statement in the library. The notation I use is called BNF, and you can read about it at [Backus-Naur Form](http://en.wikipedia.org/wiki/Backus-Naur_Form). The library for this application will contain lines of the following form:

    statement ::= "Nbody_simulation" "{"
        initial_condition
        final_condition
        equation
        "}"
    
    initial_condition ::= "initial" ":" expr
    final_condition   ::= "final" ":" expr
    equation ::= "equation" ":" differential_equation
    
    differential_equation ::= "d" symbol "/" "d" symbol "=" expr

Douglas:
> What is the status of the word `statement' here?

koichi:
> It is a category of the syntax which amber understands. Every Amber programs consist of lines of statements.

Douglas:
> Please explain this particular statement definition.

koichi:
> Our new statement begins with a string "Nbody_simulation", followed by three elements enclosed within braces: "initial condition", "final condition" and "equation". The initial and final conditions consist of a corresponding header string (e.g., "initial" ":") and an expression. The symbol `Nbody_simulation' is just a unique name of the statement so that Amber can understand the statement. Next, We have to define the internal representation of the new syntaxes.

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
> I notice you've added an extra expression (in braces) to each piece of syntax. I'll ask you about that in a minute, but what is the analogous concept for the syntax `1 + 2' which you mentioned previousl?

koichi:
> For example `1 + 2` and `add(1, 2)` have different syntaxes but their internal representation can be same, like `Add{1, 2}`.

Douglas:
> So, is `Nbody_simulation{...}` the internal representation of my problem?.

koichi:
> Correct.

Douglas:
> OK. Now can you please explain what `` ` `` `!` and `$` mean?

koichi:
> (WE NEED EXPLANATION)

koichi:
> Finally, we have to define the meanings attached to these internal representations, like this:

    NbodySim{ini, fin, eqation} => `to_C_program{
        !ini
        while (not !fin) {
            !eqation
        }
    }
     
    DiffEqn{y, x, fun} => `{
        !y += !fun * !("d" + x)
    }

koichi:
> These definitions mean that the patterns on the left hand side of `=>`, like `NbodySim{init, fin, equation}`, will be translated into the corresponding programs on the right. `to_C_program`, from standard library of Amber, translates the program into a C-program.

(WE ALSO NEED EXPLANATION OF QUOTATION AND UNQUOTATION HERE)

Douglas:
> How does Amber execute `ini`?

koichi:
> It doesn't: Amber does not execute the actual simulation.  It just generates the code for the simulation. 

Douglas:
> So, what form does `ini` take?

koichi:
> It would be easier to explain with a specific N-body problem.  Can you suggest one?

---------------

Douglas:
> How about the Kepler problem.  This is the motion of a test particle under an inverse square attractive force.  In the x,y plane (z = 0) you could, for example, start with initial position (1,0,0), initial velocity (0,1,0), and then the body will move in a circle about the origin (if G times the mass of the central body is 1)
> So what does this Kepler problem look like if we implement it in amber?  

Koichi:
> Simple:

    include "nbody-lib.ab"
    Nbody_simulation {
        initial: v: Vector(0.0, 1.0, 0.0), x: Vector(1.0, 0.0, 0.0)
        final:   t >= 1.0
        equation: {
            d x / d t = v
            d v / d t = - x/|x|^3
        }
    }

Douglas:
> I assume that amber has `Vector` as a built-in type, or in some standard mathematical library?

koichi:
> It's in a library

Douglas:
> How about `|x|` and `|x|^3`?

(NEEDS TO BE COMPLETED)

---------------

Douglas:
> That didn't seem too hard.  But remember I am really interested in the general gravitational N-body problem

koichi:
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
