[top]
components : P1@pnPlace P2@pnPlace P3@pnPlace P4@pnPlace P5@pnPlace P6@pnPlace
components : T1@pnTrans T2@pnTrans T3@pnTrans T4@pnTrans T5@pnTrans   

Link : out@P1	in1@T1
Link : out@P1	in1@T3
Link : out@P2	in1@T5
Link : out@P3	in1@T2
Link : out@P4	in1@T1
Link : out@P5	in1@T4
Link : out@P6	in1@T3
Link : out1@T1	in@P3
Link : out1@T2	in@P2
Link : out1@T2	in@P4
Link : out1@T3	in@P5
Link : out1@T4	in@P2
Link : out1@T4	in@P6
Link : out1@T5	in@P1

Link : fired@T1	in@P1
Link : fired@T1	in@P4
Link : fired@T2	in@P3
Link : fired@T3	in@P1
Link : fired@T3	in@P6
Link : fired@T4	in@P5
Link : fired@T5	in@P2


[P1]
tokens : 5

[P2]
tokens : 5

[P4]
tokens : 1

[P6]
tokens : 1
