#Include ./library/Class/Object.ahk
#Include ./library/Class/JSON.ahk

class ConfigLoader
{
	__New(file, default := "")
	{
		this.file := file
		this.default := (!IsObject(default) && default ? {} : default)

		if (!FileExist(this.file))
		{
			this._fixfile()
		}

		this._loadfile()
		if (!isObject(this.data))
		{
			this._fixfile()
		}
	}

	_fixfile()
	{
		file := FileOpen(this.file, "w")
		file.write(JSON.stringify(IsObject(this.default) ? this.default : {}, "`t"))
		file.close()
		this._loadfile()
	}

	_loadfile()
	{
		data := JSON.Parse(fileopen(this.file, "r").read())
		this.data := Object.assign(this.default, data)

		if (JSON.stringify(data) != JSON.stringify(this.data))
		{
			this.save()
		}
	}

	save()
	{
		file := FileOpen(this.file, "w")
		file.write(JSON.stringify(this.data, "`t"))
		file.close()
	}
}
