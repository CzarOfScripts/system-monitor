; #NoTrayIcon
#Persistent
#SingleInstance FORCE
#MaxThreads
#MaxHotkeysPerInterval 200
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
#NoEnv
#Include ./library/Objects/objectMerge.ahk
#Include ./library/Objects/objectClone.ahk
#Include ./library/Class/JSON.ahk
#Include ./library/Class/ConfigLoader.ahk
#Include ./library/Class/NvAPI.ahk
#Include ./library/Memory/freeMemory.ahk
#Include ./library/Memory/globalMemoryStatusEx.ahk
#Include ./library/Memory/autoByteFormat.ahk
#Include ./library/Processor/getCPULoad.ahk
#Include ./library/Keyboard/getCurrentLangCode.ahk
#Include ./library/Keyboard/getLangNameByCode.ahk
#Include ./library/Others/secondsToTime.ahk

onExit("scriptClose")

global config

loadColorDefault := {}
loadColorDefault.GPU := {0: "9F9F9F", 40: "FFD700", 80: "DC4242"}
loadColorDefault.CPU := {0: "9F9F9F", 40: "FFD700", 80: "DC4242"}
loadColorDefault.MEM := {0: "9F9F9F", 40: "FFD700", 80: "DC4242"}

defaultConfig := {emptyMemory: true
				, allowMove: true
				, alwaysOnTop: true
				, hideTrayIcon: false
				, positionX: "center"
				, positionY: "center"
				, loadColor: loadColorDefault}

config := new ConfigLoader("config.json", defaultConfig)

if (config.data.hideTrayIcon)
{
	Menu, Tray, NoIcon
}

getCPULoad()

FormatTime, date,, % "MMM dd, ddd"
FormatTime, time,, % "hh:mm:ss tt"

gui, % "systemMonitor:-caption +ToolWindow +LastFound" (config.data.alwayOnTop ? "+AlwaysOnTop" : "")
gui, systemMonitor:Margin, 5, 5
gui, systemMonitor:Color, 090909, 252525

gui, systemMonitor:Font, s15 normal cDDDDDD, Consolas
gui, systemMonitor:add, text, x5 y7 vcontrol_lang, % "EN"

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (Lang)

gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, x+5 y5 cDC4242 vcontrol_dateAndTime, % date "`n" time

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (Time)

gui, systemMonitor:Font, s15 normal cDDDDDD, Consolas
gui, systemMonitor:add, text, x+4 y7, % "GPU"

gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, x+4 y5 +right cDDDDDD, % "Load:`nTemp:"
gui, systemMonitor:add, text, x+4 +right vcontrol_gpuLoad, % "Load"
gui, systemMonitor:add, text, xp y+0 +right vcontrol_gpuTemp, % "Load"

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (GPU)

gui, systemMonitor:Font, s10 Bold cDDDDDD, Consolas
gui, systemMonitor:add, text, x+7 y4 +center, % "CPU"
gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, xp-3 y+0 +center vcontrol_cpuLoad, % "Load"

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (CPU)

gui, systemMonitor:Font, s15 Bold cDDDDDD, Consolas
gui, systemMonitor:add, text, x+4 y7, % "MEM"

gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, x+4 y5 +right cDDDDDD, % "Used:`nFree:"
gui, systemMonitor:add, text, x+4 vcontrol_memUsed, % "Load "
gui, systemMonitor:add, text, xp y+0 +right vcontrol_memFree, % "Load..."

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (MEM)

gui, systemMonitor:Font, s10 Normal cDDDDDD, Consolas
gui, systemMonitor:add, text, x+4 y4 +center w50, % "Up Time"
gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, xp y+0 +center w50 vcontrol_upTime, % formatUpTime(secondsToTime(A_TickCount // 1000))

gui, systemMonitor:Show, % "NA x" config.data.positionX " y" config.data.positionY

updateCurrentLang()
updateMonitorInfo()

if (EmptyMemory)
{
	setTimer, emptyMemory, % 7 * 60 * 1000
}
setTimer, updateMonitorInfo, 850
setTimer, updateCurrentLang, 150
return



WM_LBUTTONDOWN()
{
	static init := OnMessage(0x201, "WM_LBUTTONDOWN")

	if (config.data.allowMove)
	{
		PostMessage, 0xA1, 2
	}
}

getLoadColor(load, type)
{
	for minLoad, color in config.data.loadColor[type]
	{
		if (load >= minLoad)
		{
			outColor := color
		}
	}

	return outColor
}

emptyMemory()
{
	freeMemory()

	Run, % "/Utilities/EmptyMemoryCache.exe",, HIDE
}

updateCurrentLang()
{
	static prevLangCode := ""

	if (prevLangCode != (curLangCode := getCurrentLangCode()))
	{
		prevLangCode := curLangCode
		GuiControl, systemMonitor:, control_lang, % getLangNameByCode(curLangCode)
	}
}

updateMonitorInfo()
{
	; GPU INFO
	gpuInfo := getGpuInfo() ; {temp, load, memory {total, avail, use, load}}

	GuiControl, % "systemMonitor:+c" getLoadColor(gpuInfo.load, "GPU") " +Redraw", control_gpuLoad
	GuiControl, systemMonitor:, control_gpuLoad, % gpuInfo.load " %"
	GuiControl, systemMonitor:, control_gpuTemp, % gpuInfo.temp "°C"

	; CPU INFO
	cpuLoad := Round(getCPULoad())

	GuiControl, % "systemMonitor:+c" getLoadColor(cpuLoad, "CPU") " +Redraw", control_cpuLoad
	GuiControl, systemMonitor:, control_cpuLoad, % (cpuLoad ? cpuLoad "%" : "Load")

	; Memory INFO
	memoryInfo := globalMemoryStatusEx() ; {avail, total, load}

	GuiControl, % "systemMonitor:+c" getLoadColor(memoryInfo.load, "MEM") " +Redraw", control_memUsed
	GuiControl, systemMonitor:, control_memUsed, % memoryInfo.load " %"
	GuiControl, systemMonitor:, control_memFree, % autoByteFormat(memoryInfo.avail)

	; Uptime
	upTimeData     := secondsToTime(A_TickCount // 1000) ; {days, hours, minutes, seconds}
	upTimeFormated := formatUpTime(upTimeData)

	GuiControl, systemMonitor:, control_upTime, % upTimeFormated

	; Date and Time
	FormatTime, date,, % "MMM dd, ddd"
	FormatTime, time,, % "hh:mm:ss tt"

	GuiControl, systemMonitor:, control_dateAndTime, % date "`n" time
}

formatUpTime(upTimeData)
{
	if (upTimeData.days)
	{
		output := upTimeData.days "d " format("{:02}", upTimeData.hours) "h"
	}
	else if (upTimeData.hours)
	{
		output := format("{:02}", upTimeData.hours) "h " format("{:02}", upTimeData.minutes) "m"
	}
	else
	{
		output := format("{:02}", upTimeData.minutes) "m " format("{:02}", upTimeData.seconds) "s"
	}

	return output
}

getGpuInfo()
{
	gpuInfo      := {}
	gpuInfo.temp := NvAPI.GPU_GetThermalSettings()[1].currentTemp
	gpuInfo.load := NvAPI.GPU_GetDynamicPstatesInfoEx().GPU.percentage

	memoryInfo := NvAPI.GPU_GetMemoryInfo()

	gpuInfo.memory       := {}
	gpuInfo.memory.total := memoryInfo.dedicatedVideoMemory * 1024
	gpuInfo.memory.avail := memoryInfo.curAvailableDedicatedVideoMemory * 1024
	gpuInfo.memory.use   := gpuInfo.memory.total - gpuInfo.memory.avail
	gpuInfo.memory.load  := round(gpuInfo.memory.use / gpuInfo.memory.total * 100)

	return gpuInfo
}

scriptClose()
{
	Gui, systemMonitor:+LastFound

	WinGetPos, x, y
	config.data.positionX := x
	config.data.positionY := y

	config.save()

	exitApp
}
