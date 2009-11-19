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
    hex = GeoHex.encode(35.647401,139.716911,1)
    hex.code == '132KpuG' and 
    hex.lat == 35.6478085
    hex.lng == 139.7173629550321
    
  end
end



