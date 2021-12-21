secondsToTime(seconds)
{
	days    := seconds // (3600 * 24)
	hours   := mod(seconds, 3600 * 24) // 3600
	minutes := mod(seconds, 3600) // 60
	seconds := mod(seconds, 60)

	return {days: days, hours: hours, minutes: minutes, seconds: seconds}
}
