# 

class GeoHex
  MIN_X_LON   = 122930; #与那国島
  MIN_X_LAT   = 24448;
  MIN_Y_LON   = 141470; ##南硫黄島
  MIN_Y_LAT   = 24228;
  
  def self.encode(lat,lon,level=7)
    raise ArgumentError, "latitude must be between -90 and 90" if (lat < -90 || lat > 90)
    raise ArgumentError, "longitude must be between -180 and 180" if (lon < -180 || lon > 180)
    raise ArgumentError, "level must be between 1 and 60" if (level < 1 || level > 60)
    
#     croak 'Level must be between 1 and 60' if ( $level !~ /^\d+$/ || $level < 1 || $level > 60 );

#     my $lon_grid = $lon * $h_grid;
#     my $lat_grid = $lat * $h_grid;
#     my $unit_x   = 6.0  * $level * $h_size;
#     my $unit_y   = 2.8  * $level * $h_size;
#     my $h_k      = ( round( (1.4 / 3) * $h_grid) ) / $h_grid;
#     my $base_x   = floor( ($min_x_lon + $min_x_lat / $h_k      ) / $unit_x);
#     my $base_y   = floor( ($min_y_lat - $h_k       * $min_y_lon) / $unit_y);
#     my $h_pos_x  = ( $lon_grid + $lat_grid / $h_k     ) / $unit_x - $base_x;
#     my $h_pos_y  = ( $lat_grid - $h_k      * $lon_grid) / $unit_y - $base_y;
#     my $h_x_0    = floor($h_pos_x);
#     my $h_y_0    = floor($h_pos_y);
#     my $h_x_q    = floor(($h_pos_x - $h_x_0) * 100) / 100;
#     my $h_y_q    = floor(($h_pos_y - $h_y_0) * 100) / 100;
#     my $h_x      = round($h_pos_x);
#     my $h_y      = round($h_pos_y);
#     if ( $h_y_q > -$h_x_q + 1 ) {
#         if( ($h_y_q < 2 * $h_x_q ) && ( $h_y_q > 0.5 * $h_x_q ) ){
#             $h_x = $h_x_0 + 1;
#             $h_y = $h_y_0 + 1;
#        }
#     } elsif ( $h_y_q < -$h_x_q + 1 ) {
#         if( ($h_y_q > (2 * $h_x_q ) - 1 ) && ( $h_y_q < ( 0.5 * $h_x_q ) + 0.5 ) ) {
#             $h_x = $h_x_0;
#             $h_y = $h_y_0;
#         }
#     }

#     return __hyhx2geohex( $h_y, $h_x, $level );
  end
end
