[top]
components : P1@pnPlace P4@pnPlace P2@pnPlace P5@pnPlace P3@pnPlace P6@pnPlace 
components : T1@pnTrans T3@pnTrans T2@pnTrans T4@pnTrans 

Link : out@P1		in1@T1
Link : fired@T1		in@P1
Link : out1@T1		in@P2
Link : out@P2		in1@T2
Link : fired@T2		in@P2
Link : out@P4		in1@T3
Link : fired@T3		in@P4
Link : out@P5		in1@T4
Link : fired@T4		in@P5
Link : out1@T2		in@P1
Link : out1@T3		in@P3
Link : out@P3		in1@T1
Link : fired@T1		in@P3
Link : out1@T1		in@P5
Link : out1@T4		in@P6

[P1]
tokens : 1

[P4]
tokens : 10
