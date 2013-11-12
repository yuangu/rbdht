require File.expand_path(File.dirname(__FILE__) + '/peer')
require File.expand_path(File.dirname(__FILE__) + '/bucketset')
require "socket"
require 'ipaddr'


class RBDht
public	
	def initialize(host = "0.0.0.0", port = 9002, id = nil)
		BasicSocket.do_not_reverse_lookup = true
		@@lock  = Mutex.new
		@@sock = UDPSocket.open
		@@sock.bind(host, port)
	
		if id != nil then
			@id = id.to_a.pack('H*')
		else
			@id = randId
		end
		@@bucketset = BucketSet.new
	end

	def bootstrap(host, port, id = "bootstrap", target_id = nil )
	
		 if target_id == nil then
			target_id = @id
		 else
			target_id = target_id.to_a.pack('H*')
		 end

		 peer = Peer.new(host, port)
		 if id != "bootstrap" then
		 	@@bucketset.insert(id, peer)
	     end		 

		 peer.find_node(@@sock, target_id, @id, @@lock,  "bootstrap")   
	end
	
	def run 
	
		Thread.new {		
				recv		
		}.join

	
	end
	

private
	
	def recv
		loop do
			data = nil
			@@lock.synchronize do
				ready = IO.select([@@sock])
        		readable = ready[0]
				readable.each do |sock|
		  	    	#data = sock.recvfrom(2048)
			    	data = sock.recvfrom_nonblock(2048)
              	end
			end
			#防止出现锁嵌套造成的死锁
			if data != nil then
				handle(data)
			end			
		end
	end	

	def find_nodeHandle(ret)
			nodes = ret['r']['nodes'].unpack("H*").to_s
			nnodes = nodes.length/(26*2)
			nnodes.times do |i|
				node = getNodes(nodes[i * 26*2 , 26*2])
				bootstrap(node[1], node[2], node[0] )
			end


	end
	
	def get_peerHandle(peer, ret)
		token  = ret['r']['token']
		peer.setToken(token)
		values = ret['r']['values']
		values.each{|v|
			p v
		}

	end


	def repsondHandle(ret, session)
		puts ("repsond " + session[3] + ":" + session[1] .to_s)
	
		id = ret['r']["id"]
		id = id.unpack("H*").to_s
		peer = nil

		if  @@bucketset.hasKey(id) then
			peer = @@bucketset.getPeer(id)
			peer.setLastTime
		else
			peer = Peer.new(session[3], session[1])
			@@bucketset.insert(id, peer)
		end
	
		type = nil
		if ret['t'] == "bootstrap" then
			type = {}
			type["name"] = "find_node"
		else
			type = peer.get_trans(ret['t'])
		end

		if type != nil then
			if type["name"] == "ping" then
					#do setLasetTime
				p  "ping respond"
			end
				
			if type["name"] == "find_node" then
				 p  "find_node respond"
				 find_nodeHandle(ret)
			end

			if type["name"] == "get_peer" then
				p "get_peer respond"
				get_peerHandle(peer, ret)
			end

		end
		
	end
	
	def erroHandle(ret, session)
		puts ("erro")

	end

	def requestHanel(ret, session)
		puts ("request")


	end


	def handle(data)
	     ret = Bdecode.new.decode(data[0])
	     type = ret["y"]
		 if type == "r" then  repsondHandle(ret, data[1]) 
		 elsif  type == "e" then  erroHandle(ret, data[1])
		 elsif  type ==  "q" then requestHanel(ret, data[1])
		 else puts "unkown info type"
	     end
	end

	def getNodes(data)
		peer = data[0, 20*2]
		host = data[20*2, 4*2].hex
		port = data[20*2 + 4*2 , 2*2].hex
	 
		host = IPAddr.new(host , Socket::AF_INET)

		return [peer,  host.to_s, port]
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
