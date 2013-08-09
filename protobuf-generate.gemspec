$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

spec = Gem::Specification.new do |s|
  s.name        = 'protobuf-generate'
  s.version     = '0.0.1'
  s.summary     = 'A multi-language concrete protobuf code generator.'
  s.description = 'A simple PEG parser, AST and template based approach to code generation.'
  s.authors     = ['Shane Hanna']
  s.email       = ['shane.hanna@gmail.com']
  s.licenses    = ['MIT']
  s.homepage    = 'https://bitbucket.org/shanehanna/protobuf-generate'

  s.add_dependency('parslet')
  s.add_dependency('erubis')

  s.required_ruby_version = '>= 1.9.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
