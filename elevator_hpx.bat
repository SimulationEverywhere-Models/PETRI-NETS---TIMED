"C:\Program Files\Tcl\bin\wish80.exe" hpx2ma.tcl elevator.hpx elevator_hpx.ma 

simu -melevator_hpx.ma -lelevator_hpx.log -w10-3 -t00:30:00:000

"C:\Program Files\Tcl\bin\wish80.exe" pnmark.tcl elevator_hpx.ma elevator_hpx.log elevator_hpx.pn 

pause