require 'socket'
require File.expand_path(File.dirname(__FILE__) + '/bcode')


class Peer

	def initialize( host, port)
		@host  = host
		@port  = port
		@trans = {}
		@trans_id_pos = [00, 00]
		setLastTime
	end
   
	def setLastTime 
		@lastTime = Time.now.to_i #上次通信时间
	end
	
	def isUpdate
		@trans.each do |k, v|
			if Time.now.to_i - v["access_time"] > 20 then   #放弃20秒还没有返回的包
				del_tarns(k)
			end
		end

		return (Time.now.to_i -  @lastTime ) > (60*15)  #15分钟后，就认为这个结点无效
	end


     def  add_trans(name, info_hash = nil)		
	trans_id = get_trans_id
        @trans[trans_id] = {
		"name" => name,
		"info_hash" => info_hash,
		"access_time" => Time.now.to_i
	}
        return trans_id
     end
	
	def get_trans(trans_id )
			ret =	@trans[trans_id]
			del_tarns(trans_id)
			return ret 
	end

     def del_tarns(trans_id)
	@trans.delete(trans_id)
     end

     def get_trans_id
	 @trans_id_pos[0] = @trans_id_pos[0] + 1
	 if @trans_id_pos[0] == 0xff then
	     @trans_id_pos[0] = 0
	     @trans_id_pos[1] = @trans_id_pos[1] + 1
	     if @trans_id_pos[1] == 0xff then
		@trans_id_pos[1] = 0
	     end
  	  end

	 return @trans_id_pos.pack("c*")
     end

     def sendmessage(message, sock, info_hash = nil, is_boot = false)
		if sock then
			bcode =  Bencode.new
			message["v"] = "BT\x00\x01"
			if is_boot then
				message["t"] = "boot"
			else
				message["t"] = add_trans(message["q"], info_hash)
			end
			msg = bcode.encode(message)
			sock.connect(@host, @port )
			sock.send(msg, 0, @host, @port)
		end		
	end
public
	def ping(sock, id)  
		msg = { 
		       "y" => "q",
			   "q" => "ping",
			   "a" => {"id"=> id}
		}
		sendmessage(msg, sock)
	end
	

	def find_node(sock, target_id, id, is_boot)
		msg = {
			   "y" => "q",
			   "q" => "find_node",
			   "a" => 
				{
						"id" => id,
			     		"target" => target_id
				}
		}
		sendmessage(msg, sock, nil, is_boot)
	end

	def get_peer(sock, info_hash, id)
		msg = {"t" => "aa",
		       "y" => "q",
			   "q" => "get_peers",
			   "a" => {"id" => id,
			   "info_hash" => info_hash
				}
		}
		sendmessage(msg, sock, info_hash)
	end
	
	def announce_peer(sock, id)

	end
end
