def get_version
	return "rbdht\x00\x01"
end

def get_token
	return "rbdht"
end

def toHexStr(hex)
     return hex.to_a.pack("H*")	
end


