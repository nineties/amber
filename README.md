The Programming Language Amber 
==============================

Amber is an open source scripting language, which is being developed for easy
realization of **High-Level Programming with Self-Extension**.  The term
"self-extension" means a way to extend languages' syntaxes or semantics using
capabilities of themselves, and it includes following techniques:

* Macros
* Domain Specific Languages (DSLs)
* Extensible Syntax
* Symbolic-Programming and Eval
* Dynamic and Static Reflection

Writing programs with high-level abstraction is very important in terms of
productivity, portability and performance. Since the optimal programming
language is different according to programming targets in general, capabilities
of self-extension are also important.  Amber has been designed and developed
placing the highest priority to self-extension from the start, so
self-extension of Amber is easy and has high-degree of freedom.

Installation
------------

Amber can be compiled only in Linux environment now.

    % git clone https://github.com/nineties/amber.git
    % cd amber
    % make
    % make install

Alternatively, if you would like to install it to a local prefix:

* Set `PREFIX` in config.mk to the desired location
* `export PATH=$PREFIX/usr/bin:$PREFIX/amber/usr/lib/amber/bin:$PATH`
* `export LD_LIBRARY_PATH=$PREFIX/usr/lib/`

License
-------
Amber is published under the MIT License. See COPYING for the details of this
license.

Information
-----------
* [Project Page](http://nineties.github.com/amber/)
* [GitHub](http://github.com/nineties/amber)
* [Creating a language using only assembly language](https://speakerdeck.com/nineties/creating-a-language-using-only-assembly-language)

Contact
-------
* Developer: Koichi Nakamura
* E-mail: koichi.nakamur at gmail.com
* Twitter: [@9_ties](http://twitter.com/9_ties)
