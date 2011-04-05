$: << File.expand_path(File.dirname(__FILE__) + "/../lib/")
require "geohex"
require "geohex/v3"
require "pp"
include GeoHex

def load_data(key)
  data_dir = File.expand_path(File.dirname(__FILE__))
  File.open("#{data_dir}/testdata_#{key}.txt").read.each_line do |l|
    if l.slice(0,1) != "#"
      d = l.strip.split(',')
      yield d
    end
  end
end

describe GeoHex do
  it "should throw error if parameters is not valid" do
    lambda { GeoHex::Zone.encode() }.should raise_error(ArgumentError) # no parameters
    lambda { GeoHex::Zone.encode(-86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex::Zone.encode(86,100,0) }.should raise_error(ArgumentError) # invalid latitude
    lambda { GeoHex::Zone.encode(85,181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex::Zone.encode(-85,-181,0) }.should raise_error(ArgumentError) # invalid longitude
    lambda { GeoHex::Zone.encode(0,180,-1) }.should raise_error(ArgumentError) # invalid level
    lambda { GeoHex::Zone.encode(0,-180,25) }.should raise_error(ArgumentError) # invalid level
  end

  it "should convert coordinates to geohex code version 2" do
    # correct answers (you can obtain this test variables from jsver_test.html )
    load_data(:v2_encode) do |d|
      lat, lng, level, geohex = d[0].to_f, d[1].to_f, d[2].to_i, d[3]
      GeoHex::Zone.encode(lat, lng, level).should == geohex
    end
  end

  it "should convert geohex to coordinates version 2" do
    # correct answers (you can obtain this test variables from jsver_test.html )
    load_data(:v2_decode) do |d|
      geohex, lat, lng, level = d[0],d[1].to_f, d[2].to_f,d[3].to_i
      GeoHex::Zone.decode(geohex).should == [lat,lng,level]
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

  context GeoHex::V3 do
    it "should return encode from coordinates to hexcode in V3" do
      lat, lng, level = 33.35137950146622, 135.6104480957031, 0
      GeoHex::V3.encode(lat, lng, level)[:code].should == "XM"
    end

    it "should convert coordinates to geohex code version V3" do
      load_data(:v3_encode) do |d|
        lat, lng, level, geohex = d[0].to_f, d[1].to_f, d[2].to_i, d[3]
        GeoHex::V3.encode(lat, lng, level)[:code].should == geohex
      end
    end

    it "should return decode from hexcode to coordinates in V3" do
      lat, lng, level = 32.70505659484853,140,0
      coordinates = GeoHex::V3.decode("XM")
      coordinates[:lat].should == lat
      coordinates[:lng].should == lng
      coordinates[:level].should == level
    end

    it "should convert coordinates to geohex code version V3" do
      load_data(:v3_decode) do |d|
        lat, lng, level, geohex = d[0].to_f, d[1].to_f, d[2].to_i, d[3]
        coordinates = GeoHex::V3.decode(geohex)
        coordinates[:lat].should == lat
        coordinates[:lng].should == lng
      end
    end
  end
end
