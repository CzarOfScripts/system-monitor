; http://msdn.com/library/ms724400(vs.85,en-us)
getCPULoad()
{
	static LIT := "", LKT := "", LUT := ""
	CIT := CKT := CUT := ""
	if !(DllCall("GetSystemTimes", "Int64*", CIT, "Int64*", CKT, "Int64*", CUT))
		return "*" A_LastError
	IDL := CIT - LIT, KER := CKT - LKT, USR := CUT - LUT, SYS := KER + USR
	return ((SYS - IDL) * 100 / SYS), LIT := CIT, LKT := CKT, LUT := CUT
}
