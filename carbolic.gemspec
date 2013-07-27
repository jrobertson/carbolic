Gem::Specification.new do |s|
  s.name = 'carbolic'
  s.version = '0.1.5'
  s.summary = 'carbolic'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_dependency 'rexle'
  s.add_dependency 'rexle-builder' 
  s.signing_key = '../privatekeys/carbolic.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/carbolic'
end
