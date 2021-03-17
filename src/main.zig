const std = @import("std");
const mem = std.mem;
const testing = std.testing;

//
// start_line =  request_line | status_line
//
// methods = {
//  +---------+-------------------------------------------------+
//  | Method  | Description                                     |
//  +---------+-------------------------------------------------+
//  | GET     | Transfer a current representation of the target |
//  |         | resource.                                       |
//  | HEAD    | Same as GET, but only transfer the status line  |
//  |         | and header section.                             |
//  | POST    | Perform resource-specific processing on the     |
//  |         | request payload.                                |
//  | PUT     | Replace all current representations of the      |
//  |         | target resource with the request payload.       |
//  | DELETE  | Remove all current representations of the       |
//  |         | target resource.                                |
//  | CONNECT | Establish a tunnel to the server identified by  |
//  |         | the target resource.                            |
//  | OPTIONS | Describe the communication options for the      |
//  |         | target resource.                                |
//  | TRACE   | Perform a message loop-back test along the path |
//  |         | to the target resource.                         |
//  +---------+-------------------------------------------------+

const parser: Parser([]u8, @TypeOf(reader)) = .{
    ._parse = myParse,
};

const Method = enum { GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE };

const MessageType = enum {
    Request,
    Status,
};

const HttpVersion = enum {
    v0_9,
    v1_0,
    v1_1,
    v2_0,
};

const HTTP = struct {
    method: Method,
    http_version: HttpVersion,
    request_target: []const u8,
    reason_phrase: []const u8,
    message_type: MessageType,
    headers: std.HashMap([]const u8, []const u8),
};

fn takeUntil(allocator: *mem.Allocator, reader: anytype, delimeter: u8) ![]u8 {
    const val = try reader.readUntilDelimiterAlloc(
        allocator,
        delimeter,
        1000,
    );

    return val;
}

fn getMessageType(reader: anytype) !MessageType {
    var check: [2]u8 = undefined;
    var bytes_read = try ps.reader().read(check[0..2]);

    try ps.putBack(check[0..2]);

    if (mem.eql(u8, check[0..2], "HT")) {
        return MessageType.Status;
    }

    return MessageType.Request;
}

const ParserError = error{ InvalidMethod, MalformedRequest };

// fn partHttpVersion(message: []const u8) !HttpVersion {
//     if mem.eql(u8, message, "HTTP/0.9") {
//     }
//
//     if mem.eql(u8, message, "HTTP/0.9") {
//     }
//
//     if mem.eql(u8, message, "HTTP/0.9") {
//     }
// }

fn parseMethod(message: []const u8) !Method {
    if (mem.eql(u8, message, "GET")) {
        return Method.GET;
    }

    if (mem.eql(u8, message, "HEAD")) {
        return Method.HEAD;
    }

    if (mem.eql(u8, message, "POST")) {
        return Method.POST;
    }

    if (mem.eql(u8, message, "PUT")) {
        return Method.PUT;
    }

    if (mem.eql(u8, message, "DELETE")) {
        return Method.DELETE;
    }

    if (mem.eql(u8, message, "CONNECT")) {
        return Method.CONNECT;
    }

    if (mem.eql(u8, message, "OPTIONS")) {
        return Method.OPTIONS;
    }

    if (mem.eql(u8, message, "TRACE")) {
        return Method.TRACE;
    }

    return ParserError.InvalidMethod;
}

// fn parseStartLine(allocator: *mem.Allocator) {
//     var http: Http = undefined;
//
//     const firstToken = try reader.readUntilDelimiterAlloc(
//         allocator,
//         ' ',
//         10,
//     );
//
//     if (mem.eql(firstToken[0..2], "HT")) {
//         // status line
//         http.http_version = HttpVersion.
//
//     } else {
//         // request line
//     }
// }

test "parse request: method" {
    testing.expectEqual(try parseMethod("GET"), Method.GET);
    testing.expectEqual(try parseMethod("HEAD"), Method.HEAD);
    testing.expectEqual(try parseMethod("POST"), Method.POST);
    testing.expectEqual(try parseMethod("PUT"), Method.PUT);
    testing.expectEqual(try parseMethod("DELETE"), Method.DELETE);
    testing.expectEqual(try parseMethod("CONNECT"), Method.CONNECT);
    testing.expectEqual(try parseMethod("OPTIONS"), Method.OPTIONS);
    testing.expectEqual(try parseMethod("TRACE"), Method.TRACE);
}
