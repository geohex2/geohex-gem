module GeoHex
  module V3
    H_KEY = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    def self.calcHexSize(level)
      H_BASE/(3**(level+1))
    end

    def self.loc2xy(_lon,_lat)
      x=_lon*H_BASE/180;
      y= Math.log(Math.tan((90+_lat)*Math::PI/360)) / (Math::PI / 180 );
      y= y * H_BASE / 180;
      return OpenStruct.new("x"=>x, "y"=>y);
    end

    def self.xy2loc(_x,_y)
      lon=(_x/H_BASE)*180;
      lat=(_y/H_BASE)*180;
    lat=180.0/Math::PI*(2.0*Math.atan(Math.exp(lat*Math::PI/180))-Math::PI/2);
      return OpenStruct.new("lon" => lon,"lat" => lat);
    end

    def self.encode(lat,lng,level)
      level   += 2
      h_size   = calcHexSize(level)
      z_xy     = loc2xy(lng, lat)
      lon_grid = z_xy.x
      lat_grid = z_xy.y
      unit_x   = 6.0 * h_size
      unit_y   = 6.0 * h_size * H_K
      h_pos_x  = (lon_grid + lat_grid / H_K) / unit_x
      h_pos_y  = (lat_grid - H_K * lon_grid) / unit_y
      h_x_0    = h_pos_x.floor
      h_y_0    = h_pos_y.floor
      h_x_q    = h_pos_x - h_x_0
      h_y_q    = h_pos_y - h_y_0
      h_x      = h_pos_x.round
      h_y      = h_pos_y.round

      if h_y_q > -h_x_q + 1
        if (h_y_q < 2 * h_x_q) && (h_y_q > 0.5 * h_x_q)
          h_x = h_x_0 + 1
          h_y = h_y_0 + 1
        end
      elsif h_y_q < -h_x_q + 1
        if (h_y_q > (2 * h_x_q) - 1) && (h_y_q < (0.5 * h_x_q) + 0.5)
          h_x = h_x_0
          h_y = h_y_0
        end
      end

      h_lat = (H_K * h_x * unit_x + h_y * unit_y) / 2
      h_lon = (h_lat - h_y * unit_y) / H_K

      z_loc = xy2loc(h_lon, h_lat)
      z_loc_x = z_loc.lon
      z_loc_y = z_loc.lat

      if H_BASE - h_lon < h_size
        z_loc_x = 180
        h_xy    = h_x
        h_x     = h_y
        h_y     = h_xy
      end
      # same version 2

      h_code  = ''
      code3_x = []
      code3_y = []
      code3   = ''
      code9   = ''
      mod_x   = h_x
      mod_y   = h_y

      level.downto(0) do |i|
        h_pow = 3 ** i
        if mod_x >= (h_pow.to_f / 2).ceil
          code3_x << 2
          mod_x -= h_pow
        elsif mod_x <= -(h_pow.to_f / 2).ceil
          code3_x << 0
          mod_x += h_pow
        else
          code3_x << 1
        end

        if mod_y >= (h_pow.to_f / 2).ceil
          code3_y << 2
          mod_y -= h_pow
        elsif mod_y <= -(h_pow.to_f / 2).ceil
          code3_y <<  0
          mod_y += h_pow
        else
          code3_y << 1
        end
      end

      code3_x.zip(code3_y).each do |x,y|
        code9 = x*3+y
        h_code << code9.to_s
      end

      h_1    = h_code[0..2].to_i
      h_2    = h_code[3..-1]
      h_a1   = h_1 / 30
      h_a2   = h_1 % 30
      h_code = H_KEY[h_a1] + H_KEY[h_a2] + h_2

      ret = {
        :x => h_x,
        :y => h_y,
        :code => h_code,
        :latitude => z_loc_y,
        :longitude => z_loc_x
      }
      return ret
    end
  end
end
