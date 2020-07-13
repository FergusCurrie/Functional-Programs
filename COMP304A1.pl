/* ------------------------------------------------------------------------------------------------------ */
/* ###### 1.2 Printing Sentences ###### */
/* I'm assuming that this should print anyway even if it isn't a correct sentence (e.g. random word)*/

/* Print sentence is recuisvely defined. The first one is the base case so that a call to print sentence
    will return true if able to print. Splits into head and tail, prints head (? if qm) then printSetence
    of tail. */

printSentence([]).
printSentence(X) :-
    X  =  [Head|Tail],
    (Head = qm -> write('?') ;  write(Head),write(' ')),
    printSentence(Tail).


/* ------------------------------------------------------------------------------------------------------ */
/* ###### 1.3 Answering input ###### */ 
/* Note for this assignment I am assuming that if the input phrase could match to multiple there is 
    no priority over patterns -> whatever happens happens. */

/* Code works like this : answer -> call match -> generates list with second deminsion lists representing
   ellipses -> fix called on list which recursively calls transform all on ellipses -> generates output list */

/* Transformation facts (assuming that don't need to figure out ALL requried transformations in english
    langauge, general principle will do)*/
transform(my,your).
transform(you,me).
transform(am,are).
transform(your,my).
transform(me,you).
transform(are,am).
transform(my,your).
transform(your,my).
/*  Default transformation => word doesn't have a fact so doesn't change */
transform(X,X).


/* Recursive definition of transformAll, given a list applies transform to every member, 
    generating a list of these transformations. The variables of this predicate are the current list, 
    which is split into head and tail, the middle (M) which is where the return list is built and 
    R where variable is set (almost like a return)  */
transformAll([],R,R).
transformAll([H|T],M,R) :-     
    transform(H,Htrans),
    append(M,[Htrans],Q),
    transformAll(T,Q,R).

/* Recursive definition which takes a 2d list and generate 1d list, the second dimension lists represent ellipsis
    and are trasnformAlled to transform every member of them according to the facts. 
    the variables of this predicate are the current list, which is split into head and tail, the middle (M)
    which is where the return list is built and R where variable is set (almost like a return)    */
fix([],R,R).
fix([H|T],M,R) :-    
    ( is_list(H) -> transformAll(H,[],HRes) ; HRes = [H]),
    append(M,HRes,Final),
    fix(T,Final,R).


/*   Matching phrases in input question   */
match([i,feel|Z],[what,makes,you,feel,Z,qm]).
match([i,fantasised|Z],[have,you,ever,fantasised,Z,before,qm]).
match([you|_],[let, us, not, talk, about, me,.]).

match([i,hate,X],[who,is,X,qm]).
match([_,sucks|_],[try,being,less,negative]).

/*   Had some difficulty if there were two ... in phrase, this is my solution 
    Takes input X and Y, sets Y depending on X*/
match(X,Y) :- 
    \+length(X,1),
    /* Checks if night mare is contained */
    (member(nightmare,X) -> Y = [do,nightmares,frighten,you,qm] ; 
    reverse(X,G),
    G = [H|_],
    /* checks if it is a random question */
    (member(?,[H]) -> Y = [why,do,you,ask,qm] ; fail)
    ).

/* Main answer/2 predicate for 1.3, Has two inputs, X the input list and Y where output is saved to*/
answer(X,Y) :- 
    match(X,MatchRes),
    fix(MatchRes,[],Y).


/* ------------------------------------------------------------------------------------------------------ */
/*     Testing     */

/* Print Reply predicae takes and input list and applies the code from 1.3, then 1.2 to it */ 
printReply(X) :-
    answer(X,Y),
    printSentence(Y),
    nl().

/* The following 14 tests are split into groups of 2. Each group tests a different pattern. The first test
   shows how the basic pattern works, putting the unimportant part of pattern into ellipsis. The second test
   is with a random input (ellipsis filled in). This shows that the transform of words such as you -> me works. */
?- printReply([i,feel,...]).
?- printReply([i,feel,angry,when,you,are,mean]).

?- printReply([i,fantasised,...]).
?- printReply([i,fantasised,that,me,was,the,wealthiest,man,in,the,world]). 

?- printReply([you,...]).
?- printReply([you,you]).

?- printReply([...,nightmare,...]).
?- printReply([my,nightmare,suck]).

?- printReply([...,?]).
?- printReply([anything,can,go,in,here,?]).

?- printReply([i,hate,...]).
?- printReply([i,hate,you]).

?- printReply([...,sucks,...,...]).
?- printReply([bob,sucks,he,always,annoying]).


/* ------------------------------------------------------------------------------------------------------ */