freeMemory()
{
	for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process")
	{
		try
		{
			hProcess := DllCall("OpenProcess", "uint", 0x001F0FFF, "int", 0, "uint", objItem.ProcessID, "ptr")
			DllCall("SetProcessWorkingSetSize", "ptr", hProcess, "uptr", -1, "uptr", -1)
			DllCall("psapi.dll\EmptyWorkingSet", "ptr", hProcess)
			DllCall("CloseHandle", "ptr", hProcess)
		}
	}
	return DllCall("psapi.dll\EmptyWorkingSet", "ptr", -1)
}
