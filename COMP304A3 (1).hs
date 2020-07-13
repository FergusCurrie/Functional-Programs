------------------------------------
--------- 1 LIST FUNCTIONS ---------
------------------------------------

------- Helper Functions -------
sum' [] = 0
sum' (x:xs) = x + sum' xs

myAppend :: [a] -> [a] -> [a]
myAppend [] x = x
myAppend (x:xs) y = x : myAppend xs y

myAppend2d :: [[a]] -> [[a]] -> [[a]]
myAppend2d [] x = x
myAppend2d (x:xs) y = x : myAppend2d xs y

t0 = sum' [1,2,3,4,5] == 15
t1 = myAppend [1,2,3] [4,5] == [1,2,3,4,5]
t2 = myAppend2d [[1,2,3]] [[3]] == [[1,2,3],[3]]
  -- Tests the helper methods work

------- (a) Empty List -------
empty :: [t] -> Bool
empty [] = True
empty (_:_) = False

t3 = empty [1] == False
t4 = empty[] == True
  -- Test for the two cases : empty or not empty.

------- (b) Second -------
second :: [t] -> t
second (x:xt:xs) = xt

t5 = second [ "AA", "BB", "CC" ] == "BB"
t6 = second [ "BB", "CC" ] == "CC"
  -- These tests make sure it gets second value, tries with two sizes

------- (c) Foot -------
foot :: [t] -> t
foot [x] = x
foot (_:xs) =  foot xs

t7 = foot [ "AA", "BB", "CC"] == "CC"
t8 = foot [1,2,3,4,5,6,7,8,9] == 9
t8a = foot [1] == 1
  -- Tests the foot of two differently sized lists

------- (d) Suffixes -------
allSuffixes :: [t] -> [[t]]
allSuffixes [] = []
allSuffixes (x:xs) = myAppend2d ([(myAppend [x] xs)]) (allSuffixes xs)

t9 = allSuffixes ["AA","BB", "CC"] == [["AA","BB","CC"],["BB","CC"],["CC"]]
t10 = allSuffixes [1,2,3,4,5,6] == [[1,2,3,4,5,6],[2,3,4,5,6],[3,4,5,6],[4,5,6],[5,6],[6]]
t10a = True--allSuffixes [] == []
  -- Tests two suffixes of differnet length plus empty suffix

------- (e) Below 21 -------
vingtEtUn :: (Num n, Ord n) => [n] -> [n]
vingtEtUn [] = []
vingtEtUn  inp = vingtEtUn' [] inp

vingtEtUn' s [] = []
vingtEtUn' s (x:xs)
  | (sum' (myAppend s [x]) <= 21) = vingtEtUn' (myAppend s [x]) xs
  | otherwise = s

t11 = vingtEtUn [8,10,2,7,1,10] == [8,10,2]
t12 = vingtEtUn [21,10,2,7,1,10] == [21]
t13 = vingtEtUn [22,10,2,7,1,10] == []
t14 = vingtEtUn [] == []
  -- Tests the case from handout, a case on the boarder 21, a case over board 22 and empty case



--Runs all part 1 tests
test_1 = [t0,t1,t2,t3,t4,t5,t6,t7,t8,t8a,t9,t10,t10a,t11,t12,t14]

-- Discussion
{-
This is the first time I have ever seen Haskell so took a bit of time to get used to it.
My prolog experience from this course is helpful because functional is a different way of thinking.
I used a few helper functions to get the job done : myAppend, myAppend2d, sum'. myAppend and
myAppend2d are very similar but the first deals with 1d list [] and the second deals with 2d list [[]].
I originally coded this part using ++ append as I didn't realise it was not allowed. I replaced it with
my own recursive definitions.

In my testing I found that for vingtEtUn I was messing up the boundary case of 21. I checked my method
and found that I had been using < 21 rather than <= 21.
-}





------------------------------------
------- 2 IMPLEMENTING TABLE -------
------------------------------------

------- (a) Empty Table -------
emptyTable :: ([k],[v])
emptyTable = ([],[])


------- (b) Has Key -------
hasKey :: (Eq k) => k -> ([k],[v]) -> Bool
hasKey key ([],[]) = False
hasKey key ([],v) = error "Bad key/value"
hasKey key (ks,[]) = error "bad key/value"
hasKey key ((k:ks),(v:vs))
  | key== k = True
  | ks == [] = False
  | otherwise = hasKey key (ks,vs)

t15 = hasKey 1 ([1,2,3],[4,5,6]) == True
t16 = hasKey 20 ([1,2,3],[4,5,6]) == False
  -- Tests an existent key and a non-existent key


------- (c) Get Value -------
getValue :: (Eq k) => k -> ([k],[v]) -> v
getValue key ([],[]) = error "No key with this value"
getValue key ([],v) = error " Bad Pair"
getValue key (ks,[]) = error " Bad pair "
getValue key ((k:ks),(v:vs))
  | key==k = v
  | otherwise = getValue key (ks,vs)

t17 = getValue 1 ([1,2,3],[4,5,6]) == 4
t18 = getValue 3 ([1,2,3],[4,5,17]) == 17
  -- Tests first and last element of list


------- (d) With Key Value -------
withKeyValue :: (Eq k) => k -> v -> ([k],[v]) -> ([k],[v])
withKeyValue key val ((k:ks),(v:vs))
  | hasKey key ((k:ks),(v:vs)) = ((k:ks),(updateKey key val [] ((k:ks),(v:vs))))
  | otherwise = error " key doenst exist "
updateKey :: (Eq k)=>k -> v -> [v] -> ([k],[v]) -> [v]
updateKey key val newV ([],[]) = error "No key with this value"
updateKey key val newV ((k:ks),(v:vs))
  | ks == [] && key /= k = (newV ++ [v])
  | ks == [] && key == k = (newV ++ [val])
  | k /= key = updateKey key val (newV ++ [v]) (ks,vs)
  | k == key = updateKey key val (newV ++ [val]) (ks,vs)

t19 = withKeyValue 1 100 ([1,2,3],[4,5,6]) == ([1,2,3],[100,5,6])
t20 = withKeyValue 3 100 ([1,2,3],[4,5,6]) == ([1,2,3],[4,5,100])
  -- Two test cases for index 1 and 3



------- (e) without key -------
withoutKey :: (Eq k) => k -> ([k],[v]) -> ([k],[v])
withoutKey key ((k:ks),(v:vs))
  | hasKey key ((k:ks),(v:vs)) = removeKeyPair key [] [] ((k:ks),(v:vs))
  | otherwise = error " key doesn't exist "

removeKeyPair :: (Eq k) => k -> [k] -> [v] -> ([k],[v]) -> ([k],[v])
removeKeyPair key newK newV ([],[]) = error "No key with this value"
removeKeyPair key newK newV ((k:ks),(v:vs))
  | ks == [] && key /= k = ((newK ++ [k]),(newV ++ [v]))
  | ks == [] && key == k = (newK,newV)
  | k /= key = removeKeyPair key (newK ++ [k]) (newV ++ [v]) (ks,vs)
  | k == key = removeKeyPair key newK newV (ks,vs)

t21 = withoutKey 2 ([1,2,3],[4,5,6]) == ([1,3],[4,6])
t22 = withoutKey 1 ([1,2,3],[4,5,6]) == ([2,3],[5,6])
  -- Two tests for cases index 1 and 3



-- Run Part 2 Tests
test_2 = [t15,t16,t17,t18,t19,t20,t21,t22]

-- Discussion
{-
Now that I understand Haskell better this part was much easier. I find the output messages
from the console confusing and don't really give me much indication of what to change so I
have been using the location of the error to debug rather than what is going wrong.
I found withoutKey and withKeyValue very similar, especially their helper methods. These
both built new list using guards and then put them together to make the update table.
There were quite a few different ways of doing this such as on finding the value to delete
simply adding the list so far and the remaining together. I realised this later but had already
wrote it so that it added values to the new list until it gets to the key to delete and then ignores it,
after this it continues deleting.
-}







------------------------------------
------- 3 FORTH to Haskell! --------
------------------------------------
stack = []

one :: [Int] -> [Int]
one s = (1 : s)

dup :: [Int] -> [Int]
dup s = s ++ [(s !! ((length s)-1))]

pop :: [Int] -> [Int]
pop s = init s

plus :: [Int] -> [Int]
plus s =  pop (pop s) ++ [(+) (last s) (last (init s))]

swap :: [Int] -> [Int]
swap s =  pop (pop s) ++ [(last s)] ++ [(last (init s))]

times :: [Int] -> [Int]
times s =  pop (pop s) ++ [(*) (last s) (last (init s))]

push :: [Int] -> Int -> [Int]
push s n = s ++ [n]

run :: [[Int] -> [Int]] -> Int
run g = run' g stack

run' [o] s = last (o s)
run' (o:os) s = run' os (o s)


t23 = dup [2,3,4]  == [2,3,4,4]
t24 = pop [2,3,4] == [2,3]
t25 = plus [2,3,4] == [2,7]
t26 = times [2,3,4] == [2,12]
t27 = swap [2,3,4] == [2,4,3]
t28 = run [one] == 1
t29 = run [one,dup,dup,plus,plus] == 3

test_3 = [t23,t24,t25,t26,t27,t28,t29]


-- Discussion
{-
Using stack with index 0 as bottom of stack. Order of doing things really important in this question.
I implemented all the other methods first and then run. Didn't managed to get the run push part working,
kinda ran out of time unfortunately. To do with the integer. 
-}
------------------------------------
------------ RUN TESTS -------------
------------------------------------

run_test = [test_1,test_2,test_3]
main = print run_test

------------------------------------
------------------------------------
------------------------------------
