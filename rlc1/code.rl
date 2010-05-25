(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: code.rl 2010-05-25 21:29:50 nineties $
 %);

NODE_CONS   => 0;
NODE_SYMBOL => 1;
NODE_INT    => 2;
NODE_CHAR   => 3;
NODE_STRING => 4;
NODE_PRIM   => 5; (% (code,ptr)  %);
NODE_ARRAY  => 6; (% (code,len,buf) %);
NODE_LAMBDA => 7; (% (code,params,body) %);
NODE_MACRO  => 8; (% (code,params,body) %);
