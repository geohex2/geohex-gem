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

    def self.decode(code)
      level  = code.size
      h_size = calcHexSize(level)
      unit_x = 6 * h_size
      unit_y = 6 * h_size * H_K
      h_x    = 0
      h_y    = 0
      h_dec9 = (H_KEY.index(code[0]) * 30 + H_KEY.index(code[1])).to_s + code[2..-1]

      if  h_dec9[1] =~ /[^125]/ &&
          h_dec9[2] =~ /[^125]/
        h_dec9[0] = '7' if h_dec9[0] == "5"
        h_dec9[0] = '3' if h_dec9[0] == "1"
      end

      d9xlen = h_dec9.size
      (level+1-d9xlen).times do |n|
        h_dec9 = '0' + h_dec9
        d9xlen += 1
      end
      h_dec3 = ''

      d9xlen.times do |i|
        h_dec0 = h_dec9[i].to_i.to_s 3
        if h_dec0.size == 0
          h_dec3 << "00"
        elsif h_dec0.size == 1
          h_dec3 << "0"
        end
        h_dec3 << h_dec0.to_s
      end

      h_decx = []
      h_decy = []

      (h_dec3.size/2).times do |i|
        h_decx << h_dec3[i*2]
        h_decy << h_dec3[i*2+1]
      end

      0.upto(level) do |i|
        h_pow = 3 ** (level - i)
        if h_decx[i].to_i == 0
          h_x -= h_pow
        elsif h_decx[i].to_i == 2
          h_x += h_pow
        end

        if h_decy[i].to_i == 0
          h_y -= h_pow
        elsif h_decy[i].to_i == 2
          h_y += h_pow
        end
      end

      h_lat_y = (H_K * h_x * unit_x + h_y * unit_y) / 2
      h_lon_x = (h_lat_y - h_y * unit_y) / H_K

      h_loc = xy2loc(h_lon_x, h_lat_y)
      h_loc.lon -= 360 if h_loc.lon > 180
      h_loc.lon += 360 if h_loc.lon < -180

      return {
        :x => h_x,
        :y => h_y,
        :code => code,
        :lat => h_loc.lat,
        :lng => h_loc.lon,
      }
    end
  end
end
