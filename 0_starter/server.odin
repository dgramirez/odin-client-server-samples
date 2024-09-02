package client_server

import "core:fmt"
import "core:net"

main :: proc() {
	epListen : net.Endpoint
	epClient : net.Endpoint
	sockListen : net.TCP_Socket
	sockClient : net.TCP_Socket
	ipListen : string
	errNet : net.Network_Error
	isOK : bool

	ipListen = "127.0.0.1:1994"
	epListen, isOK = net.parse_endpoint(ipListen)
	if (!isOK) {
		fmt.printfln("[SERVER]: Invalid IP / port: %s", ipListen)
		return
	}

	sockListen, errNet = net.listen_tcp(epListen)
	if (errNet != nil) {
		fmt.println("[SERVER]: Failed to create listen socket")
		fmt.printfln("[SERVER]: Error - %v", errNet)
		return
	}

	for {
		sockClient, epClient, errNet = net.accept_tcp(sockListen)
		if (errNet == nil) {
			fmt.printfln("[SERVER]: Connected - %s",
						 net.address_to_string(epClient.address))

			net_main(sockClient)

			fmt.printfln("[SERVER]: Disconnected - %s",
						 net.address_to_string(epClient.address))
		} else {
			fmt.println("[SERVER]: Failed to accept TCP Socket: %v",
			            epClient)
			fmt.printfln("[SERVER]: Error - %v", errNet)
		}
	}
}

net_main :: proc(sockClient: net.TCP_Socket) {
	errNet: net.Network_Error
	msgRecv : [1024]u8
	ctRecv : int

	for {
		ctRecv, errNet = net.recv_tcp(sockClient, msgRecv[0:1024])
		if (errNet != nil) {
			fmt.printfln("[SERVER]: Recv Failure: %v", errNet)
			break
		}
		if (ctRecv == 0) {
			fmt.printfln("[SERVER]: Client Disconnected Gracefully.")
			break
		}

		fmt.printfln("[CLIENT]: %s", msgRecv[0:ctRecv])
	}

	net.shutdown(sockClient, .Both)
}

