# -*- coding: utf-8 -*-
#
# ported from js libraries http://geohex.net
# author Haruyuki Seki 
#
require 'rubygems'
require 'ostruct'

module GeoHex
  VERSION = '3.0.0'

  H_KEY = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  H_BASE = 20037508.34;
  H_DEG = Math::PI*(30.0/180);
  H_K = Math.tan(H_DEG);
  R=20037508.34
  
  class Zone
    attr_accessor :code, :lat, :lon, :x, :y
    def initialize(*params)
      raise ArgumentError, "latlng or code is needed" if params.size == 0
      if params.first.is_a?(Float)
        @lat,@lon = params[0],params[1]
        @level= params[2]||7 
        @code= GeoHex::Zone.encode(@lat,@lon,@level)
      else
        @code = params.first
        @lat,@lon,@level=GeoHex::Zone.decode(@code)
      end
    end
    
    def self.calcHexSize(level)
      H_BASE/(2**level)/3
    end
    
    def level
      H_KEY.index(code[0,1])
    end
    def hexSize
      self.calcHexSize(self.level)
    end
    
    def hexCoords
      h_lat = self.lat;
      h_lon = self.lon;
      h_xy = GeoHex::Zone.loc2xy(h_lon, h_lat);
      h_x = h_xy.x
      h_y = h_xy.y
      h_deg = Math.tan(Math::PI * (60 / 180));
      h_size = self.hexSize
      h_top = xy2loc(h_x, h_y + h_deg *  h_size).lat;
      h_btm = xy2loc(h_x, h_y - h_deg *  h_size).lat;
      
      h_l = xy2loc(h_x - 2 * h_size, h_y).lon;
      h_r = xy2loc(h_x + 2 * h_size, h_y).lon;
      h_cl = xy2loc(h_x - 1 * h_size, h_y).lon;
      h_cr = xy2loc(h_x + 1 * h_size, h_y).lon;
      
      [
       {:lat => h_lat, :lon => h_l},
       {:lat => h_top, :lon => h_cl},
       {:lat => h_top, :lon => h_cr},
       {:lat => h_lat, :lon => h_r},
       {:lat => h_btm, :lon => h_cr},
       {:lat => h_btm, :lon => h_cl}
      ]
    end
    
    # latlon to geohex
    def self.encode(lat,lon,level=7)
      raise ArgumentError, "latitude must be double" unless (lat.is_a?(Numeric))
      raise ArgumentError, "latitude must be between -85 and 85" if (lat < -85.1 || lat > 85.1)
      raise ArgumentError, "latitude must be between -85 and 85" if (lat < -85.1 || lat > 85.1)
      raise ArgumentError, "longitude must be between -180 and 180" if (lon < -180 || lon > 180)
      raise ArgumentError, "level must be between 0 and 24" if (level < 0 || level > 24)
      
      h_size = self.calcHexSize(level)
      z_xy = loc2xy(lon,lat)
      lon_grid = z_xy.x
      lat_grid = z_xy.y
      unit_x = 6.0* h_size;
      unit_y = 6.0* h_size*H_K;
      h_pos_x = (lon_grid + lat_grid / H_K) / unit_x;
      h_pos_y = (lat_grid - H_K*lon_grid) / unit_y;

      h_x_0 = h_pos_x.floor;
      h_y_0 = h_pos_y.floor;
      h_x_q = h_pos_x - h_x_0
      h_y_q = h_pos_y - h_y_0
      h_x = h_pos_x.round;
      h_y = h_pos_y.round;
      
      h_max=(H_BASE/unit_x + H_BASE/unit_y).round;
      
      if ( h_y_q > -h_x_q + 1 ) 
        if ( h_y_q < (2 * h_x_q ) and  h_y_q > (0.5 * h_x_q ) )
          h_x = h_x_0 + 1
          h_y = h_y_0 + 1
        end
      elsif ( h_y_q < -h_x_q + 1 ) 
        if ( (h_y_q > (2 * h_x_q ) - 1 ) && ( h_y_q < ( 0.5 * h_x_q ) + 0.5 ) ) 
          h_x = h_x_0
          h_y = h_y_0
        end
      end
    
      h_lat = (H_K * h_x * unit_x + h_y * unit_y) / 2;
      h_lon = (h_lat - h_y * unit_y)/H_K;
      
      z_loc = xy2loc(h_lon,h_lat)
      z_loc_x = z_loc.lon
      z_loc_y = z_loc.lat
      
      if (H_BASE - h_lon <h_size)
        z_loc_x = 180.0;
        h_xy = h_x;
        h_x = h_y;
        h_y = h_xy;
      end
      
      h_x_p = (h_x<0) ? 1 : 0;
      h_y_p = (h_y<0) ? 1 : 0;
      h_x_abs = ((h_x).abs * 2 + h_x_p).to_f;
      h_y_abs = ((h_y).abs * 2 + h_y_p).to_f;
      h_x_10000 = ((h_x_abs%777600000)/12960000).floor;
      h_x_1000 = ((h_x_abs%12960000)/216000).floor;
      h_x_100 = ((h_x_abs%216000)/3600).floor;
      h_x_10 = ((h_x_abs%3600)/60).floor;
      h_x_1 = ((h_x_abs%3600)%60).floor;
      h_y_10000 = ((h_y_abs%77600000)/12960000).floor;
      h_y_1000 = ((h_y_abs%12960000)/216000).floor;
      h_y_100 = ((h_y_abs%216000)/3600).floor;
      h_y_10 = ((h_y_abs%3600)/60).floor;
      h_y_1 = ((h_y_abs%3600)%60).floor;
      h_code = H_KEY[level % 60, 1];
      h_code += H_KEY[h_x_10000, 1]+H_KEY[h_y_10000, 1] if(h_max >=12960000/2) ;
      h_code += H_KEY[h_x_1000, 1]+H_KEY[h_y_1000, 1] if(h_max >=216000/2) ;
      h_code += H_KEY[h_x_100, 1]+H_KEY[h_y_100, 1] if(h_max >=3600/2) ;
      h_code += H_KEY[h_x_10, 1]+H_KEY[h_y_10, 1] if(h_max >=60/2) ;
      h_code += H_KEY[h_x_1, 1]+H_KEY[h_y_1, 1];
      
      return h_code;
    end
  
    # geohex to latlon
    def self.decode(code)
      c_length = code.length;
      level = H_KEY.index(code[0,1]);
      scl = level;
      h_size =  self.calcHexSize(level);
      unit_x = 6.0 * h_size;
      unit_y = 6.0 * h_size * H_K;
      h_max = (H_BASE / unit_x + H_BASE / unit_y).round;
      h_x = 0;
      h_y = 0;

      if (h_max >= 12960000 / 2) 
        h_x = H_KEY.index(code[1,1]) * 12960000 + 
          H_KEY.index(code[3,1]) * 216000 + 
          H_KEY.index(code[5,1]) * 3600 + 
          H_KEY.index(code[7,1]) * 60 + 
          H_KEY.index(code[9,1]);
        h_y = H_KEY.index(code[2,1]) * 12960000 + 
          H_KEY.index(code[4,1]) * 216000 + 
          H_KEY.index(code[6,1]) * 3600 + 
          H_KEY.index(code[8,1]) * 60 + 
          H_KEY.index(code[10,1]);
      elsif (h_max >= 216000 / 2) 
        h_x = H_KEY.index(code[1,1]) * 216000 + 
          H_KEY.index(code[3,1]) * 3600 + 
          H_KEY.index(code[5,1]) * 60 + 
          H_KEY.index(code[7,1]);
        h_y = H_KEY.index(code[2,1]) * 216000 + 
          H_KEY.index(code[4,1]) * 3600 + 
          H_KEY.index(code[6,1]) * 60 + 
          H_KEY.index(code[8,1]);
      elsif (h_max >= 3600 / 2) 
        h_x = H_KEY.index(code[1,1]) * 3600 + 
          H_KEY.index(code[3,1]) * 60 + 
          H_KEY.index(code[5,1]);
		h_y = H_KEY.index(code[2,1]) * 3600 + 
          H_KEY.index(code[4,1]) * 60 + 
          H_KEY.index(code[6,1]);
      elsif (h_max >= 60 / 2) 
        h_x = H_KEY.index(code[1,1]) * 60 + 
          H_KEY.index(code[3,1]);
        h_y = H_KEY.index(code[2,1]) * 60 + 
          H_KEY.index(code[4,1]);
      else
        h_x = H_KEY.index(code[1,1]);
        h_y = H_KEY.index(code[2,1]);
      end
      h_x = (h_x % 2 == 1) ? -(h_x - 1) / 2 : h_x / 2;
      h_y = (h_y % 2 == 1) ? -(h_y - 1) / 2 : h_y / 2;

      h_lat_y = (H_K * h_x * unit_x + h_y * unit_y) / 2;
      h_lon_x = (h_lat_y - h_y * unit_y) / H_K;

      h_loc = xy2loc(h_lon_x, h_lat_y);
      return [h_loc.lat, h_loc.lon, level]
    end
  end
    
  class << Zone
    def loc2xy(_lon,_lat) 
      x=_lon*H_BASE/180;
      y= Math.log(Math.tan((90+_lat)*Math::PI/360)) / (Math::PI / 180 );
      y= y * H_BASE / 180;
      return OpenStruct.new("x"=>x, "y"=>y);
    end
    
    def xy2loc(_x,_y) 
      lon=(_x/H_BASE)*180;
      lat=(_y/H_BASE)*180;
    lat=180.0/Math::PI*(2.0*Math.atan(Math.exp(lat*Math::PI/180))-Math::PI/2);
      return OpenStruct.new("lon" => lon,"lat" => lat);
    end
  end
end

require "geohex/v3"
