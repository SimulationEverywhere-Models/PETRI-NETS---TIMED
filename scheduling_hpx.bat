"C:\Program Files\Tcl\bin\wish80.exe" hpx2ma.tcl scheduling.hpx scheduling_hpx.ma 

simu -mscheduling_hpx.ma -lscheduling_hpx.log -w10-3 -t00:30:00:000

"C:\Program Files\Tcl\bin\wish80.exe" pnmark.tcl scheduling_hpx.ma scheduling_hpx.log scheduling_hpx.pn 
