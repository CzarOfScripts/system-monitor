class JSON
{
	parse(jsonStr)
	{
		SC := ComObjCreate("ScriptControl")
		SC.Language := "JScript"
		ComObjError(false)

		jsCode := "function arrangeForAhkTraversing(r){if(r instanceof Array){for(var a=0;a<r.length;++a)r[a]=arrangeForAhkTraversing(r[a]);return['array',r]}if(r instanceof Object){var n=[],e=[];for(var o in r)n.push(o),e.push(arrangeForAhkTraversing(r[o]));return['object',[n,e]]}return[typeof r,r]}"

		SC.ExecuteStatement(jsCode "; obj=" jsonStr)
		return this._convertJScriptObjToAhks( SC.Eval("arrangeForAhkTraversing(obj)") )
	}

	; _unicodeHexToString(string)
	; {
	; 	static letters := {"\u00ab": "«", "\u00bb": "»", "\u2116": "?", "\u0410": "?", "\u0430": "?", "\u0411": "?", "\u0431": "?", "\u0412": "?", "\u0432": "?", "\u0413": "?", "\u0433": "?", "\u0414": "?", "\u0434": "?", "\u0415": "?", "\u0435": "?", "\u0401": "?", "\u0451": "?", "\u0416": "?", "\u0436": "?", "\u0417": "?", "\u0437": "?", "\u0418": "?", "\u0438": "?", "\u0419": "?", "\u0439": "?", "\u041a": "?", "\u043a": "?", "\u041b": "?", "\u043b": "?", "\u041c": "?", "\u043c": "?", "\u041d": "?", "\u043d": "?", "\u041e": "?", "\u043e": "?", "\u041f": "?", "\u043f": "?", "\u0420": "?", "\u0440": "?", "\u0421": "?", "\u0441": "?", "\u0422": "?", "\u0442": "?", "\u0423": "?", "\u0443": "?", "\u0424": "?", "\u0444": "?", "\u0425": "?", "\u0445": "?", "\u0426": "?", "\u0446": "?", "\u0427": "?", "\u0447": "?", "\u0428": "?", "\u0448": "?", "\u0429": "?", "\u0449": "?", "\u042a": "?", "\u044a": "?", "\u042b": "?", "\u044b": "?", "\u042c": "?", "\u044c": "?", "\u042d": "?", "\u044d": "?", "\u042e": "?", "\u044e": "?", "\u042f": "?", "\u044f": "?", "\u0490": "?", "\u0491": "?", "\u0404": "?", "\u0454": "?", "\u0406": "?", "\u0456": "?", "\u0407": "?", "\u0457": "?"}

	; 	for unicode, letter in letters
	; 	{
	; 		string := RegExReplace(string, "\Q" unicode "\E", letter)
	; 	}

	; 	return string
	; }

	stringify(value, space := 0, _indent := 1)
	{
		_space := space
		if (space ~= "^\d+$")
		{
			_space := this._strRepeat(A_Space, space)
		}

		str := ""
		array := true
		for k in value
		{
			if (k == A_Index)
			{
				continue
			}

			array := false
			break
		}

		indent := _indent
		for a, b in value
		{
			if (space)
			{
				str .= this._strRepeat(_space, indent)
			}

			str .= (array ? "" : """" a """: ")

			if (IsObject(b))
			{
				if (space)
				{
					str := RTrim(str, " ") "`n" this._strRepeat(_space, indent)
				}

				str .= this.stringify(b, space, indent + 1)
			}
			else
			{
				str .= (b ~= "^\d+$" ? b : """" strReplace(strReplace(b, "\", "\\"), """", "\""") """")
			}

			str .= "," (space ? "`n" : " ")
		}
		str := RTrim(str, " ,`n")
		str := regExReplace(str, "`n([\s]+)?`n", "`n")

		indent--
		out := (array ? "[" : "{") (str ? (space ? "`n" : "") str (space ? "`n" : "") (space ? this._strRepeat(_space, indent) : "")  : "") (array ? "]" : "}")

		out := regExReplace(out, "^(\h*(\R|$))+|\R\h*(?=\R|$)")
		out := regExReplace(out, ":\n\s{1,}\[\]", ": []")
		out := regExReplace(out, ":\n\s{1,}\{\}", ": {}")

		return out
	}

	_convertJScriptObjToAhks(jsObj)
	{
		if (jsObj[0] == "object")
		{
			obj := {}, keys := jsObj[1][0], values := jsObj[1][1]
			loop % keys.length
				obj[keys[A_INDEX-1]] := this._convertJScriptObjToAhks( values[A_INDEX-1] )
			return obj
		}
		else if (jsObj[0] == "array")
		{
			array := []
			loop % jsObj[1].length
				array.insert(this._convertJScriptObjToAhks( jsObj[1][A_INDEX-1] ))
			return array
		}
		else
			return jsObj[1]
	}

	_strRepeat(str, count)
	{
		return strReplace(Format("{:" count "}", ""), " ", str)
	}
}
