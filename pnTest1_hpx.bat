"C:\Program Files\Tcl\bin\wish80.exe" hpx2ma.tcl pnTest1.hpx pnTest1_hpx.ma 
simu -mpnTest1_hpx.ma -lpnTest1_hpx.log -w10-3 -t00:10:00:000

"C:\Program Files\Tcl\bin\wish80.exe" pnmark.tcl pnTest1_hpx.ma pnTest1_hpx.log pnTest1_hpx.pn 
pause