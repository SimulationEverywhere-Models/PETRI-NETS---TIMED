"C:\Program Files\Tcl\bin\wish80.exe" hpx2ma.tcl pnTest2.hpx pnTest2_hpx.ma 

simu -mpnTest2_hpx.ma -lpnTest2_hpx.log -w10-3 -t00:30:00:000

"C:\Program Files\Tcl\bin\wish80.exe" pnmark.tcl pnTest2_hpx.ma pnTest2_hpx.log pnTest2_hpx.pn
pause