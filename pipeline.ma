% This is the Petri Net model of an asynchronous 2 stage
% pipeline: Stage A and stage B.  It uses the following 
% places and transitions:
%
% P1 :	There is a job in the input queue
% P2 :	A is busy processing
% P3 :	Output register of A is full
% P4 :	Copying from output reg of A to input register of B
% P5 :	Output register of A is empty
% P6 :	Input register of B is empty
% P7 :	B is busy processing
% P8 :	Input register of B is full 
% P9 :	Output register of B is full
% P10 :	Copying from output reg of B to output queue
% P11 :	Output register of B is empty
% P12 : There is a job in the output queue
%
% T1 :	Generate a new job
% T2 :  Stage A starts processing job
% T3 :  Stage A job processing is complete
% T4 :	Start copying from output reg of A to input reg of B
% T5 :	Copying from output reg of A to input reg of B is complete
% T6 :	Stage B starts processing job	
% T7 :  Stage B job processing is complete
% T8 :	Start copying from output reg of B to output queue
% T9 :	Copying from output reg of B to output queue is complete
% T10 :	Job leaves the output queue
%
[top]
components : P1@pnPlace P2@pnPlace P3@pnPlace P4@pnPlace P5@pnPlace 
components : P6@pnPlace P7@pnPlace P8@pnPlace P9@pnPlace P10@pnPlace 
components : P11@pnPlace P12@pnPlace
components : T1@pnTrans T2@pnTrans T3@pnTrans T4@pnTrans T5@pnTrans
components : T6@pnTrans T7@pnTrans T8@pnTrans T9@pnTrans T10@pnTrans

% Definition of internal couplings
Link : out1@T1	in@P1
Link : out@P1	in0@T1
Link : out@P1	in1@T2
Link : out@P5	in1@T2
Link : out1@T2	in@P2
Link : out@P2	in1@T3
Link : out1@T3	in@P3
Link : out@P3	in1@T4
Link : out@P6	in1@T4
Link : out1@T4	in@P4
Link : out@P4	in1@T5
Link : out1@T5	in@P5
Link : out1@T5	in@P8
Link : out@P8	in1@T6
Link : out@P11	in1@T6
Link : out1@T6	in@P7
Link : out@P7	in1@T7
Link : out1@T7	in@P6
Link : out1@T7	in@P9
Link : out@P9	in1@T8
Link : out1@T8	in@P10
Link : out@P10	in1@T9
Link : out1@T9	in@P11
Link : out1@T9	in@P12
Link : out@P12	in1@T10
Link : out@P12	in0@T8

Link : fired@T2	in@P1
Link : fired@T2	in@P5
Link : fired@T3	in@P2
Link : fired@T4	in@P3
Link : fired@T4	in@P6
Link : fired@T5	in@P4
Link : fired@T6	in@P8
Link : fired@T6	in@P11
Link : fired@T7	in@P7
Link : fired@T8	in@P9
Link : fired@T9	in@P10
Link : fired@T10 in@P12

% Start with the input/output registers empty

[P5]
tokens : 1

[P6]
tokens : 1

[P11]
tokens : 1
