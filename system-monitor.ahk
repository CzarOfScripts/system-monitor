; #NoTrayIcon
#Persistent
#SingleInstance FORCE
#MaxThreads
#MaxHotkeysPerInterval 200
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
#NoEnv

;* Includes
#Include ./library/Others/darkTray.ahk
#Include ./library/Class/ConfigLoader.ahk
#Include ./library/Class/NvAPI.ahk
#Include ./library/Memory/freeMemory.ahk
#Include ./library/Memory/globalMemoryStatusEx.ahk
#Include ./library/Memory/autoByteFormat.ahk
#Include ./library/Processor/getCPULoad.ahk
#Include ./library/Keyboard/getCurrentLangCode.ahk
#Include ./library/Keyboard/getLangNameByCode.ahk
#Include ./library/Others/secondsToTime.ahk
#Include ./library/Gui/guiControlSetText.ahk


;* Menu Tray
menu, tray, NoStandard

menu, tray, icon, shell32.dll, 22

menu, contacts, Add , % "Czar Of Scripts | My site"            , authorSite
menu, contacts, Add , % "Czar Of Scripts | I'm in VK"          , authorVK
menu, contacts, Add , % "Czar Of Scripts | I'm on Cheat-Master", authorCM
menu, contacts, Icon, % "Czar Of Scripts | My site"            , shell32.dll, 264
menu, contacts, Icon, % "Czar Of Scripts | I'm in VK"          , shell32.dll, 264
menu, contacts, Icon, % "Czar Of Scripts | I'm on Cheat-Master", shell32.dll, 264

menu, tray, tip, % "System Monitor"
menu, tray, add    , % "Empty memory (Standby)", selectSettingsItem
menu, tray, add    , % "Allow move"    , selectSettingsItem
menu, tray, add    , % "Always On Top" , selectSettingsItem
menu, tray, add    , % "Hide tray icon", selectSettingsItem
menu, tray, add
menu, tray, Add    , % "Contacts"      , :Contacts
menu, tray, Icon   , % "Contacts"      , shell32.dll, 161
menu, tray, add
menu, tray, Add    , % "Close script"  , closeScript
menu, tray, Icon   , % "Close script"  , shell32.dll, 132
menu, tray, Default, % "Close script"



onExit("closeScript")

global config
global hGuiSystemMonitor

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


menu, tray, % (config.data.emptyMemory  ? "check" : "uncheck"), % "Empty memory (Standby)"
menu, tray, % (config.data.allowMove    ? "check" : "uncheck"), % "Allow move"
menu, tray, % (config.data.alwaysOnTop  ? "check" : "uncheck"), % "Always On Top"
menu, tray, % (config.data.hideTrayIcon ? "check" : "uncheck"), % "Hide tray icon"


if (config.data.hideTrayIcon)
{
	menu, tray, NoIcon
}

getCPULoad()

FormatTime, date,, % "MMM dd, ddd"
FormatTime, time,, % "hh:mm:ss tt"

gui, % "systemMonitor:-caption +ToolWindow hwndhGuiSystemMonitor +LastFound" (config.data.alwayOnTop ? "+AlwaysOnTop" : "")
gui, systemMonitor:Margin, 5, 5
gui, systemMonitor:Color, 090909, 252525

gui, systemMonitor:Font, s15 normal cDDDDDD, Consolas
gui, systemMonitor:add, text, x5 y7 vcontrol_lang, % "EN"

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (Lang)

gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, x+5 y5 w80 +center cDC4242 vcontrol_dateAndTime, % date "`n" time

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (Time)

gui, systemMonitor:Font, s15 normal cDDDDDD, Consolas
gui, systemMonitor:add, text, x+4 y7, % "GPU"

gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, x+4 y5 +right cDDDDDD, % "Load:`nTemp:"
gui, systemMonitor:add, text, x+4    w35 +right vcontrol_gpuLoad
gui, systemMonitor:add, text, xp y+0 w35 +right vcontrol_gpuTemp

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (GPU)

gui, systemMonitor:Font, s10 Bold cDDDDDD, Consolas
gui, systemMonitor:add, text, y4 w35 +center, % "CPU"
gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, y+0 w35 +center vcontrol_cpuLoad

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (CPU)

gui, systemMonitor:Font, s15 Bold cDDDDDD, Consolas
gui, systemMonitor:add, text, x+4 y7, % "MEM"

gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, x+4 y5 +right cDDDDDD, % "Used:`nFree:"
gui, systemMonitor:add, text, x+4    w60 +center vcontrol_memUsed
gui, systemMonitor:add, text, xp y+0 w60 +center vcontrol_memFree

gui, systemMonitor:add, text, x+5 y6 0x7 h26 w2 ; Delimeter (MEM)

gui, systemMonitor:Font, s10 Normal cDDDDDD, Consolas
gui, systemMonitor:add, text, x+4 y4 +center w50, % "Up Time"
gui, systemMonitor:Font, s9 Bold c9F9F9F, Consolas
gui, systemMonitor:add, text, xp y+0 +center w50 vcontrol_upTime

updateCurrentLang()
updateTimeMonitorInfo()
updateDataMonitorInfo()

gui, systemMonitor:Show, % "NA x" config.data.positionX " y" config.data.positionY

if (config.data.emptyMemory)
{
	setTimer, emptyMemory, % 7 * 60 * 1000
}
SetTimer, updateTimeMonitorInfo, 50
setTimer, updateDataMonitorInfo, 850
setTimer, updateCurrentLang, 150
return


selectSettingsItem(itemName)
{
	switch (itemName)
	{
		case "Empty memory (Standby)":
		{
			config.data.emptyMemory := !config.data.emptyMemory
			config.save()

			menu, tray, % (config.data.emptyMemory ? "check" : "uncheck"), % itemName
			setTimer, emptyMemory, % (config.data.emptyMemory ? 7 * 60 * 1000 : "off")
		}
		case "Allow move":
		{
			config.data.allowMove := !config.data.allowMove
			config.save()

			menu, tray, % (config.data.allowMove ? "check" : "uncheck"), % itemName
		}
		case "Always On Top":
		{
			config.data.alwaysOnTop := !config.data.alwaysOnTop
			config.save()

			menu, tray, % (config.data.alwaysOnTop ? "check" : "uncheck"), % itemName
			gui, % "systemMonitor:" (config.data.alwaysOnTop ? "+" : "-") "AlwaysOnTop"
		}
		case "Hide tray icon":
		{
			config.data.hideTrayIcon := !config.data.hideTrayIcon
			config.save()

			menu, tray, % (config.data.hideTrayIcon ? "check" : "uncheck"), % itemName
			menu, tray, % (config.data.hideTrayIcon ? "NoIcon" : "Icon")
		}
	}
}

WM_MOVING(wParam, lParam, msg, hwnd)
{
	static init := OnMessage(0x0216, "WM_MOVING")

	pos := {left: NumGet(lParam + 0, "Int"), top: NumGet(lParam + 4, "Int"), right: NumGet(lParam + 8, "Int"), bottom: NumGet(lParam + 12, "Int")}

	if (hwnd == hGuiSystemMonitor && config.data.allowMove)
	{
		config.data.positionX := pos.left
		config.data.positionY := pos.top

		config.save()
	}
}

WM_RBUTTONDOWN()
{
	static init := OnMessage(0x0204, "WM_RBUTTONDOWN")

	menu, tray, show
}

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
		langName := getLangNameByCode(curLangCode)
		guiControlSetText("systemMonitor:", "control_lang", langName)
		prevLangCode := curLangCode
	}
}

updateTimeMonitorInfo()
{
	; Uptime
	upTimeData     := secondsToTime(A_TickCount // 1000) ; {days, hours, minutes, seconds}
	upTimeFormatted := formatUpTime(upTimeData)

	guiControlSetText("systemMonitor:", "control_upTime", upTimeFormatted)

	; Date and Time
	FormatTime, date,, % "MMM dd, ddd"
	FormatTime, time,, % "hh:mm:ss tt"

	guiControlSetText("systemMonitor:", "control_dateAndTime", date "`n" time)
}

updateDataMonitorInfo()
{
	; GPU INFO
	gpuInfo := getGpuInfo() ; {temp, load, memory {total, avail, use, load}}

	GuiControl, % "systemMonitor:+c" getLoadColor(gpuInfo.load, "GPU") " +Redraw", control_gpuLoad
	guiControlSetText("systemMonitor:", "control_gpuLoad", gpuInfo.load (gpuInfo.load == 100 ? "" : A_Space) "%")
	guiControlSetText("systemMonitor:", "control_gpuTemp", gpuInfo.temp "°C")

	; CPU INFO
	cpuLoad := getCPULoad()

	GuiControl, % "systemMonitor:+c" getLoadColor(cpuLoad, "CPU") " +Redraw", control_cpuLoad
	guiControlSetText("systemMonitor:", "control_cpuLoad", (cpuLoad != "" ? Round(cpuLoad, (cpuLoad < 10)) "%" : "Load"))

	; Memory INFO
	memoryInfo := globalMemoryStatusEx() ; {avail, total, load}

	GuiControl, % "systemMonitor:+c" getLoadColor(memoryInfo.load, "MEM") " +Redraw", control_memUsed
	guiControlSetText("systemMonitor:", "control_memUsed", round(memoryInfo.load, 2) " %")
	guiControlSetText("systemMonitor:", "control_memFree", autoByteFormat(memoryInfo.avail))
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



authorSite()
{
	run, % "https://CzarOfScripts.com"
}

authorVK()
{
	run, % "https://vk.com/id173241815"
}

authorCM()
{
	run, % "https://cheat-master.ru/index/8-459193"
}

closeScript(exitReason, exitCode)
{
	exitApp
}
