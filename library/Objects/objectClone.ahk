objectClone(obj)
{
	cloned := obj.clone()
	for i, key in obj
	{
		if IsObject(key)
		{
			cloned[i] := objectClone(key)
		}
	}
	return cloned
}
