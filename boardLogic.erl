-module(boardLogic).
-compile(export_all).
-import(lists, [filter/2, foldr/3, map/2, nth/2, nthtail/2, seq/2, sublist/2]).

putChecker(Board, Field, {Width, Height}) ->
                    Head = sublist(Board, 8-Height),
                    Tail = nthtail(1+8-Height, Board),
                    CorrectRow = nth(1+8-Height, Board),
                    NewRow = putIntoRow(CorrectRow, Field, Width),
                    Head ++ [NewRow] ++ Tail.

removeChecker(Board, Position) -> putChecker(Board, empty, Position).

moveChecker(Board, OldPosition, NewPosition) ->
                    Checker = getChecker(Board, OldPosition),
                    BoardAfterRemoving = removeChecker(Board, OldPosition),
                    putChecker(BoardAfterRemoving, Checker, NewPosition).

copyChecker(Board, Position, NewPosition) ->
                    Checker = getChecker(Board, Position),
                    putChecker(Board, Checker, NewPosition).

changeMenToKings(Board) -> 
                    Middle = nthtail(1, sublist(Board, 7)),
                    Top = map(fun(F) -> case F of 
                                            {man, white} -> {king, white};
                                            _Else -> F
                                        end end, 
                                        nth(1, Board)),
                    Bottom = map(fun(F) -> case F of 
                                               {man, black} -> {king, black};
                                               _Else -> F
                                           end end, 
                                           nth(8, Board)),
                    [Top] ++ Middle ++ [Bottom].

clearFieldsBetween(Board, FirstPos, SecPos) ->
                    Fields = getCheckersBetween(FirstPos, SecPos),
                    foldr(fun(Pos, Acc) -> putChecker(Acc, empty, Pos) end, Board, Fields).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getCheckersPositions() -> [{C, D} || C <- seq(1,8), D <- seq(1,8), utils:even(C+D)].

getCheckersBetween({X1, Y1}, {X2, Y2}) -> 
                    Predicate = fun({X, Y}) -> (X > min(X1, X2)) and (X < max(X1, X2)) and
                                             (Y > min(Y1, Y2)) and (Y < max(Y1, Y2)) and 
                                             (abs(X1-X) == abs(Y1-Y)) end,
                    filter(Predicate, getCheckersPositions()).

getChecker(Board, {Width, Height}) -> nth(Width, nth(1+8-Height, Board)).
                    
getCheckerType(Field) -> case Field of
                            empty     -> noType;
                            {Type, _} -> Type
                         end.

getCheckerColor(Field) -> case Field of
                            empty      -> noColor;
                            {_, Color} -> Color
                          end.

getCheckersByColor(Board, Color) -> 
                        Predicate = fun({X, Y}) -> getCheckerColor(getChecker(Board, {X, Y})) == Color end,
                        filter(Predicate, getCheckersPositions()).

getCheckerPositionsForCapture({PX, PY}, IsKing) ->
                        PredicateForMan  = fun({X, Y}) ->  (abs(PX-X) == 2) and (abs(PY-Y) == 2) end, 
                        PredicateForKing = fun({X, Y}) ->  (abs(PX-X) == abs(PY-Y)) and (PX /= X) and (PY /= Y) end, 
                        Predicate = fun(Pos) -> case IsKing of 
                                                     true  -> PredicateForKing(Pos);
                                                     false -> PredicateForMan(Pos)
                                                 end end,                      
                        filter(Predicate, getCheckersPositions()).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

checkIfEmpty(Board, Pos) -> getChecker(Board, Pos) == empty.

checkIfEnemy(Board, FirstPos, SecPos) ->
                    FirstColor = getCheckerColor(getChecker(Board, FirstPos)),
                    SecColor   = getCheckerColor(getChecker(Board, SecPos)),
                    (FirstColor /= noColor) and  (SecColor /= noColor) and (FirstColor /= SecColor).

checkIfFriend(Board, FirstPos, SecPos) ->
                    FirstColor = getCheckerColor(getChecker(Board, FirstPos)),
                    SecColor = getCheckerColor(getChecker(Board, SecPos)),
                    (FirstColor /= noColor) and  (SecColor /= noColor) and (FirstColor == SecColor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

putIntoRow(Row, Field, Index) ->
                    Head = sublist(Row, Index-1),
                    Tail = nthtail(Index, Row),
                    Head ++ [Field] ++ Tail.
