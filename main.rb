require 'socket'
require File.expand_path(File.dirname(__FILE__) + '/peer')
$port = 9321
BasicSocket.do_not_reverse_lookup = true
sock = UDPSocket.open
sock.bind("0.0.0.0", $port)

#"router.utorrent.com"
#'router.bittorrent.com'
#
boot = Peer.new("\x2d\x1e\xf4\xc7\x03\xa2\x81\xd1\xc8\x55\xe2\x02\x84\xb2\x61\x6d\x1b\xfc\xcb\x01", "67.215.242.139" , 6881)
#boot.find_node(sock, "\x74\x63\x85\xfe\x32\xb2\x68\xd5\x13\xd0\x68\xf2\x2c\x53\xc4\x6d\x2e\xb3\x4a\x5c" )



boot.ping(sock )
#p sock.recvfrom(100) 
while true
        ready = IO.select([sock])
        readable = ready[0]
		readable.each do |sock|
			p sock.recvfrom(100) 
		end
end
