-module(types).
-compile(export_all).
-import(lists, [map/2, seq/2]).
-import(string, [tokens/2]).

newBoard2()  -> loadBoardFromString(".b.b.b.b\nb.b.b.b.\n........\n........\n........\n........\n.w.w.w.w\nw.w.w.w.\n").
newBoard3()  -> loadBoardFromString(".b.b.b.b\nb.b.b.b.\n.b.b.b.b\n........\n........\nw.w.w.w.\n.w.w.w.w\nw.w.w.w.\n").
emptyBoard() -> [[empty || _ <- seq(1, 8)] || _ <- seq(1, 8)].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loadBoardFromString(BoardStr) -> 
    map(fun(L) -> map(fun(X) -> fromCharToField(X) end, L) end, tokens(BoardStr, "\n")).

fromCharToField(X) -> if
                          X == $. -> empty;
                          X == $b -> {man,  black};
                          X == $B -> {king, black};
                          X == $w -> {man,  white};
                          X == $W -> {king, white}
                      end.

newColor(white) -> black;
newColor(black) -> white.