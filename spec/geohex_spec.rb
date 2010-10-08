require "#{File.dirname(__FILE__)}/../lib/geohex.rb"
require "pp"
include GeoHex

describe GeoHex do
  before(:all) do
    @test_ll2hex = []
    @test_hex2ll = []
    File.open("#{File.dirname(__FILE__)}/testdata_ll2hex.txt").read.each_line do |l|
      if l.slice(0,1) != "#"
        d = l.strip.split(',')
        @test_ll2hex << [d[0].to_f, d[1].to_f, d[2].to_i, d[3]]
      end
    end
    File.open("#{File.dirname(__FILE__)}/testdata_hex2ll.txt").read.each_line do |l|
      if l.slice(0,1) != "#"
        d = l.strip.split(',')
        @test_hex2ll << [d[0],d[1].to_f, d[2].to_f,d[3].to_i]
      end
    end
  end  
  
  it "should throw error if parameters is not valid" do
    lambda { GeoHex::Zone.encode() }.should raise_error(ArgumentError) # no parameters
    lambda { GeoHex::Zone.encode(-86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex::Zone.encode(86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex::Zone.encode(85,181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex::Zone.encode(-85,-181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex::Zone.encode(0,180,-1) }.should raise_error(ArgumentError) # invalid level
    lambda { GeoHex::Zone.encode(0,-180,25) }.should raise_error(ArgumentError) # invalid level
  end
  it "should convert coordinates to geohex code" do
    # correct answers (you can obtain this test variables from jsver_test.html )
    @test_ll2hex.each do |v|
      GeoHex::Zone.encode(v[0],v[1],v[2]).should == v[3]
    end
    
  end
  it "should convert geohex to coordinates " do
    # correct answers (you can obtain this test variables from jsver_test.html )
    @test_hex2ll.each do |v|
      GeoHex::Zone.decode(v[0]).should == [v[1],v[2],v[3]]
    end
  end

  it "should return instance from coordinates " do
    GeoHex::Zone.new(35.647401,139.716911,12).code.should == 'mbas1eT'
  end

  it "should raise error if instancing with nil data " do
    lambda { GeoHex::Zone.new }.should raise_error(ArgumentError)
  end

  it "should return instance from hexcode " do
    geohex = GeoHex::Zone.new('wwhnTzSWp')
    geohex.lat.should == 35.685262361266446
    geohex.lon.should == 139.76695060729983
    geohex.level.should == 22
  end
end
