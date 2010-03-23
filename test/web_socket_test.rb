require File.dirname(__FILE__) + '/test_helper'

class WebSocketTest < Test::Unit::TestCase
  
  def test_should_have_delegate
    ws = WebSocket.new('127.0.0.1', 8080)
    delegate = Object.new
    ws.delegate = delegate
    assert_same ws.delegate, delegate
  end
  
  def test_should_have_chunk_length_constant
    assert_not_nil WebSocket::CHUNK_LENGTH
    assert_equal WebSocket::CHUNK_LENGTH, 1024
  end
  
  def test_should_have_properly_formed_request_headers
    target = '66.102.9.99'
    port = 1337
    ws = WebSocket.new(target, port)
    handshake = "GET / HTTP/1.1\r\n" +
    "Upgrade: WebSocket\r\n" +
    "Connection: Upgrade\r\n" +
    "Host: #{NSHost.hostWithName(target).name}:#{port}\r\n" +
    "Origin: http://#{NSHost.hostWithName(target).name}\r\n" +
    "\r\n"
    assert ws.respond_to?(:handshake)
    assert_equal ws.handshake, handshake
  end
end