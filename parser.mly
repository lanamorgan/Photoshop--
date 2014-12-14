%{ open Ast %}

%token SEMICOLON LBRACE RBRACE LPAREN RPAREN EQ LTHAN GTHAN 
%token NOT TIMES NEQ LEQ GEQ AT BLOCK BLUE DOWN INT NOELSE EOF
%token ELSE FALSE GREEN IF LEFT LOOP MAIN MOVE PUT ELLIPSE COMMA
%token RED RIGHT RUN TRUE UP WHILE ASSIGN BOOL RECT DRAWLOOP DOT
%token X Y WIDTH HEIGHT
%token <string> ID 
%token <int> LITERAL 

%nonassoc NOELSE
%nonassoc ELSE
%nonassoc COMMA
%right ASSIGN
%left EQ NEQ
%left LTHAN GTHAN LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE
%left MOVE 


%start program
%type <Ast.program> program

%%


program:
                {[], []}        
     | program vdecl { ($2 :: fst $1), snd $1 }
     | program fdecl { fst $1, ($2 :: snd $1) }

fdecl:
    BLOCK ID LBRACE stmt_list RBRACE
        {
          {    
            fname = $2;
            body = List.rev $4;
          }
        }
color:
        RED {(255, 0, 0)}
     |  GREEN { (0, 255, 0) }
     |  BLUE { (0, 0, 255 )}
     |  LPAREN LITERAL COMMA LITERAL COMMA LITERAL RPAREN { ($2, $4, $6) }

shape:
        RECT { Rect}
      | ELLIPSE { Ellipse}


vdecl:
   shape ID ASSIGN expr COMMA expr COMMA expr COMMA expr COMMA color
        { Shape(
            {
                stype = $1;
                sname = $2;
                x = $4;
                y = $6;
                w = $8;
                h = $10;
                scolor = $12;
            }
        )
        }

  
    | INT ID {Def(Int, $2, Literal(0) )}
    | BOOL ID {Def(Bool, $2, Literal(0) )}
    | INT ID ASSIGN expr           { Def(Int, $2, $4)}
    | BOOL ID ASSIGN boolval          { Def(Bool, $2, $4)}
 
 



stmt_list:
                        { [] }
    | stmt_list stmt    { $2 :: $1 }

stmt:
      expr SEMICOLON                        {Expr($1)}
    | LBRACE stmt_list RBRACE               { Block(List.rev $2) }
    | IF LPAREN expr RPAREN stmt %prec NOELSE     { If ($3, $5, Block([])) }
    | IF LPAREN expr RPAREN stmt ELSE stmt  { If($3, $5, $7) }
    | WHILE LPAREN expr RPAREN stmt         { While ($3, $5) }
    | RUN ID SEMICOLON                      { Run($2)}
    | DRAWLOOP LBRACE stmt_list RBRACE      { Draw(List.rev $3) }
    | PUT ID AT expr COMMA expr SEMICOLON         { Put($2, $4, $6) }
    | MOVE ID LEFT expr SEMICOLON           { Animator ($2, Left, $4) }
    | MOVE ID RIGHT expr SEMICOLON          { Animator ($2, Right, $4) }
    | MOVE ID UP expr SEMICOLON             { Animator ($2, Up, $4) }
    | MOVE ID DOWN expr SEMICOLON           { Animator ($2, Down, $4) }
    | vdecl SEMICOLON                       { Vdec($1)}
   

 
 boolval:
        TRUE {Literal(1)}
      | FALSE {Literal(0)}

expr:
   
      LITERAL                   { Literal($1) }
    | ID                        { Id($1) }
    | expr PLUS expr            { Binop($1, Add,   $3) }
    | expr MINUS expr           { Binop($1, Sub,   $3) }
    | expr TIMES expr           { Binop($1, Mult,  $3) }
    | expr DIVIDE expr          { Binop($1, Div,   $3) }
    | expr EQ expr              { Binop($1, Equals, $3) }
    | expr NEQ expr             { Binop($1, Neq,   $3) }
    | expr LTHAN expr           { Binop($1, Less,  $3) }
    | expr LEQ expr             { Binop($1, Leq,   $3) }
    | expr GTHAN expr           { Binop($1, Greater,  $3) }
    | expr GEQ expr             { Binop($1, Geq,   $3) }
    | ID ASSIGN expr            { Vassign($1, $3)}
    | ID ASSIGN expr COMMA expr COMMA color    { Sassign($1, $3, $5, $7)}
    | LPAREN expr RPAREN        { $2 } 
    | ID X              {Get($1, X)} 
    | ID Y              {Get ($1, Y)}
    | ID WIDTH          {Get ($1, Width)}
    | ID HEIGHT         {Get ($1, Height)}
    
