guiControlSetText(subCommand, controlID, text)
{
	guiControlGet, ctrlText, % subCommand, % controlID, text

	if (ctrlText != text)
	{
		guiControl, % subCommand, % controlID, % text
	}
}
