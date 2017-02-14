-module(minMax).
-compile(export_all).
-import(types, [newColor/1]).
-import(lists, [foldr/3, map/2, nth/2]).
-import(tree, [checkersCount/2, generateTree/3, generateTreeAsync/3]).

-define(TREE_DEPTH, 5).

simulateAI(Board, Color) ->
                    NewColor            = newColor(Color),
                    CheckersCount       = checkersCount(Board, NewColor),
                    if 
                        CheckersCount == 0 ->
                            Board;
                        true               ->
                            % Tree                = generateTree(Board, NewColor, ?TREE_DEPTH),
                            Tree                = generateTreeAsync(Board, NewColor, ?TREE_DEPTH),
                            {NewBoard, _, _, _} = minMax(1, Tree),
                            NewBoard
                    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
minMax(_, {Board, Color, Value, []})       -> 
                    {Board, Color, Value, []};
minMax(N, {Board, Color, Value, Children}) ->
                    ChildrenMinMax = map(fun(Child) -> minMax(N+1, Child) end, Children),
                    Func           = fun(X, Acc) -> minMaxCondition(N, X, Acc) end,  
                    Max            = foldr(Func, nth(1, ChildrenMinMax), ChildrenMinMax),
                    if 
                        N > 1 -> copyMoveValueForTree({Board, Color, Value, Children}, Max);
                        true  -> Max
                    end.

minMaxCondition(N, X, Acc) ->
                    IsOdd    = utils:odd(N),
                    XValue   = valueForTree(X),
                    AccValue = valueForTree(Acc),
                    if 
                        IsOdd and (XValue > AccValue) -> X;
                        IsOdd                         -> Acc;
                        XValue < AccValue             -> X;
                        true                          -> Acc
                    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

valueForTree({_, _, Value, _}) -> Value.

copyMoveValueForTree({Board, Color, _, _}, {_, _, Value2, Children2}) ->
                    {Board, Color, Value2, Children2}.             