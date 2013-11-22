class Bencode

	def initialize
		@ret = ""
	end

	public 
		def encode(x)
			 @ret = ""
			 encode_auto(x)
			 return @ret
		end
	private 
		def encode_auto(x)
			case x.class.to_s 
			   when "String"
				   encode_string(x)
			   when "Fixnum"
				   encode_int(x)
			   when "Hash"  
				   encode_dict(x)
			   when "Array" 
			           encode_list(x)
			   else
			end
		end

		def encode_int(x)
			@ret = @ret + "i" + x.to_s + "e"
		end

		def encode_bool(x)
   			if x then
				encode_int(1)
			else
				encode_int(0)
			end
		end
	
		def encode_string(x)
 			@ret = @ret + x.length.to_s + ":" + x
		end

		def encode_list(x)
			@ret = @ret + "l"
			x.each do |v|
				 encode_auto(v)
			end
		    @ret = @ret + "e"
		end
   

		def encode_dict(x)
			@ret = @ret + "d"
			x.each do |k,v|
				encode_string(k)
				encode_auto(v)	
			end
			@ret = @ret + "e"
		end

end

class Bdecode
	def decode(x)
		ret = nil
		 begin
			@pos = 0
			@x = x
			ret = decode_auto()
		rescue
			puts "error:#{$!} at:#{$@}"
		ensure
			return ret
		end	
	end


	def  decode_auto()
		if @x[@pos, 1] == "i" then
			return decode_int()
		elsif  @x[@pos, 1] == "l" then
			return 	decode_list()	
		elsif  @x[@pos, 1] == "d" then
			return decode_dict()					
		else 
			return decode_string()
		end			
	end	
		

	def decode_int()
			ret = 0
			len = 0
			if @x[@pos,1].eql?("i") then 	
				@pos = @pos + 1
				while not @x[@pos + len, 1].eql?("e") do
				     len = len + 1
				end
				ret =  Integer(@x[@pos, len])
				@pos = @pos + len + 1
			end				
		
			return ret
		end

		def decode_string()
=begin
			x = @x[@pos, @x.length - @pos]
    		len =  x.split(":")[0]
=end
			len = 0
			while len < (@x.length - @pos) and not @x[@pos + len, 1] == ":" do
				len = len + 1
			end
			if len == 0 then 
				@pos = @pos  + 1
				return ""
			else
				len = @x[@pos, len]
    			@pos = @pos + len.length + 1
				len = Integer(len)
				ret = @x[@pos, len]
				@pos = @pos + len
				return ret
			end
		
		end
	
		def decode_list()
			ret = Array.new 
			if @x[@pos, 1].eql?("l") then
				@pos = @pos + 1
				while not @x[@pos, 1].eql?("e") do
					ret << decode_auto()
				end
				@pos = @pos + 1			
			end			
			return ret 
		end
   

		def decode_dict()
			ret = Hash.new
			if @x[@pos, 1].eql?("d") then
				@pos = @pos + 1
				while not @x[@pos, 1].eql?("e") do
					k = decode_string()
					v =  decode_auto()
					ret[k] = v
				end			

			end
			@pos = @pos + 1
			return ret
			
		end
end


=begin

test =  Bencode.new
x = {"t"=>"aa", "y"=>"e", "e"=>[201,"A Generic Error Ocurred"]}
ret = test.encode(x)
puts ret


test2 =   Bdecode.new
ret = test2.decode(ret)
puts ret["e"]
=end
