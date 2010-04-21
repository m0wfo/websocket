framework 'AppKit'
require File.dirname(__FILE__) + '/test_helper'

class WebsocketTest < Test::Unit::TestCase
  
  def test_should_have_delegate
    delegate = Object.new
    @ws.delegate = delegate
    assert_same @ws.delegate, delegate
  end
  
  def test_should_have_chunk_length_constant
    assert_not_nil Websocket::CHUNK_LENGTH
    assert_equal Websocket::CHUNK_LENGTH, 1024
  end
  
  def test_error_raised_when_connection_refused
    # assert_raise do
    #   app = NSApplication.new
    #   app.delegate = AppDelegate.new do |d|
    #     d.ws = Websocket.new('127.0.0.1', 8080)
    #   end
    #   app.run
    #   sleep 2
    #   app.stop
    # end
    # todo
  end
  
  def test_read_stream
    @istream = OpenStruct.new
    @istream.hasBytesAvailable = true
    i = flexmock(:safe, @ws) do |mock|
      mock.should_receive(:istream).and_return { @istream }
    end
    # 
    # @ws.connect
    # @ws.push('hi')
  end
  
  protected
  
  def setup
    @ws ||= Websocket.new('127.0.0.1', 8080)
  end
end