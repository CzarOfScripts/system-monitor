class JSON
{
	Parse(jsonStr)
	{
		SC := ComObjCreate("ScriptControl")
		SC.Language := "JScript"
		ComObjError(false)

		jsCode =
		(
		function arrangeForAhkTraversing(obj){
			if(obj instanceof Array){
				for(var i=0 ; i<obj.length ; ++i)
					obj[i] = arrangeForAhkTraversing(obj[i]) ;
				return ['array',obj] ;
			}else if(obj instanceof Object){
				var keys = [], values = [] ;
				for(var key in obj){
					keys.push(key) ;
					values.push(arrangeForAhkTraversing(obj[key])) ;
				}
				return ['object',[keys,values]] ;
			}else
				return [typeof obj,obj] ;
		}
		)

		SC.ExecuteStatement(jsCode "; obj=" jsonStr)
		return this.convertJScriptObjToAhks( SC.Eval("arrangeForAhkTraversing(obj)") )
	}

	convertJScriptObjToAhks(jsObj)
	{
		if (jsObj[0]="object")
		{
			obj := {}, keys := jsObj[1][0], values := jsObj[1][1]
			loop % keys.length
				obj[keys[A_INDEX-1]] := this.convertJScriptObjToAhks( values[A_INDEX-1] )
			return obj
		}
		else if (jsObj[0]="array")
		{
			array := []
			loop % jsObj[1].length
				array.insert(this.convertJScriptObjToAhks( jsObj[1][A_INDEX-1] ))
			return array
		}
		else
			return jsObj[1]
	}

	Stringify(value, space := 0, _indent := 1)
	{
		_space := space
		if (space ~= "^\d+$")
		{
			_space := this.strRepeat(A_Space, space)
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
				str .= this.strRepeat(_space, indent)
			}

			str .= (array ? "" : """" a """: ")

			if (IsObject(b))
			{
				if (space)
				{
					str := RTrim(str, " ") "`n" this.strRepeat(_space, indent)
				}

				str .= this.Stringify(b, space, indent + 1)
			}
			else
			{
				str .= """" StrReplace(b, """", "\""") """"
			}

			str .= "," (space ? "`n" : " ")
		}
		str := RTrim(str, " ,`n")
		str := RegExReplace(str, "`n([\s]+)?`n", "`n")

		indent--
		out := (array ? "[" : "{") (space ? "`n" : "") str (space ? "`n" : "")
		out .= (space ? this.strRepeat(_space, indent) : "") (array ? "]" : "}")
		return RegExReplace(out, "^(\h*(\R|$))+|\R\h*(?=\R|$)")
	}

	strRepeat(str, count)
	{
		return StrReplace(Format("{:" count "}", ""), " ", str)
	}
}
