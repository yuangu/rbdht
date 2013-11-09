require File.expand_path(File.dirname(__FILE__) + '/peer')
require File.expand_path(File.dirname(__FILE__) + '/bucketset')
require "socket"


class RBDht
public	
	def initialize(host = "0.0.0.0", port = 9002, id = nil)
		BasicSocket.do_not_reverse_lookup = true
		@sock = UDPSocket.open
		@sock.bind(host, port)
		if id != nil then
			@id = id.to_a.pack('H*')
		else
			@id = randId
		end
		@bucketset = BucketSet.new
	end

	def bootstrap(host, port, target_id = "746385fe32b268d513d068f22c53c46d2eb34a5c" )
		 id = target_id.to_a.pack('H*')
		 peer = Peer.new(host, port)
		 peer.find_node(@sock, id, @id)
	end

private
	def repsondHandle(ret)
		puts ("repsond")
	end
	
	def erroHandle(ret)
		puts ("erro")

	end

	def requestHanel(ret)
		puts ("request")


	end


	def handle(data)
	     ret = Bdecode.new.decode(data[0])
	     case ret["y"]
	        when "r" : repsondHandle(ret)
		when "e":  erroHandle(ret)
		when "q":  requestHanel(ret)
		
		



	     end

	end
public
	def recv
		while true
			ready = IO.select([@sock])
        		readable = ready[0]
			readable.each do |sock|
		  	    data = sock.recvfrom(1024)
			    handle(data)
                        end
		end
	end
	

	
	def randId
		arr = []
		20.times do
			|i|			
			arr[i] = rand(0xFF) 
		end
          	return arr.pack("C*")
	end

end 
