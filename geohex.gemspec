Gem::Specification.new do |s|
  s.name     = "geohex"
  s.version  = '1.0.0'
  s.date     = "2009-11-17"
  s.summary  = "GeoHex Library for Ruby, per http://geogames.net/labs/geohex implementation."
  s.email    = "hal.marsellus@gmail.com"
  s.homepage = "http://github.com/geohex/geohash-gem"
  s.description = "GeoHex provides support for manipulating GeoHex strings in Ruby. See http://geogames.net/labs/geohex"
  s.has_rdoc = true
  s.authors  = ["Haruyuki Seki"]
  s.files    = ["lib/geohex.rb"]
  s.test_files = ["spec/geohex_spec.rb"]
  s.rdoc_options = ["--main", "README.markdown"]
  s.extra_rdoc_files = ["Manifest.txt", "README.markdown"]
end
