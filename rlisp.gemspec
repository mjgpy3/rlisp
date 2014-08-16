Gem::Specification.new do |s|
  s.name = 'rlisp'
  s.version = '0.0.1'
  s.licenses = ['MIT']
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Michael "Gilli" Gilliland']
  s.homepage = 'https://github.com/mjgpy3/rlisp'
  s.date = '2014-07-18'
  s.summary = 'A lisp-like DSL for ruby, yay!'
  s.description = 'Your wildest dreams have come true! Lisp within ruby!'
  s.files = ['./lib/rlisp.rb',
    './spec/spec_helper.rb',
    './spec/lib/rlisp_spec.rb',
    './README.md',
    './rlisp.gemspec']
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rake'
end
