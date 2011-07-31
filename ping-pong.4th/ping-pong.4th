\ ping-pong.4th

VARIABLE LEFT-BASE-POS
VARIABLE RIGHT-BASE-POS
VARIABLE BAll-X
VARIABLE BALL-Y
VARIABLE BALL-DIRECTION ( 0 -- LT, 1 -- RT, 3 -- RB, 2 -- LB )
VARIABLE FIRST-PLAYER-SCORE
VARIABLE SECOND-PLAYER-SCORE

: DEFAULT-VARIABLES
    9 LEFT-BASE-POS !
    9 RIGHT-BASE-POS !
    40 BAll-X !
    12 BALL-Y !
    0  BALL-DIRECTION !
    0 FIRST-PLAYER-SCORE !
    0 SECOND-PLAYER-SCORE !
;

: DRAW-BORDERS
    80 0 DO I  0 AT-XY ." *" LOOP \ top horisontal
    80 0 DO I 25 AT-XY ." *" LOOP \ bottom horisontal
    25 1 DO 0  I AT-XY ." *" LOOP \ left vertical
    25 1 DO 79 I AT-XY ." *" LOOP \ right vertical
    4 25 AT-XY ." [ 0 ]"
    70 25 AT-XY ." [ 0 ]"
;

: DRAW-LEFT-BASE
    2 LEFT-BASE-POS @ 5 0 DO 2DUP I + AT-XY ." |" LOOP 2DROP
;

: DRAW-RIGHT-BASE
    77 RIGHT-BASE-POS @ 5 0 DO 2DUP I + AT-XY ." |" LOOP 2DROP
;

: REDRAW-BASE ( x y delta -- )
    1 = IF
        2DUP
        AT-XY SPACE
        5 + AT-XY ." |"
    ELSE
        2DUP
        1 - AT-XY ." |"
        4 + AT-XY SPACE
    THEN
    
    0 0 AT-XY
;

: REDRAW-LEFT-BASE
    DUP
    2 LEFT-BASE-POS @ ROT REDRAW-BASE
    LEFT-BASE-POS @ + LEFT-BASE-POS !
;

: REDRAW-RIGHT-BASE
    DUP
    77 RIGHT-BASE-POS @ ROT REDRAW-BASE
    RIGHT-BASE-POS @ + RIGHT-BASE-POS !
;

: LEFT-BASE-DOWN
    LEFT-BASE-POS @ 18 <> IF 1 REDRAW-LEFT-BASE THEN
;

: LEFT-BASE-UP
    LEFT-BASE-POS @ 1 <> IF -1 REDRAW-LEFT-BASE THEN
;

: RIGHT-BASE-DOWN
    RIGHT-BASE-POS @ 18 <> IF 1 REDRAW-RIGHT-BASE THEN
;

: RIGHT-BASE-UP
    RIGHT-BASE-POS @ 1 <> IF -1 REDRAW-RIGHT-BASE THEN
;

: FLIP-HORISONTAL ( dir -- dir )
    BALL-DIRECTION @
    DUP 0 = IF
        2
    ELSE
        DUP 1 = IF
            3
        ELSE
            DUP 3 = IF
                1
            ELSE
                0
            THEN
        THEN
    THEN
    BALL-DIRECTION !
    DROP
;

: FLIP-VERTICAL ( dir -- dir)
    BALL-DIRECTION @
    DUP 0 = IF
        1
    ELSE
        DUP 1 = IF
            0
        ELSE
            DUP 2 = IF
                3
            ELSE
                2
            THEN
        THEN
    THEN
    BALL-DIRECTION !
    DROP
;

: REDRAW-BALL
    DUP
    BALL-X @ BALL-Y @ AT-XY SPACE
    BALL-X @ 1 ROT 1 AND IF + ELSE - THEN BALL-X !
    BALL-Y @ 1 ROT 2 AND IF + ELSE - THEN BALL-Y !
    BALL-X @ BALL-Y @ AT-XY ." O"
;

: LEFT-BASE-CATCH?
    BALL-Y @ LEFT-BASE-POS @ >=
    BALL-Y @ LEFT-BASE-POS @ 5 + <=
    AND
;

: RIGHT-BASE-CATCH?
    BALL-Y @ RIGHT-BASE-POS @ >=
    BALL-Y @ RIGHT-BASE-POS @ 5 + <=
    AND
;

: FIRST-PLAYER-FAIL
    FIRST-PLAYER-SCORE @ DUP
    1 + FIRST-PLAYER-SCORE !
    6 25 AT-XY .
;

: SECOND-PLAYER-FAIL
    SECOND-PLAYER-SCORE @ DUP
    1 + SECOND-PLAYER-SCORE !
    72 25 AT-XY .
;

: MOVE-BALL
    BALL-X @ 3 = IF
        LEFT-BASE-CATCH? IF
            FLIP-VERTICAL
        THEN
    THEN
    
    BALL-X @ 76 = IF
        RIGHT-BASE-CATCH? IF
            FLIP-VERTICAL
        THEN
    THEN

    BALL-X @ 1 = IF
        FIRST-PLAYER-FAIL
        FLIP-VERTICAL
    THEN
        
    BALL-X @ 78 = IF
        SECOND-PLAYER-FAIL
        FLIP-VERTICAL
    THEN
    
    BALL-Y @ DUP
    1 = SWAP 22 = OR IF
        FLIP-HORISONTAL
    THEN
    
    BALL-DIRECTION @ REDRAW-BALL
    
    0 0 AT-XY
;

: PROCESS-KEY
    DUP 113 ( Q ) = IF PAGE QUIT THEN
    DUP 119 ( W ) = IF LEFT-BASE-UP    THEN
    DUP 115 ( S ) = IF LEFT-BASE-DOWN  THEN
    DUP 111 ( O ) = IF RIGHT-BASE-UP   THEN
    DUP 108 ( L ) = IF RIGHT-BASE-DOWN THEN
;

: INIT-DRAW
    PAGE
    DRAW-BORDERS
    DRAW-LEFT-BASE
    DRAW-RIGHT-BASE
;

: START
    DEFAULT-VARIABLES
    INIT-DRAW
    BEGIN
        MOVE-BALL
        KEY? IF
            KEY PROCESS-KEY
        THEN
        KEY? IF
            KEY PROCESS-KEY
        THEN
        50 MS
    AGAIN
;

START