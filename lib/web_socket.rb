class WebSocket
  attr_accessor :delegate
  attr_reader :handshake, :host
  
  CHUNK_LENGTH = 1024
  
  def initialize(host, port)
    @istream = Pointer.new(:id)
    @ostream = Pointer.new(:id)
    @q = Dispatch::Queue.new("com.mowforth.limpet.websocket.#{object_id}")
    @group = Dispatch::Group.new
    @host = NSHost.hostWithName(host)
    @port = port
    @handshake = "GET / HTTP/1.1\r\n" +
    "Upgrade: WebSocket\r\n" +
    "Connection: Upgrade\r\n" +
    "Host: #{@host.name}:#{@port}\r\n" +
    "Origin: http://#{@host.name}\r\n" +
    "\r\n"
  end
  
  def connect
    # todo
  end
  
  protected
  
  def stream(stream, handleEvent:eventCode)
    # todo
  end
  
  private
  
  def istream
    @istream[0]
  end
  
  def ostream
    @ostream[0]
  end
    
  end
end