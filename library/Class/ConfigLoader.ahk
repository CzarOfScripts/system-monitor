class ConfigLoader
{
	__New(file, default := "")
	{
		this.file := file
		if (!IsObject(default) && default)
		{
			default := {}
		}

		this.default := default

		if (!FileExist(this.file))
		{
			this._fixfile()
		}

		this._loadfile()
		if (!isObject(this.data))
		{
			this.fixfile()
		}
	}

	_fixfile()
	{
		file := FileOpen(this.file, "w")
		file.write(JSON.Stringify(IsObject(this.default) ? this.default : {}, "`t"))
		file.close()
		this._loadfile()
	}

	_loadfile()
	{
		data := JSON.Parse(fileopen(this.file, "r").read())
		this.data := this.default ? objectMerge(this.default, data) : data
	}

	save()
	{
		file := FileOpen(this.file, "w")
		file.write(JSON.Stringify(this.data, "`t"))
		file.close()
	}
}
