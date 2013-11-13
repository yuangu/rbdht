require 'ipaddr'
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
		size = 0
		@@mutex.synchronize do
			size = @@set.size
		end
		return size
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
		ishas = false
		@@mutex.synchronize do
	     	ishas = @@set.has_key?(id)
		end
		return ishas
	end 

	def getPeer(id)
		peer = nil 
		@@mutex.synchronize do
			peer = @@set[id]
		end
		return peer
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
	
	def getnodes(k=8)
		nodes = ""
		@@mutex.synchronize do
			@@set.each do |k, v|
				nodes = nodes +	k.to_a.pack('H*')
				info = v.getinfo
				ip_int = IPAddr.new(info['host']).to_i
				nodes = nodes + [ip_int].pack("i*")
				nodes = nodes + [info['port']].pack("s")
			end
		end
		return nodes
	end


end
