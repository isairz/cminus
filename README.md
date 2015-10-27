# C-Minus
2015년 컴파일러 수업의 과제인 C-Minus 제작을 위한 프로젝트이다.
[Tiny Compiler](http://www.cs.sjsu.edu/faculty/louden/cmptext/) 를 수정하여 C 문법의 Subset인  C-Minus를 직접 제작하여 본다.

### Tested Environment
 - OS X Yosemite (10.10.3)
 - Ubuntu 14.04 LTS

### Requirment
 - GCC
 - FLEX
 - BISON

## Project 1 - Scanner
### Overview
스캐너 제작을 위해 키워드, 심볼을 정의하고 DFA를 이용해 주어진 소스파일의 문자열을 토큰 단위로 분석(Lexical Analysis)한다.

### How to use
```
$ make cminus
$ ./cminus test.cm
```
```
$ make cminus_flex
$ ./cminus_flex test.cm
```

### Definition
#### Keywords (lower case only)
 - else
 - if
 - int
 - return
 - void
 - while

#### Symbols
 - \+
 - \-
 - \*
 - /
 - <
 - <=
 - \>
 - \>=
 - ==
 - \!=
 - =
 - ;
 - ,
 - (
 - )
 - [
 - ]
 - {
 - }
 - /\* \*/

#### Tokens
 - 𝐼𝐷 = 𝑙𝑒𝑡𝑡𝑒𝑟 𝑙𝑒𝑡𝑡𝑒𝑟*
 - 𝑁𝑈𝑀 = 𝑑𝑖𝑔𝑖𝑡 𝑑𝑖𝑔𝑖𝑡 *
 - 𝑙𝑒𝑡𝑡𝑒𝑟 = a | ... | z | A | ... | Z
 - 𝑑𝑖𝑔𝑖𝑡 = 0 | 1 | ... | 9

### 과제 수행
먼저 스캐너만 제작하기 위해 **main.c** 의 FLAG들을 조정한다.
``` c
int EchoSource = TRUE;
int TraceScan = TRUE;
int TraceParse = FALSE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;
```

키워드와 심볼 등록을 위해 **global.h** 의 enum 값을 수정한다.
이 때 MAXRESERVED의 개수를 키워드 수와 반드시 같게 해 주어야 한다.
키워드의 처음과 끝에 KEYWORD_START, KEYWORD_END 라는 enum을 추가하여 관리 하면 실수를 방지 할 수 있을 것이다.
컴파일 오류 방지를 위해 tiny 에서 쓰던 enum을 남겨두고, fixme를 추가한다.
``` c
/* MAXRESERVED = the number of reserved words */
#define MAXRESERVED 6

typedef enum
    /* book-keeping tokens */
   {ENDFILE,ERROR,
    /* reserved words */
    ELSE,IF,INT,RETURN,VOID,WHILE,
    /* multicharacter tokens */
    ID,NUM,
    /* special symbols */
    PLUS,MINUS,TIMES,OVER,LT,LTEQ,GT,GTEQ,EQ,NEQ,ASSIGN,SEMI,COMMA,
    LPAREN,RPAREN,LBRACK,RBRACK,LBRACE,RBRACE,

    /* OLD symbols for compile */
    /* FIXME: Remove this symbols */
    THEN,END,UNTIL,REPEAT,READ,WRITE,
   } TokenType;
```

본격적인 DFA를 수행하기 위해 scan.c를 수정한다.
tiny에서 방식 그대로 하나씩 바뀌되, 2글자 짜리 연산자들을 조심스럽게 추가한다.

특히 /\* \*/ 를 추가할때 주의한다. 첫 slash가 나왔을때, \*가 나왔을때, 2번째 \*이 나왔을때의 state를 각각 나눠 처리한다.
``` c
case INSLASH:
  if (c == '*')
  { state = INCOMMENT;
    save = FALSE;
  }
  else
  { state = DONE;
    ungetNextChar();
    currentToken = OVER;
  }
  break;
case INCOMMENT:
  save = FALSE;
  if (c == EOF)
  { state = DONE;
    currentToken = ENDFILE;
  }
  else if (c == '*') state = INCOMMENTSTAR;
  break;
case INCOMMENTSTAR:
  save = FALSE;
  if (c == EOF)
  { state = DONE;
    currentToken = ENDFILE;
  }
  else if (c == '/') state = START;
  else state = INCOMMENT;
  break;
```
### Results
```c
TINY COMPILATION: test.cm
   1: /* A Program to perform Euclid`s
   2:    Algorithm to computer gcd */
   3:
   4: int gcd (int u, int v)
	4: reserved word: int
	4: ID, name= gcd
	4: (
	4: reserved word: int
	4: ID, name= u
	4: ,
	4: reserved word: int
	4: ID, name= v
	4: )
   5: {
	5: {
   6:     if (v == 0) return u;
	6: reserved word: if
	6: (
	6: ID, name= v
	6: ==
	6: NUM, val= 0
	6: )
	6: reserved word: return
	6: ID, name= u
	6: ;
   7:     else return gcd(v,u-u/v*v);
	7: reserved word: else
	7: reserved word: return
	7: ID, name= gcd
	7: (
	7: ID, name= v
	7: ,
	7: ID, name= u
	7: -
	7: ID, name= u
	7: /
	7: ID, name= v
	7: *
	7: ID, name= v
	7: )
	7: ;
   8:     /* u-u/v*v == u mod v */
   9: }
	9: }
  10:
  11: void main(void)
	11: reserved word: void
	11: ID, name= main
	11: (
	11: reserved word: void
	11: )
  12: {
	12: {
  13:     int x; int y;
	13: reserved word: int
	13: ID, name= x
	13: ;
	13: reserved word: int
	13: ID, name= y
	13: ;
  14:     x = input(); y = input();
	14: ID, name= x
	14: =
	14: ID, name= input
	14: (
	14: )
	14: ;
	14: ID, name= y
	14: =
	14: ID, name= input
	14: (
	14: )
	14: ;
  15:     output(gcd(x,y));
	15: ID, name= output
	15: (
	15: ID, name= gcd
	15: (
	15: ID, name= x
	15: ,
	15: ID, name= y
	15: )
	15: )
	15: ;
  16: }
	16: }
	17: EOF
```

### Using flex
```
$ make cminus_flex
$ ./cminus_flex test.cm
```

### Overview
[flex](http://flex.sourceforge.net/) 를 사용하여 C-Minus의 lexer를 자동으로 생성하고 사용한다.

### 과제수행
라이브러리의 종속성을 없애기 위해 noyywrap 를 사용하지 않도록 cminus.l에서 옵션을 추가한다.
```
%option noyywrap
```

Makefile 에 아래 항목을 추가한다. 라이브러리 종속성을 제거하였기 때문에 -l 옵션이 필요 없다.
```makefile
cminus_flex: main.o globals.h util.o lex.yy.o
        $(CC) $(CFLAGS) main.o util.o lex.yy.o -o cminus_flex

lex.yy.o: cminus.l scan.h util.h globals.h
        flex -o lex.yy.c cminus.l
        $(CC) $(CFLAGS) -c lex.yy.c
```

lex/tiny.l을 기반으로 cminus.l을 작성한다. 편리한 문법을 제공해 주어서 별다른 어려움 없이 cminus의 문법들을 구현 할 수 있다.

### Results
```c

TINY COMPILATION: test.cm
	4: reserved word: int
	4: ID, name= gcd
	4: (
	4: reserved word: int
	4: ID, name= u
	4: ,
	4: reserved word: int
	4: ID, name= v
	4: )
	5: {
	6: reserved word: if
	6: (
	6: ID, name= v
	6: ==
	6: NUM, val= 0
	6: )
	6: reserved word: return
	6: ID, name= u
	6: ;
	7: reserved word: else
	7: reserved word: return
	7: ID, name= gcd
	7: (
	7: ID, name= v
	7: ,
	7: ID, name= u
	7: -
	7: ID, name= u
	7: /
	7: ID, name= v
	7: *
	7: ID, name= v
	7: )
	7: ;
	9: }
	11: reserved word: void
	11: ID, name= main
	11: (
	11: reserved word: void
	11: )
	12: {
	13: reserved word: int
	13: ID, name= x
	13: ;
	13: reserved word: int
	13: ID, name= y
	13: ;
	14: ID, name= x
	14: =
	14: ID, name= input
	14: (
	14: )
	14: ;
	14: ID, name= y
	14: =
	14: ID, name= input
	14: (
	14: )
	14: ;
	15: ID, name= output
	15: (
	15: ID, name= gcd
	15: (
	15: ID, name= x
	15: ,
	15: ID, name= y
	15: )
	15: )
	15: ;
	16: }
	17: EOF
```
### Review
tiny의 소스가 미니멀하게 잘 짜져 있어서 과제는 별다른 어려움 없이 수행 할 수 있었다.
이번 과제의 아쉬운 점 이라면 기껏 새로운 컴파일러를 제작하는데 C의 Subset인 언어를 만든다는 점이다. 이 언어는 아무리 잘 만들어봐야 C의 하위 호환이고 별다른 쓸모가 없어 보인다. 차라리 DSL(Domain-Specific Language)를 하나 정의하여 직접 구현해 보거나 문법이 간단하면서도 First-Class Function을 지원하는 JavaScript를 직접 구현해보면 더 재밌고 보람찬 과제가 되지 않았을까 한다.


## Project 2 - Parser
### Overview
 - Flex를 이용하여 구현한 C-Minus Scanner를 이용
 - Yacc (bison)를 사용하여 얻은 소스 코드를 합하여 Parser를 구현한다.

### How to use
```
$ make cminus
$ ./cminus test.cm
```
```
$ make test
```

### BNF Grammer for C Minus

### 구현 과정
#### main.c
Parser 처리를 위해 상수들을 수정하였다.
bison을 사용 하기 위해 Global 변수들을 수정하였다.
```c
#define NO_PARSE FALSE
int EchoSource = TRUE;
int TraceScan = FALSE;
int TraceParse = TRUE;
```

	
#### globals.h
yacc/globals.h 파일을 복사하여 수정하였다. 토큰들의 정의를 받아오기 위해 bison에서 생성되는 y.tab.h를 include 하였다.

#### Makefile
bison을 사용해 y.tab.c를 자동으로 생성하고 컴파일 하기 위해 Makefile을 수정하였다.
```
# yacc에서 token들을 정의하기 때문에 가장 먼저 컴파일 되어야 한다.
# 컴파일 에러를 막기 위해, analyze.o, cgen.o를 컴파일 하지 않는다.
OBJS = y.tab.o lex.yy.o main.o util.o symtab.o

y.tab.o: cminus.y globals.h
	bison -d cminus.y --yacc
	$(CC) $(CFLAGS) -c y.tab.c
```	
#### util.c & util.h
BNF에서 Decl, Param, Type Node가 추가되었으므로 이를 생성하는 함수를 만든다.

또한 생성된 parse tree를 출력 할 수 있도록 printTree를 수정하였다.


#### cminus.y
yacc/tiny.y 파일을 복사하여 수정하였다.
대부분의 문법들은 tiny와 크게 다르지 않아 수정하는게 별 문제가 없었으나, ID(변수명이나 함수명)을 가져와야 하는 경우 ID를 가져오기 위해 별도의 처리가 필요하였다. 마지막 토큰만 저장하므로, 뒤의 토큰을 처리해 버리면 token이 날아가버려 identifier를 읽을 수 없는 것이다.
```bison
saveName    : ID
                 { savedName = copyString(tokenString);
                   savedLineNo = lineno;
                 }
                 
saveNumber  : NUM
                 { savedNumber = atoi(tokenString);
                   savedLineNo = lineno;
                 }
```
위 두 문법을 추가로 정의하여, ID와 NUM을 사용 하는 곳을 대체하여 사용하였다.

```bison
var_decl    : type_spec saveName SEMI
                 { $$ = newDeclNode(VarK);
                   $$->child[0] = $1; /* type */
                   $$->lineno = lineno;
                   $$->attr.name = savedName;
                   
```

saveName을 이용해 ID를 별도로 저장해두었다고 해도 저장하는 변수가 global variable이다 보니 덮어써지는 문제가 발생하기 때문에 saveName이후 또 saveName을 사용 할 경우 문제가 발생하였다. saveName에 stack을 사용한다면 하나씩 가져오는 것도 가능 하겠다고 생각하였지만, 굳이 stack을 사용하지 않아도 해결 가능한 문제였기에 사용하지 않았다. saveName을 이용하더라도 바로 파싱 결과를 저장하도록 변경하여, savedName이 덮어써지는 경우를 방지하였다. 아래 예제의 경우 saveName 바로 뒤에서 name을 저장하지 않는다면 args안에서 savedName을 덮어쓰기 된다.
```bison
call        : saveName {
                 $$ = newExpNode(CallK);
                 $$->attr.name = savedName;
              }
              LPAREN args RPAREN
                 { $$ = $2;
                   $$->child[0] = $4;
                 }
```

bison 버전의 문제인지 yylex function의 선언을 찾지 못해 컴파일 에러가 발생, cminus.y 의 상단에 yylex을 선언해주었다.
``` c 
static int yylex(void);
```


### Results

#### 1. test.cm
```
./cminus test.cm

TINY COMPILATION: test.cm

Syntax tree:
  Function Dec: gcd
    Type: int
    Parameter: u
      Type: int
    Parameter: v
      Type: int
    Compound Statment
      If
        Op: ==
          Id: v
          Const: 0
        Return
          Id: u
        Return
          Call(followings are args) : gcd
            Id: v
            Op: -
              Id: u
              Op: *
                Op: /
                  Id: u
                  Id: v
                Id: v
  Function Dec: main
    Type: void
    Compound Statment
      Var Dec: x
        Type: int
      Var Dec: y
        Type: int
      Assign
        Id: x
        Call(followings are args) : input
      Assign
        Id: y
        Call(followings are args) : input
      Call(followings are args) : output
        Call(followings are args) : gcd
          Id: x
          Id: y
```
과제 명세의 예제와 결과가 조금 다르지만, 파싱 이 정상적으로 일어났음을 확인 할 수 있다.

예제와 다른 곳은 선언에서의 Type부분인데, type은 cminus에서 void와 int만 선언하여서 그렇지 실제 C에선 const, static 등의 접두사가 붙을 수도 있기 때문에 확장성을 위해 함수 선언과 변수 선언해서 type을 child로 가지도록 하였다.


#### 2. Array Test
BNF상에 array가 존재하는데, test.cm에서 array를 테스트 히지 못해 추가적인 테스트를 수행하였다.
```c
int aaa[1234];
int function (int a,int b, int c[], int d) { }
```

```
Syntax tree:
  Var Dec(following const:array length): aaa 1234
    Type: int
  Function Dec: function
    Type: int
    Parameter: a
      Type: int
    Parameter: b
      Type: int
    Array Parameter: c
      Type: int
    Parameter: d
      Type: int
    Compound Statment
```

### Reviews
parse.c를 직접 작성하는 것이 쉽다고 이야기를 들었으나, 추후 직접 다른 언어를 만들어 볼때를 대비하여 yacc를 익혀두는 것이 좋을 것 같아 yacc를 이용하여 작성하였다. bison이 BNF로 문법만 정의하면 알아서 c code의 parser를 생성해주는 매우 High 한 수준인지 알았는데, BNF작성으로 끝나는 것이 아니라 tree의 내용들을 저장해 주는 과정도 필요하다는 것에 놀랬다. 하지만 편리한 도구임이 분명하며, bison을 사용해 보았다는 것 자체가 이번 과제를 통해 얻은 가장 큰 경험인 것 같다.
