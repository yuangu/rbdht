require File.expand_path(File.dirname(__FILE__) + '/peer')
require File.expand_path(File.dirname(__FILE__) + '/bucketset')
require File.expand_path(File.dirname(__FILE__) + '/utils')
require "socket"
require 'ipaddr'
require 'thread'

class RBDht
public	
	def initialize(host = "0.0.0.0", port = 9002, id = nil)
		BasicSocket.do_not_reverse_lookup = true
		@@lock  = Mutex.new
		@@sock = UDPSocket.open
		@@sock.bind(host, port)
	
		if id != nil then
			@id = strToHex(id)
		else
			@id = randId
		end
		@@bucketset = BucketSet.new
	end

	def bootstrap(host, port, id = "bootstrap", target_id = nil )
	
		 if target_id == nil then
			target_id = @id
		 else
			target_id = strToHex(target_id)
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
				begin  
			    	data = sock.recvfrom_nonblock(2048)
              	rescue
					puts "error:#{$!} at:#{$@}"
				ensure
					next
				end

				end
			end
			#防止出现锁嵌套造成的死锁
			if data != nil then
				handle(data)
			end			
		end
	end	

	def find_nodeHandle(ret)
			nodes = ret['r']['nodes']
			if nodes == nil then return end
			nodes = hexToStr(nodes) 
			nnodes = nodes.length/(26*2)
			nnodes.times do |i|
				node = getNodes(nodes[i * 26*2 , 26*2])
				if @@bucketset.getlength < 1000 then
					bootstrap(node[1], node[2])
				end
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
		id = hexToStr(id) 
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
		type = ret["q"]
		id = ret["a"]['id']
		id = hexToStr(id)
		trans_id =  ret["t"]
		if trans_id == nil or id == nil  then return end

		peer = nil
		if  @@bucketset.hasKey(id) then
			peer = @@bucketset.getPeer(id)
			peer.setLastTime
		else
			peer = Peer.new(session[3], session[1])
			@@bucketset.insert(id, peer)
		end

		

		if type == "ping" then
			peer.pong(@@sock,  trans_id, @id, @@lock)
			p "ping request"
		elsif type == "find_node" then
			nodes = @@bucketset.getnodes
			peer.fond_node(@@sock, nodes, trans_id, @id, @@lock)
		#	peer.pong(sock,  trans_id, @id, @@lock)
			p "find_node request"
		elsif type == "get_peers" then
			p "get_peers request"
			nodes = @@bucketset.getnodes
			token = get_token
			peer.got_peers(@@sock, trans_id, @id , token, nil, nodes, @@lock)


		elsif type == "announce_peer" then
			p "announce_peer request"
		else puts "unkown info type"
		
		end
	end


	def handle(data)
	     ret = Bdecode.new.decode(data[0])
		 if ret == nil then return end
		 if ret['v'] != nil then p "the clients version is " + ret['v'] end
		

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
