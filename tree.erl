-module(tree).
-compile(export_all).
-import(boardLogic, [clearFieldsBetween/3, changeMenToKings/1, getChecker/2, getCheckersByColor/2, getCheckerType/1, moveChecker/3]).
-import(types, [newColor/1]).
-import(lists, [concat/1, map/2, filter/2, foldr/3, nth/2, nthtail/2]).
-import(movementLogic, [isAnyCapture/3, makeMove/2, possibleMoves/2]).

% tree :: {Board, Color, Integer, [Tree]}
generateTree(Board, Color, Depth)     ->
                    generateTree(Board, Color, Color, Depth).
                    
generateTree(Board, OrgColor, Color, 0)     ->
                    {Board, Color, valueByColor(Board, newColor(OrgColor)), []};
generateTree(Board, OrgColor, Color, Depth) ->
                    NewColor = newColor(Color),
                    Moves    = getAllPossibleMoves(Board, NewColor),
                    RecFunc  = fun(X) -> generateTree(changeMenToKings(makeMove(Board, X)), OrgColor, NewColor, Depth-1) end,
                    Children = map(RecFunc, Moves),
                    {Board, Color, valueByColor(Board, newColor(OrgColor)), Children}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generateTreeAsync(Board, Color, Depth) ->
                    % Start Thread Pool
                    threadPool:start(),
                    % Run Proccess for highest (first) tree level 
                    Pid            = self(),
                    spawn(fun() -> generateTreeAsync(Board, Color, Color, Depth, Pid) end),
                    % Get the result
                    Result         = receive X -> X end,
                    % Finish Thread Pool
                    threadPool:finish(),
                    Result.

generateTreeAsync(Board, OrgColor, Color, Depth, Parent) ->   
                    NewColor     = newColor(Color),
                    Pid          = self(),
                    % Check if there is any available thread, then start new, otherwise calculate synchronously
                    ChildFunc    = fun(Move) -> UseNewThread = if 
                                                                   Depth > 1 -> threadPool:canGetNew();
                                                                   true      -> rejection 
                                                               end,                                                
                                                case UseNewThread of 
                                                    rejection -> 
                                                        {sync, Move};
                                                    ok        -> 
                                                        NewBoard = changeMenToKings(makeMove(Board, Move)),
                                                        %drawing:showBoard(NewBoard),                                                        
                                                        spawn(fun() -> generateTreeAsync(NewBoard, OrgColor, NewColor, Depth-1, Pid) end),
                                                        async
                                                end end,
                     % Get every possible move
                     Moves       = getAllPossibleMoves(Board, NewColor),
                     % Check every move
                     Children    = map(ChildFunc, Moves),  
                     % Get the results                              
                     ChildrenRes = map(fun(Result) -> case Result of
                                                          {sync, Move}  -> 
                                                              NewBoard = changeMenToKings(makeMove(Board, Move)),
                                                              generateTree(NewBoard, OrgColor, NewColor, Depth-1);
                                                          async         -> 
                                                              receive X -> X end
                                                      end end,
                                       Children),
                     % free the thread
                     threadPool:freeThread(),
                     % Send result to parent
                     Parent ! {Board, Color, valueByColor(Board, newColor(OrgColor)), ChildrenRes}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

valueByColor(Board, Color) -> 
                    CheckersCountColor     = checkersCount(Board, Color),
                    CheckersCountDiffColor = checkersCount(Board, newColor(Color)),
                    CheckersValueColor     = checkersValue(Board, Color),
                    CheckersValueDiffColor = checkersValue(Board, newColor(Color)),
                    Multiplier             = if 
                                                 CheckersCountColor + CheckersCountDiffColor > 6 -> 3000;
                                                 true                                            -> 500
                                             end,
                    MyCheckers             = (Multiplier * CheckersCountColor) + (2 * CheckersValueColor),
                    OpponentCheckers       = (2000 * CheckersCountDiffColor) + CheckersValueDiffColor,
                    MyCheckers - OpponentCheckers.

checkersValue(Board, Color) -> 
                    Checkers = getCheckersFromBoard(Board, Color, false),
                    Func     = fun(Pos, Acc) -> Acc + fieldValue(Pos) + checkerValueByType(Board, Pos) end,
                    foldr(Func, 0, Checkers).

checkerValueByType(Board, Pos) ->
                    CheckerType = getCheckerType(getChecker(Board, Pos)),
                    if
                        CheckerType == king -> 4;
                        true                -> 1
                    end.

fieldValue({_, 1}) -> 6;
fieldValue({_, 8}) -> 6;
fieldValue({1, _}) -> 5;
fieldValue({8, _}) -> 5;
fieldValue({2, _}) -> 3;
fieldValue({7, _}) -> 3;
fieldValue({_, 2}) -> 3;
fieldValue({_, 7}) -> 3;
fieldValue({4, 4}) -> 1;
fieldValue({5, 5}) -> 1;
fieldValue(_)      -> 2.

checkersCount(Board, Color) -> 
                    length(getCheckersFromBoard(Board, Color, false)).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getAllPossibleMoves(Board, Color) -> 
                    IsAnyCapture = length(getCheckersFromBoard(Board, Color, true)) > 0,
                    Checkers     = getCheckersFromBoard(Board, Color, IsAnyCapture),
                    Func         = fun(Pos) -> map(fun(X) -> [Pos] ++ X end, possibleMoves(Board, Pos)) end,
                    Result       = concat(map(Func, Checkers)),
                    utils:leaveTheLongestsPaths(Result).

getCheckersFromBoard(Board, Color, WithCapture) ->
                    CaptureCondition = fun(Pos) -> ((getCheckerType(getChecker(Board, Pos)) == man) and 
                                                    isAnyCapture(Board, Pos, false)) or
                                                   ((getCheckerType(getChecker(Board, Pos)) == king) and 
                                                    isAnyCapture(Board, Pos, true)) end,                  
                    Condition        = if 
                                           WithCapture -> CaptureCondition;
                                           true        -> fun(_) -> true end
                                       end,
                    Checkers         = getCheckersByColor(Board, Color),
                    filter(Condition, Checkers).       
