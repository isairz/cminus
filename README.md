# C-Minus
2015년 컴파일러 수업의 과제인 C-Minus 제작을 위한 프로젝트이다.
[Tiny Compiler](http://www.cs.sjsu.edu/faculty/louden/cmptext/) 를 수정하여 C 문법의 Subset인  C-Minus를 직접 제작하여 본다.

### Tested Environment
 - OS X Yosemite (10.10.3)
 - Ubuntu 14.04 LTS

### Requirment
 - GCC
 - FLEX

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
