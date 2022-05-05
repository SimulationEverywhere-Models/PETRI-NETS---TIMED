[top]
components : P1@pnPlace P2@pnPlace P3@pnPlace P4@pnPlace T1@pnTrans T2@pnTrans

% Definition of internal couplings
Link : out@P1	in1@T1
Link : out@P2	in1@T1
Link : out@P2	in1@T2
Link : out@P3	in1@T2
Link : out1@T1	in@P4
Link : out1@T2	in@P4
Link : out1@T2	in@P1
Link : fired@T1	in@P1
Link : fired@T1	in@P2
Link : fired@T2	in@P2
Link : fired@T2	in@P3

[P2]
tokens : 10

[P3]
tokens : 5
