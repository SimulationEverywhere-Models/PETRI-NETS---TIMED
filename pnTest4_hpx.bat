"C:\Program Files\Tcl\bin\wish80.exe" hpx2ma.tcl pnTest4.hpx pnTest4_hpx.ma 

simu -mpnTest4_hpx.ma -lpnTest4_hpx.log -w10-3 -t00:10:00:000

"C:\Program Files\Tcl\bin\wish80.exe" pnmark.tcl pnTest4_hpx.ma pnTest4_hpx.log pnTest4_hpx.pn 
pause