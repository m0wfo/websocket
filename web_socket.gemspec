Gem::Specification.new do |spec|
  spec.name = %q{web_socket}
  spec.version = "0.0.1"
  spec.authors = ["Chris Mowforth"]
  spec.email = "chris@mowforth.com"
  spec.files = Dir.glob("lib/*")
  spec.has_rdoc = false
  spec.summary = "A WebSocket client for MacRuby"
  spec.required_ruby_version = Gem::Requirement.new(">= 1.9.0")
  spec.test_files = Dir.glob("test/*.rb")
end