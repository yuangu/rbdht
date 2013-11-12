require 'socket'
require File.expand_path(File.dirname(__FILE__) + '/bcode')
require File.expand_path(File.dirname(__FILE__) + '/utils')

class Peer

	def initialize( host, port)
		@host  = host
		@port  = port
		@trans = {}
		@trans_id_pos = [00, 00]
		setLastTime
	end
   
	 def sendmessage(message, sock, trans_id= nil, lock= nil)
		if sock then			 
			
		 		bcode =  Bencode.new
				message["v"] = get_version
				if trans_id != nil then
						message["t"] = trans_id
				end

				msg = bcode.encode(message)
				puts "send " + message["q"] + " to " + @host + ":"+@port.to_s

			if lock != nil then
				lock.synchronize do
					sock.connect(@host, @port )
					sock.send(msg, 0, @host, @port)		
				end
			else
				sock.connect(@host, @port )
				sock.send(msg, 0, @host, @port)
			end
		end
	end

	 def get_trans_id(name, info_hash = nil)
	 	@trans_id_pos[0] = @trans_id_pos[0] + 1
	 	if @trans_id_pos[0] == 0xff then
	    	 @trans_id_pos[0] = 0
	    	 @trans_id_pos[1] = @trans_id_pos[1] + 1
	     	if @trans_id_pos[1] == 0xff then
			@trans_id_pos[1] = 0
	     	end
  	  	end
	 	trans_id =  @trans_id_pos.pack("c*")


		 @trans[trans_id] = {
		"name" => name,
		"info_hash" => info_hash,
		"access_time" => Time.now.to_i
		}
	 	return trans_id
	 end


	def setLastTime 
		@lastTime = Time.now.to_i #上次通信时间
	end


	def isbad
		@trans.each do |k, v|
			if Time.now.to_i - v["access_time"] > 60 then   #放弃60秒还没有返回的包
				del_tarns(k)
			end
		end

		return (Time.now.to_i -  @lastTime ) > (60*15)  #15分钟后，就认为这个结点无效
	end


	
	def get_trans(trans_id )
			ret =	@trans[trans_id]
			del_tarns(trans_id)
			return ret 
	end

     def del_tarns(trans_id)
	@trans.delete(trans_id)
     end

	def setToken(token)
		@token = token
	end

public
	def ping(sock, sender_id, lock = nil)  
		trans_id =  get_trans_id("ping")			
		msg = { 
		       "y" => "q",
			   "q" => "ping",
			   "a" => {"id"=> sender_id}
		}
		sendmessage(msg, sock, trans_id, lock)
	end
	
	def pong(sock, trans_id, sender_id, lock)
		msg = {
			"y" => "r",
			"r" => {
				"id" => sender_id,
			}	
		}
		sendmessage(msg, sock, trans_id, lock)
	end


	def find_node(sock, target_id, sender_id, lock, trans_id = nil)
		if trans_id == nil then
		   trans_id =  get_trans_id("find_node")
		end
		msg = {
			   "y" => "q",
			   "q" => "find_node",
			   "a" => 
				{
						"id" => sender_id,
			     		"target" => target_id
				}
		}
		sendmessage(msg, sock, trans_id, lock)
	end

	def fond_node(sock, found_nodes, trans_id = nil, sender_id = nil, lock = nil)
	

	end



	def get_peers(sock, info_hash, sender_id)
		trans_id =  get_trans_id("get_peers")
		msg = {
		       "y" => "q",
			   "q" => "get_peers",
			   "a" => {"id" => sender_id,
			   "info_hash" => info_hash
				}
		}
		sendmessage(msg, sock, trans_id, lock)
	end


	def got_peers()



	end
	
	def announce_peer(sock, id)

	end

	def announced_peer(sock, id)

	end

end
