require File.expand_path(File.dirname(__FILE__) + '/peer'
require File.expand_path(File.dirname(__FILE__) + '/bucketset'
require 'socket'


class RBDht
	
	def initialize(host = "0.0.0.0", port = 9002, id = nil)
		BasicSocket.do_not_reverse_lookup = true
		@sock = UDPSocket.open
		sock.bind(host, port)
		if id != nil then
			@id = id.to_a.pack('H*')
		else
			@id = randId
		end
	end

	def bootstrap(host, port, target_id = "746385fe32b268d513d068f22c53c46d2eb34a5c" )
		 id = target_id.to_a.pack('H*')


	end


	def recv
		ready = IO.select([sock])
        readable = ready[0]
		readable.each do |sock|
		return @sock.recvfrom(1024)
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
