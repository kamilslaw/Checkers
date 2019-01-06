Implementation of checkers, allows playing with AI (based on concurrent MinMax algorithm)

To start the game (requires Erlang OTP):

```erlang
c(types).
c(boardLogic).
c(movementLogic).
c(utils).
c(drawing).
c(threadPool).
c(tree).
c(minMax).
c(gameInterface).

gameInterface:main().
```
