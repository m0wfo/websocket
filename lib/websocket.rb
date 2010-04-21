framework 'Foundation'
autoload :URI, 'uri'

class Websocket  
  attr_accessor :delegate, :host, :port
  
  CHUNK_LENGTH = 1024
  
  def initialize(location)
    target = URI::parse(location)
    raise "Unsupported protocol" unless target.scheme == 'ws'

    @istream, @ostream = Pointer.new(:id), Pointer.new(:id)
    @q = Dispatch::Queue.new("com.mowforth.websocket.#{object_id}")
    @group = Dispatch::Group.new
    @host = NSHost.hostWithName(target.host).addresses.last
    @port = target.port
  end
  
  def connect
    NSStream.getStreamsToHost(@host, port:@port, inputStream:@istream, outputStream:@ostream)
    istream.setDelegate(self)
    ostream.setDelegate(self)
    
    istream.scheduleInRunLoop(NSRunLoop.currentRunLoop, forMode:NSDefaultRunLoopMode)
    ostream.scheduleInRunLoop(NSRunLoop.currentRunLoop, forMode:NSDefaultRunLoopMode)
    
    istream.retain
    ostream.retain
    
    istream.open
    ostream.open
    
    @q.async(@group) { ostream.write(handshake, maxLength:handshake.length) }
    
    @group.wait
    @q.suspend!
  end
  
  def push(message)
    data = "\x00#{message}\xff"
    @q.async(@group) { ostream.write(data, maxLength:data.length) }
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
      send_or_warn(:connectionClosed)
    elsif eventCode == NSStreamEventErrorOccurred
      # warn stream.streamError.localizedDescription
      raise "arrrrgh!"
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
        send_or_warn(:dataReceived, data.delete("\x00ˇ").force_encoding("UTF-8"))
      end
    end
  end
  
  def handshake
    "GET / HTTP/1.1\r\n" +
    "Upgrade: WebSocket\r\n" +
    "Connection: Upgrade\r\n" +
    "Host: #{@host.name}:#{@port}\r\n" +
    "Origin: http://#{@host.name}\r\n" +
    "\r\n".force_encoding("US-ASCII")
  end
  
  def istream
    @istream[0]
  end
  
  def ostream
    @ostream[0]
  end
  
  def send_or_warn(method, *args)
    if @delegate && @delegate.respond_to?(method)
      @delegate.send(method, *args)
    else
      warn "Delegate does not respond to #{method}"
    end
  end
end