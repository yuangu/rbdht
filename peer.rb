require 'socket'
require File.expand_path(File.dirname(__FILE__) + '/bcode')


class Peer

	def initialize( host, port)
		@host = host
		@port = port
	end
   

	private
    def sendmessage(message, sock)
		if sock then
			bcode =  Bencode.new
			message["v"] = "BT\x00\x01"
			message["t"] = "\x02\x16\x5b\x26"
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
	

	def find_node(sock, target_id, id)
		msg = {
			   "y" => "q",
			   "q" => "find_node",
			   "a" => 
				{
						"id" => id,
			     		"target" => target_id
				}
		}
		sendmessage(msg, sock)
	end

	def get_peer(sock, info_hash, id)
		msg = {"t" => "aa",
		       "y" => "q",
			   "q" => "get_peers",
			   "a" => {"id" => id,
			   "info_hash" => info_hash
				}
		}
		sendmessage(msg, sock)
	end
	
	def announce_peer(sock, id)

	end
end
