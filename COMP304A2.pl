/* COMP304A2 */

/* 1.1 Road Database  */
/* I'm assuming that roads should be two way */
road("Wellington","Palmerston North",143). 
road("Palmerston North","Wanganui",74). 
road("Palmerston North","Napier",178).
road("Palmerston North","Taupo",259).
road("Wanganui","Taupo",231). 
road("Wanganui","New Plymouth ",163). 
road("Wanganui","Napier",252). 
road("Napier","Taupo",147). 
road("Napier","Gisborne",215). 
road("New Plymouth","Hamilton",242). 
road("New Plymouth","Taupo",289). 
road("Taupo","Hamilton",153). 
road("Taupo","Rotorua",82). 
road("Taupo","Gisborne",334). 
road("Gisborne","Rotorua",291). 
road("Rotorua","Hamilton",109). 
road("Hamilton","Auckland",126).

/* Predicate to make roads bi directional - takes X,Y,Z where x,y are start/finish and z is distance*/
bidirroad(X,Y,Z) :- road(X,Y,Z) ; road(Y,X,Z).

/* 1.2 Route Planning   */
/* route/3 finds a route between start and finish, saving the visited towns in Visits
 it uses routeHelp which has an aditional variable to keep track of towns visited so far to 
 achieve this with VisitedSoFar accumilating the visited town */
route(Start, Finish, Visits):- routeHelp(Start,Finish,[Start],Visits).
routeHelp(Finish,Finish,VisitedSoFar,Visits) :- Visits = VisitedSoFar.
routeHelp(Start,Finish,VisitedSoFar,Visits):-
    bidirroad(Start,X,_),
    \+member(X,VisitedSoFar), %stops towns from being visited twice
    append(VisitedSoFar,[X],Newvisits),
    routeHelp(X,Finish,Newvisits,Visits).
    

/* 1.3 Route Planning With Distances   */
/* Route/4 finds distance and visits using route/6 which has two additional variables, 
current and visitedsofar to find final distance and visits. */
route(Start,Finish,Visits, Distance):-
    route(Start,Finish,[Start],Visits,0, Distance).
route(Finish,Finish, VisitedSoFar,Visits,Current, Distance) :-  
    Distance is Current,
    Visits = VisitedSoFar.
route(Start,Finish,VisitedSoFar,Visits,Current, Distance):-
    bidirroad(Start,X,Z),
    \+member(X,VisitedSoFar), %stops towns from being visited twice
    append(VisitedSoFar,[X],Newvisits),
    Newdistance is Current + Z,
    route(X,Finish,Newvisits,Visits,Newdistance,Distance).

/* 1.4 Finding all routes. Choice uses findall and route/4 to find all routes and distances */
choice(Start,Finish,RoutesAndDistances) :- findall((X,Y), route(Start, Finish,X,Y), RoutesAndDistances).

/* 1.4.1 Finding all routes including towns in via (done using subset) */
via(Start,Finish,Via,RoutesAndDistances) :-  
    findall((X,Y), (route(Start, Finish,X,Y),subset(Via,X)), RoutesAndDistances).

/* 1.4.2 Finding All Routes avoiding towns in avoid, uses not_int/2 to check all members of first argument are not 
    members of second argument. */
not_in(Avoid,X) :- forall(member(E,Avoid),\+member(E,X)).
avoiding(Start,Finish,Avoid,RoutesAndDistances) :-  
    %findall((X,Y), (route(Start, Finish,X,Y),\+subset(Avoid,X)), RoutesAndDistances).
     findall((X,Y), (route(Start, Finish,X,Y),not_in(Avoid,X)) , RoutesAndDistances).


/* ############################ TESTING ############################ */

/* Tests for route planning */
/* Tests a sample input, between Wellingotn and auckland*/
?-route("Wellington","Auckland",["Wellington", "Palmerston North", "Wanganui", "Taupo", "Hamilton", "Auckland"]).
/* Tests a sample input, between Auckland and Rotorua*/
?-route("Auckland","Rotorua",["Auckland", "Hamilton", "New Plymouth", "Taupo", "Rotorua"]).
/* Tests that bi directional roading is working */
?-route("Hamilton","Auckland",["Hamilton","Auckland"]).
?-route("Auckland","Hamilton",["Auckland","Hamilton"]).
/* Tests for route with an invalid town , this fails so not predicate makes it run true*/
?-not(route("Auckland","Hamiltond",_)).
/* Route to self */
?-route("Auckland","Auckland",["Auckland"]).

/*  Tests for the route plannign with distances. */
/* Tests a sample input Wellington -> Auckland */
?-route("Wellington","Auckland",["Wellington", "Palmerston North", "Wanganui", "Taupo", "Hamilton", "Auckland"],727).
/* Tests a sample input Rotorua -> Hamilton */
?-route("Rotorua","Hamilton",["Rotorua", "Hamilton"],109).
/* Tests bidirection Rotorua -> Hamilton */
?-route("Hamilton","Rotorua",["Hamilton","Rotorua"],109).
/* Route to self */
?-route("Auckland","Auckland",["Auckland"],0).

/* Tests for choice predicate*/
/* Tests same input, all choice between Palmerston North and Wellington */
?-choice("Palmerston North","Wellington",[(["Palmerston North", "Wellington"], 143)]).
/* Tests Auckland -> Wellington gets correct number routes */
?-choice("Auckland","Wellington",X),length(X,35).
/* Tests Auckland -> Rotorua gets correct number routes */
?-choice("Auckland","Rotorua",X),length(X,15).
/* Tests bidirectional */
?-choice("Rotorua","Auckland",X),length(X,15).
/* Tests route to itself */
?-choice("Auckland","Auckland",[(["Auckland"], 0)]).

/* Tests for via */
/* Predicate to test via */
/* Tests sample input Auckland -> Wellington VIA Taupo*/
?-via("Auckland","Wellington",["Taupo"],X),length(X,33).
/* Tests for impossible input (proves cant visit same town twice )*/
?-via("Wellington","Wanganui",["Palmerston North","Auckland"],[]).
/* Check ordering of via and order of to/from is unimportant */
?-via("Auckland","Wellington",["Taupo","Gisborne"],X),length(X,18).
?-via("Auckland","Wellington",["Gisborne","Taupo"],X),length(X,18).
?-via("Wellington","Auckland",["Gisborne","Taupo"],X),length(X,18).

/* Tests for avoiding */
/* Test impossible input */
?-avoiding("Wellington","Auckland",["Palmerston North"],[]).
/* Test does avoid with sample input, Wellington->Taupo avoid Wanganui, Napier and New Plymouth */
?-avoiding("Wellington","Taupo",["Wanganui","Napier","New Plymouth"],[(["Wellington", "Palmerston North", "Taupo"], 402)]).
/* Test does avoid with sample input, Wellington->Taupo avoid Wanganui, Napier and New Plymouth */
?-avoiding("Auckland","Gisborne",["Taupo","Napier"],[(["Auckland", "Hamilton", "Rotorua", "Gisborne"], 526)]).
/* Test error on avoiding */
?-avoiding("Wellington","Taupo",["Wanganuid"],X),length(X,13).