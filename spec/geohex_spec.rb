require "#{File.dirname(__FILE__)}/../lib/geohex.rb"
require "pp"
include GeoHex

describe GeoHex do
  it "lat lon to xy" do
    pending
    GeoHex.__loc2xy(0,0).should == [0,0]
  end
end


describe GeoHex do
  before(:all) do
    @test_data = []
    File.open("#{File.dirname(__FILE__)}/location_data.txt").read.each_line do |l|
      if l.slice(0,1) != "#"
        d = l.strip.split(',')
        @test_data << [d[0].to_f, d[1].to_f, d[2].to_i, d[3]]
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
    @test_data.each do |v|
      GeoHex::Zone.encode(v[0],v[1],v[2]).should == v[3]
    end
    
  end
  it "should convert geohex to coordinates " do
  pending
    # correct answers (you can obtain this test variables from jsver_test.html )
    @test_data.each do |v|
      GeoHex::Zone.decode(v[3]).should == [v[0],v[1],v[2]]
    end
    
  end

  it "should return instance from coordinates " do
    GeoHex::Zone.new(35.647401,139.716911,12).code.should == 'mbas1eT'
  end

  it "should raise error if instancing with nil data " do
    lambda { GeoHex::Zone.new }.should raise_error(ArgumentError)
  end

  it "should return instance from hexcode " do
  pending
    geohex = GeoHex::Zone.new('132KpuG')
    geohex.lat.should == 35.6478085
    geohex.lon.should == 139.7173629550321
    geohex.level.should == 1

    geohex = GeoHex::Zone.new('0016C')
    geohex.lat.should == 24.305370000000003
    geohex.lon.should == 124.17423982869379
    geohex.level.should == 60

  end
end
