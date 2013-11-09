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
         puts "insert " + id + " to bucketSet" 		
	     @@set[id] = peer
	end
	
	def delete(id)
		puts "delect" + id + " at bucketSet"
		@@set.delete(id)
	end

	def hasKey(id)
	     return 	@@set.has_key?(id)
	end 

	def getPeer(id)
			return @@set[id]
	end
	
	def update(sock, id)
		@@set.each do |k,v|
			if v.isUpdate then
				delete(k)				
			else
				v.ping(sock, id)
			end
		end

	end

end
