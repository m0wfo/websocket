require File.dirname(__FILE__) + '/test_helper'

class WebSocketTest < Test::Unit::TestCase
  
  def test_should_have_delegate
    delegate = Object.new
    @ws.delegate = delegate
    assert_same @ws.delegate, delegate
  end
  
  def test_should_have_chunk_length_constant
    assert_not_nil WebSocket::CHUNK_LENGTH
    assert_equal WebSocket::CHUNK_LENGTH, 1024
  end
  
  def test_connection
    @ws.connect
  end
  
  def setup
    @ws ||= WebSocket.new('127.0.0.1', 8080)
  end
end