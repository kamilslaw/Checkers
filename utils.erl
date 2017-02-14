-module(utils).
-compile(export_all).
-import(lists, [concat/1, filter/2, foldl/3, foldr/3, map/2, max/1]).

even(X) -> X band 1 == 0.
odd(X)  -> not even(X).

intersperse(Str, Char) -> concat(map(fun(X) -> concat([X, [Char]]) end, Str)).

foldl1(Func, [H|T]) -> foldl(Func, H, T).

% Leave the longest subarrays in array
leaveTheLongestsPaths([]) -> [];
leaveTheLongestsPaths(Paths) -> 
                    Max = max(map(fun(X) -> length(X) end, Paths)),
                    filter(fun(X) -> length(X) == Max end, Paths).