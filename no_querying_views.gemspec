# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = "no_querying_views"
  s.version     = '1.0.0'
  s.authors     = ["Franck Verrot"]
  s.email       = "franck@verrot.fr"
  s.homepage    = "https://github.com/franckverrot/no_querying_views"
  s.summary     = "No more querying views in your Rails apps"
  s.description = s.summary

  s.files        = `git ls-files app lib`.split("\n")
  s.platform     = Gem::Platform::RUBY

  s.add_development_dependency "bundler"
  s.add_development_dependency "minitest"

  s.add_dependency 'rake'
  s.add_dependency 'actionpack',          '>= 4.0.0'
  s.add_dependency 'activerecord',        '>= 4.0.0'
  s.add_development_dependency 'railties','>= 4.0.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pg'
end
