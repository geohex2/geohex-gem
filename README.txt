= geohex

* http://geohex.rubyforge.org/

## GEOHEX DESCRIPTION
GeoHex Gem for Ruby (c) 2009 Haruyuki Seki
http://twitter.com/hal_sk_e  (en)
http://twitter.com/hal_sk  (ja)

  * The GeoHex is a latitude/longitude encoding system invented by sa2da.
  * GeoHex divides geometry regions into hexagonal grid and set an unique identifier to each grid. It supports only Japan region so far. 
  * The coding idea is opened under the Creative Commons Attribution 2.1 Japan Lisence. 
  * GeoHex Documentation: http://github.com/geohex/geohex-docs
  * GeoHex Original Wiki(Japanese): http://geogames.net/labs/geohex
  * GeoHex Demo: http://geogames.net/hex/
  * Various GeoHex Libraries: http://github.com/geohex/
  
## GEOHEX GEM DESCRIPTION
   
  This GeoHex Ruby gem can convert latitude/longitude to GeoHex code each others.
  * Encode from latitude/longitude to GeoHex code to an arbitrary level of precision
  * Decode from GeoHex code to latitude/longitude and level of precision

## INSTALL

   sudo gem install geohex

## QUICK START

   require 'geohex'
   GeoHex.encode(35.647401,139.716911,1)
   => '132KpuG' 
   GeoHex.decode('0dMV')
   => [24.338279000000004,124.1577708779443,7]

## FEATURES

   require 'geohex'
   geohex = GeoHex.new(35.647401,139.716911,1)
   geohex.code
   => '132KpuG' 
   geohex = GeoHex.decode('0dMV')
   geohex.lat
   => 24.338279000000004

## LICENSE

NOTE: 
The idea of GeoHex is licensed by sa2da. 
You should follow original license of GeoHex.
(The license is opened by CC-BY-SA license)
You must attribute this work to sa2da (with link).
http://geogames.net

This ruby code is covered by MIT License.
(The MIT License)

Copyright (c) 2009 Haruyuki SEKI 

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
