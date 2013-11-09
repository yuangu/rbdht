require File.expand_path(File.dirname(__FILE__) + '/peer')

def  distancemetric(peerA, peerB)
	ida = peerA.getid()
    idb = peerB.getid()
	
	return ida ^ idb
end


class BucketSet
	def initialize
		@@set  = Hash.new  
	end	
	
	def getlength
		return @@set.size
	end
	
	def insert(id, peer)
             puts "insert " + id + "to bucketSet" 		
	     @@set[id.to_i] = peer
	end

	def hasKey(id)
	     return 	@@set.has_key?(id)
	end 
end
