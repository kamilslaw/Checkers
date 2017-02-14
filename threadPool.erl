-module(threadPool).
-compile(export_all).

coresNumber() -> erlang:system_info(schedulers_online).

start() -> register(threadpool, spawn(fun() -> threadPool(coresNumber() - 1) end)).

finish() -> threadpool ! finish.

canGetNew() -> threadpool ! {canGetNew, self()},
               receive X -> X end.

freeThread() -> threadpool ! freeThread.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

threadPool(AvailableCores) ->
                receive 
                    finish              -> ok;
                    freeThread          -> threadPool(AvailableCores + 1);
                    {canGetNew, Sender} -> 
                        if 
                            AvailableCores > 0 -> Sender ! ok,
                                                  threadPool(AvailableCores - 1);
                            true               -> Sender ! rejection,
                                                  threadPool(0)
                        end
                end.