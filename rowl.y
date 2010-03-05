/* BNF of growl */

%token Symbol Command Identifier Integer Character Real String
%token Tdarrow
%token Taddasgn Tsubasgn Tmulasgn Tdivasgn Tmodasgn Torasgn Txorasgn Tandasgn Tlshiftasgn Trshiftasgn
%token Teq Tne Tle Tge
%token Tlshift Trshift
%token Tarrow

%nonassoc Tdarrow
%right ':'
%right '=' Taddasgn Tsubasgn Tmulasgn Tdivasgn Tmodasgn Torasgn Txorasgn Tandasgn Tlshiftasgn Trshiftasgn
%nonassoc prec_pattern
%left Operator
%left Tseqor
%left Tseqand
%left '|'
%left '^'
%left '&'
%nonassoc Teq Tne
%nonassoc '<' '>' Tle Tge
%left Tlshift Trshift
%left '+' '-'
%left '*' '/' '%'
%right prec_unary prec_preop
%left '.' Tarrow prec_postop


%%

Program
    :
    | ExternalItemList
    | ExternalItemList ';'
    ;

ExternalItemList
    : ExternalItem
    | ExternalItemList ';' ExternalItem
    ;

ExternalItem
    : Item
    ;

Tuple
    : '(' TupleItemsOpt ')'
    ;

TupleItemsOpt
    :
    | TupleItems
    ;

TupleItems
    : Item
    | TupleItems ',' Item
    ;

Array
    : '[' ArrayItemsOpt ']'
    ;

ArrayItemsOpt
    :
    | ArrayItems
    ;

ArrayItems
    : Item
    | ArrayItems ',' Item
    ;

List
    : '{' '}'
    | '{' ListItems '}'
    | '{' ListItems ';' '}'
    ;

ListItems
    : Item
    | ListItems ';' Item
    ;

Item
    : TertiaryItem
    | Item ':' Item
    | Item Tdarrow Item
    | Item '=' Item
    | Item Taddasgn Item
    | Item Tsubasgn Item
    | Item Tmulasgn Item
    | Item Tdivasgn Item
    | Item Tmodasgn Item
    | Item Torasgn Item
    | Item Txorasgn Item
    | Item Tandasgn Item
    | Item Tlshiftasgn Item
    | Item Trshiftasgn Item
    | Item '+' Item
    | Item '-' Item
    | Item '*' Item
    | Item '/' Item
    | Item '%' Item
    | Item Tlshift Item
    | Item Trshift Item
    | Item '<' Item
    | Item '>' Item
    | Item Tle Item
    | Item Tge Item
    | Item Teq Item
    | Item Tne Item
    | Item '&' Item
    | Item '^' Item
    | Item '|' Item
    | Item Tseqand Item
    | Item Tseqor Item
    | Item '.' Item
    | Item Tarrow Item
    | Item Operator Item
    | '+' Item %prec prec_unary
    | '-' Item %prec prec_unary
    | '~' Item %prec prec_unary
    | '!' Item %prec prec_unary
    | '&' Item %prec prec_unary
    | '*' Item %prec prec_unary
    ;

PatternItemsOpt
    :
    | PatternItems
    ;

PatternItems
    : PatternItem
    | PatternItems PatternItem
    ;

PatternItem
    : Symbol
    | Command
    | Identifier
    | Constant
    | Array
    | List
    | Tuple
    ;

TertiaryItem
    : SecondaryItem
    | Symbol PatternItemsOpt
    ;

SecondaryItem
    : PrimaryItem
    | SecondaryItem Array
    | SecondaryItem List
    | SecondaryItem Tuple
    ;

PrimaryItem
    : Identifier
    | Constant
    | Array
    | List
    | Tuple
    ;

Constant
    : Integer
    | Character
    | Real
    | String
    ;

%%
