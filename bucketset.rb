require File.expand_path(File.dirname(__FILE__) + '/peer')

def  distancemetric(peerA, peerB)
	ida = peerA.getid()
    idb = peerB.getid()
	
	return ida ^ idb
end


class BucketSet
	def initialize
		@@set  = Array.new  
	end	
	
	def getlength
		return @@set.length
	end
	
	def insert(peer)
		index = 0
		@@set.each do |x|
			if x.getid > peer.getid then
				@@set.insert(index, peer)
				break
			end	
		    index = index + 1
		end
	end

	def getbucket(peer, k = 8)
		
		if array.length <= k then
			return @@set
		end
		
		index = 0
		@@set.each do |x|
			if x.getid < peer.getid then
				index = index + 1	
			else
					break
			end	
		end
		return @@set[index, k]	

	end
end
