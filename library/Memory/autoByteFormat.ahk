autoByteFormat(size, decimalPlaces := 2)
{
	static sizeTable    := ["byte", "KB", "MB", "GB", "TB"]
	static sizeTableLen := sizeTable.maxIndex()

	sizeIndex := 1

	while (size >= 1024 && sizeIndex < sizeTableLen)
	{
		sizeIndex += 1
		size /= 1024.0
	}

	return round(size, (sizeIndex == 1 ? 0 : decimalPlaces)) " " sizeTable[sizeIndex] (sizeIndex == 1 && size != 1 ? "s" : "")
}
