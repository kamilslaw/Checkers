-module(drawing).
-compile(export_all).
-import(io_lib, [format/2]).
-import(lists, [concat/1, foldl/3, map/2, zipwith/3]).
-import(string, [join/2]).

showField(F) -> case F of
                    empty -> ".";
                    _Else -> showChecker(F)
                end.

showChecker(F) -> case F of
                      {man,  black} -> "b";
                      {king, black} -> "B";
                      {man,  white} -> "w";
                      {king, white} -> "W"
                  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

showMove(Move) -> utils:foldl1(fun(X, Acc) -> Acc ++ " -> " ++ X end, generateMoveString(Move)).

generateMoveString([])         -> [];
generateMoveString([{Y, X}|T]) -> PosStr = concat(format("~c~c", [Y+64, X+48])), % Change Y-coordinate from number to letter (A-H)
                                  [PosStr | generateMoveString(T)].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

showBoard(Board) -> io:format(generateExtBoardStr(Board)).

generateBoardString(Board) -> concat(utils:intersperse(map(fun(X) -> map(fun(F) -> showField(F) end, X) end, Board), "\n")).

generateExtBoardStr(Board) -> 
            HorizNumbers = "\n  ABCDEFGH\n\n",
            VertNumbers  = ["8 ", "7 ", "6 ", "5 ", "4 ", "3 ", "2 ", "1 "],
            GenBoard     = map(fun(X) -> map(fun(F) -> showField(F) end, X) end, Board),
            Lines        = concat(utils:intersperse(zipwith(fun(X,Y)-> [X ++ Y]  end, VertNumbers, GenBoard), "\n")),
            map(fun(X) -> [X | " "] end, HorizNumbers ++ Lines ++ "\n").
