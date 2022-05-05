"C:\Program Files\Tcl\bin\wish80.exe" hpx2ma.tcl pnTest3.hpx pnTest3_hpx.ma 
simu -mpnTest3_hpx.ma -lpnTest3_hpx.log -w10-3 -t00:30:00:000

"C:\Program Files\Tcl\bin\wish80.exe" pnmark.tcl pnTest3_hpx.ma pnTest3_hpx.log pnTest3_hpx.pn 
pause