def get_version
	return "rbdht\x00\x01"
end

def get_token
	return "rbdht"
end

#二进制序列转换成字符形式
def hexToStr(hex)
     return hex.unpack("H*")[0]
end

def strToHex(str)
    return [str].pack("H*")

end



p strToHex "1989"

