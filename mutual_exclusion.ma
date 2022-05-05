% This is the Petri Net model of a typical software mutual 
% exclusion problem.  It uses the following places and 
% transitions:
% P1 :	Process 1 is running in its non-critical section
% P2 :	Process 2 is running in its non-critical section
% P3 :	Process 1 is running in its critical section
% P4 :	Process 2 is running in its critical section
% P5 :  Mutex semaphore status:
%		0 : semaphore is not available
%		1 : semaphore is available
% T1 :	Process 1 enters the critical section
% T2 :	Process 2 enters the critical section
% T3 :	Process 1 exits the critical section
% T4 :	Process 2 exits the critical section
%
[top]
components : P1@pnPlace P2@pnPlace P3@pnPlace P4@pnPlace P5@pnPlace 
components : T1@pnTrans T2@pnTrans T3@pnTrans T4@pnTrans  

% Definition of internal couplings
Link : out@P1	in1@T1
Link : out1@T1	in@P3
Link : out@P3	in1@T3
Link : out1@T3	in@P1
Link : out@P2	in1@T2
Link : out1@T2	in@P4
Link : out@P4	in1@T4
Link : out1@T4	in@P2
Link : out@P5	in1@T1
Link : out@P5	in1@T2
Link : out1@T3	in@P5
Link : out1@T4	in@P5

Link : fired@T1	in@P1
Link : fired@T1	in@P5
Link : fired@T2	in@P2
Link : fired@T2	in@P5
Link : fired@T3	in@P3
Link : fired@T4	in@P4

[P1]
% Start with process 1 in its non-critical section
tokens : 1

[P2]
% Start with process 2 in its non-critical section
tokens : 1

[P5]
% Start with the semaphore available
tokens : 1

