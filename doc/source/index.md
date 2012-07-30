---
layout: page
title: The Programming Language Amber
date: 2012-06-12 11:09
comments: true
sharing: true
footer: true
lang: en
---

What is Amber?
--------------
Amber is a open source scripting language, which is being developed for easy realization of **High-Level Programming with Self-Extension**.
The term "self-extension" means a way to extend languages' syntaxes or semantics using capabilities of themselves, and it includes following techniques:

* Macros
* Domain Specific Languages (DSLs)
* Extensible Syntax
* Meta-Programming
* Dynamic and Static Reflection

Writing programs with high-level abstraction is very important in terms of productivity, portability and performance. Since the optimal programming language is different according to programming targets in general, capabilities of self-extension are also important.
Amber has been designed and developed placing the highest priority to self-extension from the start, so self-extension of Amber is easy and has high-degree of freedom.

* [Why I am developing Amber](blog/motivation.html)
* [Features](feature.html)

Running Amber
-------------

* [Installation](tutorial/install.html)
* [Tutorials](tutorial)
* [Demos](tutorial/demo.html)

Studying Amber
--------------
* [Amber Core](implementation/amber-core.html)
* [Implementation](implementation)
* [References](reference)

Development Status
------------------
The release version of Amber is currently under development.
It will be a self-hosting compiler completely from the layer of assembers.
Current Amber only has capabilities for developing the release version, and it does not support following things:

* multi-precision integer arithmetic
* floating-point arithmetic
* multi-byte characters
* foreign function support
