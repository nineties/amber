(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 % 
 % 
 % $Id: code.rl 2010-02-22 18:06:23 nineties $ 
 %);

(% types %);
NODE_VOID_T     => 0;
NODE_BOOL_T     => 1;
NODE_CHAR_T     => 2;
NODE_INT_T      => 3;
NODE_INT64_T    => 4;
NODE_FLOAT_T    => 5;
NODE_DOUBLE_T   => 6;
NODE_ARRAY_T    => 7;  (% element type %);
NODE_BLOCK_T     => 8;  (% element type %);
NODE_TUPLE_T    => 9;  (% length, element types  %);
NODE_FUNCTION_T => 10; (% param type, ret type %);
NODE_TYVAR      => 11; (% type-variable id %);

NODE_PROG       => 0; (% item list %);
NODE_INTEGER    => 1; (% type, value %);
NODE_STRING     => 2; (% type, string, is-comment %);
NODE_IDENTIFIER => 3; (% type, name, id, tyscheme %);
NODE_ARRAY      => 4; (% type, length, elements %);
NODE_BLOCK      => 5; (% type, elements %);
NODE_TUPLE      => 6; (% type, length, elements %);
NODE_REWRITE    => 7; (% left, right %);
NODE_EVAL       => 8; (% expression %);
NODE_DECL       => 9; (% type, identifier, expression %);
NODE_PAT        => 10; (% symbol, length, pat-elems %);
NODE_ASM        => 11; (% code %);

