class Object
{
	assign(target, sources*)
	{
		target := Object.clone(target)

		for i, arr in sources
		{
			for key, value in arr
			{
				target[key] := (IsObject(value) && !value.base.IsArray) ? this.clone(value, target[key]) : value
			}
		}

		return target
	}

	clone(obj)
	{
		cloned := obj.clone()

		for i, key in obj
		{
			if IsObject(key)
			{
				cloned[i] := this.clone(key)
			}
		}

		return cloned
	}
}
