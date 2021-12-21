; https://msdn.microsoft.com/en-us/library/aa366589(v=vs.85).aspx
globalMemoryStatusEx()
{
	static MSEX, init := NumPut(VarSetCapacity(MSEX, 64, 0), MSEX, "uint")

	if !(DllCall("GlobalMemoryStatusEx", "ptr", &MSEX))
		throw Exception("Call to GlobalMemoryStatusEx failed: " A_LastError, -1)

	memoryInfo       := {}
	memoryInfo.load  := NumGet(MSEX, 4, "uint")
	memoryInfo.total := NumGet(MSEX, 8, "uint64")
	memoryInfo.avail := NumGet(MSEX, 16, "uint64")
	memoryInfo.use   := memoryInfo.total - memoryInfo.avail

	return memoryInfo
}
