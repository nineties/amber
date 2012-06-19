---
layout: page
title: Amberの特徴
date: 2012-06-13 22:15
comments: true
sharing: true
footer: true
lang: ja
---

Amberはその自己拡張を強力にサポートする以下の特徴を持っています．
実際，Amber自身もシンプルなコア言語(Amber Core)からの拡張により実現されています．

スクリプト言語
--------------
Amberはスクリプト言語です．事前のコンパイルは要らず手軽に実行できます．
また，動的言語でもあるので簡潔に柔軟にプログラムを書くことができます．

(静的型付けのコンパイラ言語の方が望ましい場面もありますので，その為の標準ライブラリを用意する予定です．例えば，Amberの次期仮想マシンはこのライブラリを用いて実装されます．)

プログラム=データ
-----------------
Amberではプログラム自体を通常のデータと同じくシームレスに扱う事が可能です．

    amber:1> 1 + 2             # normal expression
    => 3
    amber:2> \(1 + 2)          # (quotation) return given expression without evaluation
    => Add{1, 2}
    amber:3> `(1 + !(2 + 3))   # (quasi-quotation, unquotation) evaluate unquoted expressions only
    => Add{1, 5}
    amber:4> eval( \(1 + 2) )  # evaluate given data as a program
    => 3

詳しくは[リファレンス/クォーテーション](reference/quotation.html)へ．

(上の例では出力がAdd{1, 2}のように内部形式となっていますが，次期バージョンでは修正される予定です．)

第一級関数
----------
Amberの関数は第一級オブジェクトです．変数への代入や関数の引数として渡すなどの操作が通常のデータと同様にできます．

    amber:1> map(x -> x + 1, [1,2,3,4]) # x -> x + 1 is an anonymous function
    => [2, 3, 4, 5]

Amberは以下の機能を備えており，関数を部品として柔軟に扱う事ができます．

* 無名関数
* 部分関数
* クロージャ
* 関数の垂直・水平合成

詳しくは[リファレンス/関数](reference/function.html)へ．

パターンマッチング
------------------
Amberでは以下のように，パターンマッチを用いる関数定義を行う事ができます．

    fib(n) : fib(n-1) + fib(n-2)
    fib(0) : 0
    fib(1) : 1
    puts(fib(20))   # => 6765

(Amberでは後に書かれた定義の方が優先されます．)

もっと複雑なパターンを利用したり, ガード節の利用も可能です．
詳しくは[リファレンス/パターンマッチング](reference/pattern-matching.html)へ．


### 動的パターンマッチ機構
Amberのパターンマッチ機構の特徴は，動的に更新が可能であるという点です．
実は，上で書いた`fib`は1つの関数を指しているのではなく，3つの関数の水平合成を指しています．そして以下の様に新たな定義を動的に追加合成するという事が可能です．

    fib(n) : fib(n-1) + fib(n-2)
    fib(0) : 0
    fib(1) : 1
    puts(fib(20))       # => 6765

    {
        fib(0) : 1      # composite new definition only in this block
        puts(fib(20))   # => 10946
    }

下図の様なイメージです．

{% img ../images/fib.png 500 "Dynamic pattern-matching mechanism" %}

(マッチする関数が存在しない場合はエラーとなります．リリース版では例外となる予定です．
Amberでは手軽に使える事を優先していますのでこの様な仕様になっていますが，パターンの網羅性検査を追加するライブラリを作成する事は可能です．)

部分関数
--------
Amberの動的パターンマッチ機構は部分関数とその水平合成によって実現されています．
部分関数とは一部の値のみを引数として受け取る事が出来る関数のことで，Amberでは
パターンマッチを用いた関数が自動的に部分関数となります．

複数の部分関数は水平合成して１つの関数として扱うことができます．
関数`f`と`g`を`f | g`の様に水平合成演算子で繋げると，`f`,`g`の順にパターンマッチングし最初に成功した関数を実行する関数が作れます．

    amber:1> map(x@Int -> "Int" | x@String -> "String", [1,2,"three"]
    => ["Int", "Int", "String"]

このメカニズムによって，既存の関数を手軽に拡張して使えるのがAmberの特徴です．

    amber:1> map(to_s, [1,2,"three"])
    => ["1", "2", "three"]
    amber:2> map(x@String -> "String:"+to_s(x) | to_s, [1,2,"three"])   # extend to_s() for strings
    => ["1", "2", "String:three"]

詳しくは[リファレンス/関数](reference/function.html)へ．

拡張可能パーサ
--------------
Amberのパーサは拡張可能であり，既存の構文を置き換えたり新しい構文を追加したりする事ができます．以下の様な特徴があります．

* Parsing Expression Grammer (PEG)
* Packrat Parsing
* Scannerless Parsing
* 左再帰のサポート

PEGは多くのプログラミング言語で用いられているLL系文法やLR系文法と同等もしくはそれ以上の表現力を持っており，大体どのような言語でも定義出来ると考えて良いでしょう．
以下の例ではC言語風のコメント構文を定義しています．

    amber:1> comment [spacesensitive] ::= "//" [^\n]*   # C-style single line comment
    => nil
    amber:2> puts("hoge") // Now, you can use the new comment syntax
    hoge
    => nil

詳しくは[リファレンス/パーサ](reference/parser.html)へ．

マクロ
------
式の実行前にマクロを呼び出す事もできます．マクロ定義はデフォルトでは`パターン => 式`という様に書きます．
左辺のパターンにマッチした式は右辺の実行結果に置き換えられます．

    amber:1> x + y => `((!x + !y) % 10)     # definition of a macro
    => nil
    amber:2> 5 + 6
    => 1

詳しくは[リファレンス/マクロ](reference/macro.html)へ．
