getCurrentLangCode()
{
	WinGet, WinID,, A
	ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")

	if (!InputLocaleID)
	{
		WinActivate, ahk_class WorkerW
		WinGet, WinID2,, ahk_class WorkerW
		ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinID2, "UInt", 0)
		WinActivate, ahk_id %WinID%
		InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
	}

	return InputLocaleID
}
