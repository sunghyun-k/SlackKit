//
//  SwifterServer.swift
//
// Copyright © 2017 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Vapor

class SwifterServer: SlackKitServer {
    let app = Application()
    let port: in_port_t
    // 사용하는 프로퍼티가 아님
    let forceIPV4: Bool

    init(port: in_port_t = 8080, forceIPV4: Bool = false, responder: SlackKitResponder) {
        self.port = port
        self.forceIPV4 = forceIPV4

        for route in responder.routes {
            
            app.post("\(route.path)") { request in
                return route.middleware.respond(to: (request.request, Response())).1.response
            }
        }
    }

    public func start() {
        do {
            try app.server.start(address: .hostname(nil, port: Int(port)))
        } catch let error {
            print("Server failed to start with error: \(error)")
        }
    }

    deinit {
        app.shutdown()
    }
}

extension Vapor.Request {
    public var request: RequestType {
        return try! Request(
            method: .custom(named: method.string),
            path: route?.path.string ?? "",
            queryPairs: parameters.allNames
                .map { ($0, parameters.get($0)!) },
            body: body.string ?? "",
            headers: HTTPHeaders(headers: headers
                .map { Header(name: $0.name, value: $0.value) })
        )
    }
}

extension ResponseType {
    public var contentType: String? {
        return self.headers.first(where: {$0.name.lowercased() == "content-type"})?.value
    }
    
    public var response: Vapor.Response {
        switch self.code {
        case 200 where contentType == nil:
            return .init(status: .ok, body: .init(string: bodyString ?? ""))
        case 200 where contentType?.lowercased() == "application/json":
            do {
                let json = try JSONSerialization.jsonObject(with: body, options: [])
                return .init(status: .ok, body: .init(data: body))
                
            } catch let error {
                return .init(status: .badRequest, body: .init(string: error.localizedDescription))
            }
        case 400:
            return .init(status: .badRequest, body: .init(string: "Bad request."))
        default:
            return .init(status: .ok, body: .init(string: "ok"))
        }
    }
}
