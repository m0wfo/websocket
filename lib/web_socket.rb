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
  
  def close
    ostream.close
    istream.close
    
    istream.removeFromRunLoop(NSRunLoop.currentRunLoop, forMode:NSRunLoop::NSDefaultRunLoopMode)
    ostream.removeFromRunLoop(NSRunLoop.currentRunLoop, forMode:NSRunLoop::NSDefaultRunLoopMode)
    
    ostream.release
    istream.release
  end
  
  protected
  
  def stream(stream, handleEvent:eventCode)
    if eventCode == 16
      close
      @delegate.send(:connectionClosed)
    else
      if istream.hasBytesAvailable
        read(istream)
      end
    end
  end
  
  private
  
  def read(input)
    stream, read_bytes = "", 0
    while istream.hasBytesAvailable
      buf = "\0" * CHUNK_LENGTH
      len = input.read(buf, maxLength:CHUNK_LENGTH)
      read_bytes += len
      stream << buf
    end
    data = stream[0..read_bytes-1]
    if data =~ /\r\n\r\n$/
      @q.resume!
    else
      if data
        if @delegate.respond_to?(:dataReceived)
          @delegate.send(:dataReceived, data.delete("\x00ˇ").force_encoding("UTF-8"))
        else
          warn "Tried to call dataReceived on the delegate, but it's undefined."
        end
      end
    end
  end
  
  def istream
    @istream[0]
  end
  
  def ostream
    @ostream[0]
  end
    
  end
end