objectMerge(target, sources*)
{
	target := objectClone(target)

	for i, arr in sources
	{
		for key, value in arr
		{
			target[key] := (IsObject(value) && !value.base.IsArray) ? ObjectMerge(value, target[key]) : value
		}
	}

	return target
}
