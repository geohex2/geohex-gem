require "#{File.dirname(__FILE__)}/../lib/geohex.rb"

describe GeoHex do
  
  it "should throw error if parameters is not valid" do
    lambda { GeoHex.encode() }.should raise_error(ArgumentError) # no parameters
    lambda { GeoHex.encode(-91,100,1) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex.encode(91,100,1) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex.encode(90,181,1) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex.encode(-90,-181,1) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex.encode(0,180,0) }.should raise_error(ArgumentError) # invalid level
    lambda { GeoHex.encode(0,-180,61) }.should raise_error(ArgumentError) # invalid level
  end
  it "should convert coordinates to geohex code" do
    # simple test
    GeoHex.encode(35.647401,139.716911,1).should == '132KpuG' 
    GeoHex.encode(24.340565,124.156201,42).should == 'G028k'

    # correct answers (you can obtain this test variables from jsver_test.html )
    correctdata = '{' + File.open("#{File.dirname(__FILE__)}/testdata.txt").read + '}'
    eval(correctdata).each_pair do |k,v|
      GeoHex.encode(v[0],v[1],v[2]).should == k
    end
    
    #hex.lat == 35.6478085
    #hex.lng == 139.7173629550321
    
  end
end



