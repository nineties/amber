(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: code.rl 2010-05-29 16:39:25 nineties $
 %);

NODE_CONS    => 0;
NODE_SYMBOL  => 1;
NODE_INT     => 2;
NODE_CHAR    => 3;
NODE_STRING  => 4;
NODE_PRIM    => 5;  (% (code,ptr)  %);
NODE_ARRAY   => 6;  (% (code,size,buf) %);
NODE_LAMBDA  => 7;  (% (code,params,body) %);
NODE_MACRO   => 8;  (% (code,params,body) %);
NODE_QUOTE   => 9;  (% (code,sexp) %);
NODE_UNQUOTE => 10; (% (code,sexp) %);
NODE_STRBUF  => 11; (% (code,size,buf) %);
