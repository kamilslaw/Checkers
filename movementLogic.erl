-module(movementLogic).
-compile(export_all).
-import(boardLogic, [checkIfEmpty/2, checkIfEnemy/3, checkIfFriend/3, clearFieldsBetween/3, 
                     copyChecker/3, getChecker/2, getCheckerColor/1, getCheckerType/1, getCheckersBetween/2, 
                     getCheckersPositions/0, getCheckerPositionsForCapture/2, moveChecker/3]).
-import(lists, [concat/1, filter/2, foldr/3, map/2, nth/2, nthtail/2]).

makeMove(Board, []) -> Board;
makeMove(Board, [_]) -> Board;
makeMove(Board, Moves) -> 
                    FirstPos             = nth(1, Moves),
                    SecPos               = nth(2, Moves),
                    BoardWithCleanFields = clearFieldsBetween(Board, FirstPos, SecPos),
                    NewBoard             = moveChecker(BoardWithCleanFields, FirstPos, SecPos),
                    makeMove(NewBoard, nthtail(1, Moves)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

possibleMoves(Board, Pos) -> 
                    Checker     = getChecker(Board, Pos),
                    CheckerType = getCheckerType(Checker),
                    case CheckerType of 
                        noType -> [];
                        man    -> utils:leaveTheLongestsPaths(possibleMovesByType(Board, Pos, false));
                        king   -> utils:leaveTheLongestsPaths(possibleMovesByType(Board, Pos, true))
                    end.

possibleMovesByType(Board, Pos, IsKing) ->
                    AnyCapture = isAnyCapture(Board, Pos, IsKing),
                    case AnyCapture of
                        true  -> movesWithCapture(Board, Pos, IsKing);
                        false -> movesWithoutCapture(Board, Pos, IsKing)
                    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

isAnyCapture(Board, Pos, IsKing) -> 
                    Positions = getCheckerPositionsForCapture(Pos, IsKing),
                    Function  = fun(NewPos, Acc) -> isCapturePossible(Board, Pos, NewPos) or Acc end,
                    foldr(Function, false, Positions).

isCapturePossible(Board, Pos, NewPos) -> 
                    IsLastFieldEmpty = checkIfEmpty(Board, NewPos),
                    FieldsToCheck    = getCheckersBetween(Pos, NewPos),
                    Function         = fun(CheckPos, Acc) -> fieldCounter(Board, Pos, CheckPos, Acc) end,
                    Exactly1Enemy    = foldr(Function, 0, FieldsToCheck) == 1,
                    Exactly1Enemy and IsLastFieldEmpty.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

movesWithoutCapture(Board, {X, Y}, IsKing) ->
                    CheckerColor     = getCheckerColor(getChecker(Board, {X, Y})),
                    PredicateForMan  = fun({PX, PY}) -> (abs(X-PX) == 1) and
                                                        (abs(Y-PY) == 1) and 
                                                        checkIfEmpty(Board, {PX, PY}) and
                                                        (((PY > Y) and (CheckerColor == white)) or 
                                                         ((PY < Y) and (CheckerColor == black))) end,
                    PredicateForKing = fun({PX, PY}) -> (abs(X-PX) == abs(Y-PY)) and
                                                        (X /= PX) and
                                                        (Y /= PY) and 
                                                        checkIfEmpty(Board, {PX, PY}) and
                                                        foldr(fun(Pos, Acc) -> Acc and checkIfEmpty(Board, Pos) end, 
                                                               true, 
                                                               getCheckersBetween({X, Y}, {PX, PY})) end,     
                    Predicate        = fun(Pos) -> case IsKing of
                                                       true  -> PredicateForKing(Pos);
                                                       false -> PredicateForMan(Pos)
                                                   end end,
                    Filtered         = filter(Predicate, getCheckersPositions()),
                    map(fun(El) -> [El] end, Filtered).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

movesWithCapture(Board, Pos, IsKing) ->
                    Possibilities = [[NewPos] || NewPos <- getCheckerPositionsForCapture(Pos, IsKing), isCapturePossible(Board, Pos, NewPos)],
                    MoveLogic     = fun([NewPos]) -> 
                                                   NextStopMoves = movesWithCaptureNextStep(Board, Pos, NewPos, IsKing),
                                                   Len           = length(NextStopMoves),
                                                   if 
                                                       Len == 0 -> [[NewPos]];
                                                       true     -> map(fun(X) -> [NewPos] ++ X end, NextStopMoves)
                                                   end end, 
                    concat(map(MoveLogic, Possibilities)).

movesWithCaptureNextStep(Board, Pos, NewPos, IsKing) ->
                    BoardAfterMoving   = copyChecker(Board, Pos, NewPos),
                    BoardAftreCleaning = clearFieldsBetween(BoardAfterMoving, Pos, NewPos),
                    movesWithCapture(BoardAftreCleaning, NewPos, IsKing).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fieldCounter(Board, Pos, NewPos, Acc) ->
                    IsFriend = checkIfFriend(Board, Pos, NewPos),
                    IsEnemy  = checkIfEnemy(Board, Pos, NewPos),
                    if
                        IsFriend -> Acc + 2;
                        IsEnemy  -> Acc + 1;
                        true     -> Acc
                    end.

