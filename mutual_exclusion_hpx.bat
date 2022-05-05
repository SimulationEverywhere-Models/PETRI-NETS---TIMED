"C:\Program Files\Tcl\bin\wish80.exe" hpx2ma.tcl mutual_exclusion.hpx mutual_exclusion_hpx.ma 

simu -mmutual_exclusion_hpx.ma -lmutual_exclusion_hpx.log -w10-3 -t00:30:00:000

"C:\Program Files\Tcl\bin\wish80.exe"pnmark.tcl mutual_exclusion_hpx.ma mutual_exclusion_hpx.log mutual_exclusion_hpx.pn 
