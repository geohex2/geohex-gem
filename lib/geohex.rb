# -*- coding: utf-8 -*-
#
# ported from perl libraries http://svn.coderepos.org/share/lang/perl/Geo-Hex/trunk/lib/Geo/Hex.pm
# author Haruyuki Seki 
#
require 'proj4'
include Proj4


class GeoHex
  VERSION = '2.0.0'

  H_KEY       = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX'

  H_BASE = 20037508.3;
  H_DEG = Math::PI*(30/180);
  H_K = Math.tan(H_DEG);
  
  attr_accessor :code, :lat, :lon, :level

  def initialize(*params)
    if params.first.is_a?(Float)
      @lat,@lon = params[0],params[1]
      @level= params[2]||7 
      @code = GeoHex.encode(@lat,@lon,@level)
    else
      @code = params.first
      @lat,@lon,@level=GeoHex.decode(@code)
    end
    #@center_lat = 
  end

  # latlon to geohex
  def self.encode(lat,lon,level=7)
    raise ArgumentError, "latitude must be between -85 and 85" if (lat < -85 || lat > 85)
    raise ArgumentError, "longitude must be between -180 and 180" if (lon < -180 || lon > 180)
    raise ArgumentError, "level must be between 0 and 24" if (level < 0 || level > 24)
    
    h_size = H_BASE/(2**level)/3;
    lat_grid, lon_grid = self.__loc2xy_o(lat,lon)
    unit_x = 6* h_size;
    unit_y = 6* h_size*H_K;
    
    h_pos_x = (lon_grid + lat_grid/H_K)/unit_x;
    h_pos_y = (lat_grid - H_K*lon_grid)/unit_y;
    h_x_0 = h_pos_x.floor;
    h_y_0 = h_pos_y.floor;
    h_x_q = (((h_pos_x - h_x_0)*100)/100).floor;
    h_y_q = (((h_pos_y - h_y_0)*100)/100).floor;
    h_x = h_pos_x.round;
    h_y = h_pos_y.round;
    
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
    h_lon = (h_lat - h_y*unit_y)/H_K;
    z_loc_x, z_loc_y = xy2loc_o(h_lat,h_lon);
    
    if (H_BASE - h_lon <h_size)
        z_loc_x = 180;
        h_xy = h_x;
        h_x = h_y;
        h_y = h_xy;
    end

    h_x_p =0;
    h_y_p =0;
    h_x_p = 1 if(h_x<0);
    h_y_p = 1 if(h_y<0);
    h_x_abs = (h_x).abs * 2 + h_x_p;
    h_y_abs = (h_y).abs * 2 + h_y_p;
    h_x_10000 = ((h_x_abs%77600000)/1296000).floor;
    h_x_1000 = ((h_x_abs%1296000)/216000).floor;
    h_x_100 = ((h_x_abs%216000)/3600).floor;
    h_x_10 = ((h_x_abs%3600)/60).floor;
    h_x_1 = ((h_x_abs%3600)%60).floor;
    h_y_10000 = ((h_y_abs%77600000)/1296000).floor;
    h_y_1000 = ((h_y_abs%1296000)/216000).floor;
    h_y_100 = ((h_y_abs%216000)/3600).floor;
    h_y_10 = ((h_y_abs%3600)/60).floor;
    h_y_1 = ((h_y_abs%3600)%60).floor;

    h_code = h_code +h_key[h_x_10000]+h_key[h_y_10000] if(h_max >=1296000/2) ;
    h_code = h_code +h_key[h_x_1000]+h_key[h_y_1000] if(h_max >=216000/2) ;
    h_code = h_code +h_key[h_x_100]+h_key[h_y_100] if(h_max >=3600/2) ;
    h_code = h_code +h_key[h_x_10]+h_key[h_y_10] if(h_max >=60/2) ;
    h_code = h_code +h_key[h_x_1]+h_key[h_y_1];


    #zone["lon"] = z_loc_x;
    #zone["x"] = h_x;
    #zone["y"] = h_y;
    #zone["code"] = h_code;
    return h_code
  end
  
  # geohex to latlon
  def self.decode(code)
    h_y, h_x, level, unit_x, unit_y, h_k, base_x, base_y = self.__geohex2hyhx( code )
    
    h_lat = ( h_k   * ( h_x + base_x ) * unit_x + ( h_y + base_y ) * unit_y ) / 2
    h_lon = ( h_lat - ( h_y + base_y ) * unit_y ) / h_k
    lat      = h_lat / H_GRID
    lon      = h_lon / H_GRID

    return  lat, lon, level 
  end



  private

  def self.__geohex2hyhx (hexcode)

    level, c_length, code = __geohex2level( hexcode ) 

    unit_x = 6.0 * level * H_SIZE
    unit_y = 2.8 * level * H_SIZE
    h_k    = ( ( ( 1.4 / 3 ) * H_GRID ).round.to_f ) / H_GRID
    base_x = ( ( MIN_X_LON + MIN_X_LAT / h_k ) / unit_x ).floor.to_f
    base_y = ( ( MIN_Y_LAT - h_k * MIN_Y_LON ) / unit_y ).floor.to_f

    if ( c_length > 5 ) 
      h_x = H_KEY.index(code[0]) * 3600 + H_KEY.index(code[2]) * 60 + H_KEY.index(code[4])
      h_y = H_KEY.index(code[1]) * 3600 + H_KEY.index(code[3]) * 60 + H_KEY.index(code[5])
    else 
      h_x = H_KEY.index(code[0]) * 60   + H_KEY.index(code[2])
      h_y = H_KEY.index(code[1]) * 60   + H_KEY.index(code[3])
    end
    
    return h_y, h_x, level, unit_x, unit_y, h_k, base_x, base_y 
  end

  def self.__geohex2level(hexcode)
    code     = hexcode.split(//)
    c_length = code.size

    if ( c_length > 4 ) 
        level = H_KEY.index( code.shift )
        raise 'Code format is something wrong' if ( level == -1 )
        level = 60 if ( level == 0 )
    else
        level = 7
    end
    return level, c_length, code 
  end

  def self.__loc2xy_o(lat,lon) 
    projSource = Projection.new( "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" )
    projDest = Projection.new( "+proj=merc  +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 
                   +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs")
    pointSource = Point.new(lon,lat)
    pointDest = projSource.transform(projDest, pointSource);
    return pointDest.toPointObj();
  end
end
