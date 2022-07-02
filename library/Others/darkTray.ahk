darkTray()
{
	static init := darkTray()

	try
	{
		uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
		SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
		FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
		DllCall(SetPreferredAppMode, "int", 1)
		DllCall(FlushMenuThemes)
	}
}
