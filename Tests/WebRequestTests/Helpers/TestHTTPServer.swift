//
// TestHTTPServer
//
// Adapted from: https://gist.github.com/neonichu/c504267a23ca3f3126bb
//

import Foundation

class TestHTTPServer: NSObject {

    var responsePayload: String?
    var portNumber: UInt16 = 8080
    private var timer: DispatchSourceTimer?
    private var serverSocket: Int32 = -1

    func start() {

        guard let payload = responsePayload else {
            return print("No response payload")
        }

        let sin_zero: (Int8,Int8,Int8,Int8,Int8,Int8,Int8,Int8) = (0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)
        let sock_stream = SOCK_STREAM
        let INADDR_ANY = in_addr_t(0)

        let sock = Darwin.socket(AF_INET, Int32(sock_stream), 0)
        guard (sock >= 0) else {
            return print("Could not create server socket.")
        }

        var optval = 1
        guard (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &optval, socklen_t(MemoryLayout<Int>.size)) >= 0) else {
            return print("Could not set SO_REUSEADDR")
        }

        let socklen = UInt8(MemoryLayout<sockaddr_in>.size)

        var serveraddr = sockaddr_in()
        serveraddr.sin_family = sa_family_t(AF_INET)
        serveraddr.sin_port = in_port_t(htons(value: in_port_t(portNumber)))
        serveraddr.sin_addr = in_addr(s_addr: INADDR_ANY)
        serveraddr.sin_zero = sin_zero
        serveraddr.sin_len = socklen

        let _ = withUnsafeMutablePointer(to: &serveraddr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.bind(sock, $0, socklen_t(socklen))
            }
        }

        guard (listen(sock, 5) >= 0) else {
            return print("Could not listen on socket")
        }

        print(">>>> Started listening on port \(portNumber)")

        let queue = DispatchQueue.global(qos: .background)
        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer.schedule(deadline: .now(), repeating: .seconds(100), leeway: .seconds(1))
        timer.setEventHandler(handler: { [weak self] in
            guard let `self` = self else { return }
            guard (sock >= 0) else {
                self.stop()
                return
            }

            let clientSocket = accept(sock, nil, nil)

            self.rawPrint(clientSocket, "HTTP/1.1 200 OK\n")
            self.rawPrint(clientSocket, "Server: Test Web Server\n");
            self.rawPrint(clientSocket, "Content-length: \(payload.lengthOfBytes(using: .utf8))\n");
            self.rawPrint(clientSocket, "Content-type: application/json\n");
            self.rawPrint(clientSocket, "\r\n");

            self.rawPrint(clientSocket, payload)

            Darwin.close(clientSocket)
        })
        self.serverSocket = sock
        self.timer = timer
        timer.resume()
    }

    func stop() {
        Darwin.close(serverSocket)
        timer?.cancel()
        timer = nil
        print("<<<< Stopped listening on port \(portNumber)")
    }

    private func htons(value: CUnsignedShort) -> CUnsignedShort {
        return (value << 8) + (value >> 8)
    }

    private func rawPrint(_ socket: Int32, _ output: String) {
        let _ = output.withCString { (bytes) in
            send(socket, bytes, Int(strlen(bytes)), 0)
        }
    }
}
