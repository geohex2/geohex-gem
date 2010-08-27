require "#{File.dirname(__FILE__)}/../lib/geohex.rb"

describe GeoHex do
  before(:all) do
    @correct_ll2hex = eval('{' + File.open("#{File.dirname(__FILE__)}/testdata_ll2hex.txt").read + '}')
    @correct_hex2ll = eval('{' + File.open("#{File.dirname(__FILE__)}/testdata_hex2ll.txt").read + '}')
  end  
  
  it "should throw error if parameters is not valid" do
    lambda { GeoHex.encode() }.should raise_error(ArgumentError) # no parameters
    lambda { GeoHex.encode(-86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex.encode(86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex.encode(85,181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex.encode(-85,-181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex.encode(0,180,-1) }.should raise_error(ArgumentError) # invalid level
    lambda { GeoHex.encode(0,-180,25) }.should raise_error(ArgumentError) # invalid level
  end
  it "should convert coordinates to geohex code" do
    # correct answers (you can obtain this test variables from jsver_test.html )
    @correct_ll2hex.each_pair do |k,v|
      GeoHex.encode(k[0],k[1],k[2]).should == v
    end
    
  end
  it "should convert geohex to coordinates " do
  pending
    # correct answers (you can obtain this test variables from jsver_test.html )
    @correct_hex2ll.each_pair do |k,v|
      GeoHex.decode(k).should == v
    end
    
  end

  it "should return instance from coordinates " do
  pending
    GeoHex.new(35.647401,139.716911,1).code.should == '132KpuG'
    GeoHex.new(35.647401,139.716911,60).code.should == '032Lq'
  end

  it "should raise error if instancing with nil data " do
  pending
    lambda { GeoHex.new }.should raise_error(ArgumentError)
  end
  it "should return instance from hexcode " do
  pending
    geohex = GeoHex.new('132KpuG')
    geohex.lat.should == 35.6478085
    geohex.lon.should == 139.7173629550321
    geohex.level.should == 1

    geohex = GeoHex.new('0016C')
    geohex.lat.should == 24.305370000000003
    geohex.lon.should == 124.17423982869379
    geohex.level.should == 60

  end
end



