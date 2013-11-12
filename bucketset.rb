require File.expand_path(File.dirname(__FILE__) + '/peer')


class BucketSet
	def initialize
		@@set    = Hash.new 
	    @@mutex  = Mutex.new
		@info = {
			"bad"  => 0,
			"good" => 0,
		}
	end	
	
	def getlength
		@@mutex.synchronize do
			return @@set.size
		end
	end
	
	def insert(id, peer)
		@@mutex.synchronize do
        	 puts "insert " + id + " to bucketSet" 		
	    	 @@set[id] = peer
		end
	end
	
	def delete(id)
		@@mutex.synchronize do
			puts "delect" + id + " at bucketSet"
			@@set.delete(id)
		end
	end

	def hasKey(id)
		@@mutex.synchronize do
	     	return @@set.has_key?(id)
		end
	end 

	def getPeer(id)
		@@mutex.synchronize do
			return @@set[id]
		end
	end
	
	def update(sock, id)
		goodnum = 0
		badnum = 0
		@@mutex.synchronize do
			@@set.each do |k,v|
				if  v.isbad then badnum = badnum + 1 else goodnum = goodnum + 1 end
			end
		end
		@info['bad'] = badnum
		@info['good'] = goodnum
	end

	def getinfo
		return @info
	end


end
