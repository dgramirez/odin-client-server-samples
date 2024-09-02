package client_server

import "core:fmt"
import "core:net"
import "core:os"
import "core:strings"

main :: proc() {
	ipServer : string
	epServer : net.Endpoint
	sockControl : net.TCP_Socket
	strSend : string
	msgSend : [1024]u8
	ctSend : int
	errNet : net.Network_Error
	isOK : bool
	errOS : os.Errno

	ipServer = "127.0.0.1:1994"
	epServer, isOK = net.parse_endpoint(ipServer)
	if (!isOK) {
		fmt.printfln("[CLIENT]: Invalid IP / port: %s", ipServer)
		return
	}

	sockControl, errNet = net.dial_tcp(epServer)
	if (errNet != nil) {
		fmt.printfln("[CLIENT]: Failed to dial server: %s", ipServer)
		fmt.printfln("[CLIENT]: Error - %v", errNet)
		return
	}

	fmt.printfln("[CLIENT]: Connected - %s", ipServer)
	for {
		ctSend, errOS = os.read(os.stdin, msgSend[0:1024])
		if (errOS != 0) {
			fmt.printfln("[CLIENT]: An error occurred on stdin: %v", errOS)
			fmt.println("[CLIENT]: Exiting...")
			net.shutdown(sockControl, .Both)
			break
		}

		strSend = transmute(string)msgSend[0:ctSend]
		strSend = strings.trim_right_space(strSend)
		if (check_exit(strSend)) {
			net.shutdown(sockControl, .Both)
			break
		}

		if (ctSend > 0) {
			_, errNet = net.send_tcp(sockControl, transmute([]u8)strSend)
			if (errNet != nil) {
				fmt.printfln("[CLIENT]: Failed to send message to server.")
				fmt.printfln("[CLIENT]: Error - %v", errNet)
				net.shutdown(sockControl, .Both)
				break
			}
		}
	}
	fmt.printfln("[CLIENT]: Disconnected - %s", ipServer)
}

check_exit :: proc(msg: string) -> bool{
	if (strings.compare(msg, "exit") == 0) {
		return true
	}
	if (strings.compare(msg, "quit") == 0) {
		return true
	}
	if (strings.compare(msg, "bye") == 0) {
		return true
	}
	return false
}
