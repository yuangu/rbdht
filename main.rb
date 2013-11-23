=begin
require 'socket'
require File.expand_path(File.dirname(__FILE__) + '/peer')
$port = 9321
BasicSocket.do_not_reverse_lookup = true
sock = UDPSocket.open
sock.bind("0.0.0.0", $port)

#"router.utorrent.com"
#'router.bittorrent.com'
#
boot = Peer.new( "67.215.242.139" , 6881)
#boot.find_node(sock, "\x74\x63\x85\xfe\x32\xb2\x68\xd5\x13\xd0\x68\xf2\x2c\x53\xc4\x6d\x2e\xb3\x4a\x5c","\x2d\x1e\xf4\xc7\x03\xa2\x81\xd1\xc8\x55\xe2\x02\x84\xb2\x61\x6d\x1b\xfc\xcb\x01" )



boot.ping(sock ,"\x2d\x1e\xf4\xc7\x03\xa2\x81\xd1\xc8\x55\xe2\x02\x84\xb2\x61\x6d\x1b\xfc\xcb\x01")
#p sock.recvfrom(100) 
while true
        ready = IO.select([sock])
        readable = ready[0]
		readable.each do |sock|
			p sock.recvfrom(100) 
		end
end
=end
require File.expand_path(File.dirname(__FILE__) + '/rbdht')
test = RBDht.new
test.setHook("ping", def func(host, port)   p host + ":"+ port + " ping"  end )

=begin
findnodeHook = def func(host, port, nodes)
	str = host + ":"+ port + "find_node"
 =begin
	nodes.each { |node|
		str = str + node[0] + " " + node[1] + ":" + node[2] + "\n"

	}
 =end
	p str
end
test.setHook("find_node", findnodeHook)
=end

gotpeerHook = def func(host, port, infohash)
	str = host + ":"+ port + " got_peers"
	p str 
	#p infohash.class
	p infohash
	p  "infohash:" + infohash
	fh = File.new("temp.out", "a")
	fh.write( host+ ":"+ port + " " + infohash + "\r\n")
	fh.close
end
test.setHook("got_peers", gotpeerHook)

test.bootstrap( "67.215.242.139" , 6881)
test.run
