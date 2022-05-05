[top]
components : P1@pnPlace P2@pnPlace P3@pnPlace 
components : T1@pnTrans 

Link : out@P1		in3@T1
Link : fired@T1		in@P1
Link : out@P2		in2@T1
Link : fired@T1		in@P2
Link : out4@T1		in@P3

[P1]
tokens : 5

[P2]
tokens : 3
