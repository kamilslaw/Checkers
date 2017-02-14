-module(gameInterface).
-compile(export_all).
-import(boardLogic, [changeMenToKings/1]).
-import(drawing, [showBoard/1, showMove/1]).
-import(lists, [foldl/3, nth/2]).
-import(minMax, [simulateAI/2]).
-import(movementLogic, [makeMove/2]).
-import(tree, [checkersCount/2, getAllPossibleMoves/2]).
-import(types, [newBoard2/0, newBoard3/0]).

main() -> 
    {ok, [BoardType]}   = io:fread("\nChoose type of Board - (2) Rows,  (3) Rows\n", "~d"),
    {ok, [PlayerWhite]} = io:fread("\nChoose type of White player \n1) Human \n2) AI\n", "~d"),
    {ok, [PlayerBlack]} = io:fread("\nChoose type of Black player \n1) Human \n2) AI\n", "~d"),
    Board              = if 
                             BoardType == 2 -> newBoard2();
                             true           -> newBoard3()  
                         end,
    showBoard(Board),
    play(Board, PlayerWhite, PlayerBlack).

play(Board, PlayerWhite, PlayerBlack) -> 
    BoardAfterWhite  = playColor(Board, white, PlayerWhite),
    BoardAfterBlack  = playColor(BoardAfterWhite, black, PlayerBlack),
    EndGameCondition = (checkersCount(Board, white) == 0) or (checkersCount(Board, black) == 0),
    if 
        EndGameCondition -> io:fwrite("** Game Over **\n");
        true             -> play(BoardAfterBlack, PlayerWhite, PlayerBlack)
    end.

playColor(Board, Color, PlayerType) ->
    NewBoard = if 
                   PlayerType == 1 -> try playHuman(Board, Color) of
                                          Result -> Result
                                      catch
                                          error:Error -> io:fwrite("~p~n", [Error]),
                                                         playColor(Board, Color, PlayerType)
                                      end;
                   true            -> simulateAI(Board, Color)
               end,    
    showBoard(NewBoard),
    NewBoard.

playHuman(Board, Color) ->
    PossibleMoves = getAllPossibleMoves(Board, Color),
    MoveDrawFunc  = fun(X, Acc) -> 
                        if 
                            Acc > 1 -> io:fwrite(" "); 
                            true    -> io:fwrite("") 
                        end, 
                        if 
                            Acc > 9 -> io:write(Acc); 
                            true    -> io:fwrite(" "), io:write(Acc) 
                        end,       
                        io:fwrite(": "),  
                        io:fwrite(showMove(X)), 
                        io:fwrite("\n"), 
                        Acc+1 end,
    foldl(MoveDrawFunc, 1, PossibleMoves),
    io:fwrite(" Now turn: "),
    if 
        Color == white -> io:fwrite("white");
        true           -> io:fwrite("black")
    end,
    {ok , [Move]} = io:fread("\n Choose the number of the move: ", "~d"),
    io:fwrite("\n"),
    if
        length(PossibleMoves) == 0 -> Board;
        true                       -> changeMenToKings(makeMove(Board, nth(Move, PossibleMoves)))
    end.

    
