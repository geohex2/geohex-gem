var h_stamp = new Array();
var h_key = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
var h_base = 20037508.3;
var h_deg = Math.PI*(30/180);
var h_k = Math.tan(h_deg);
var h_size;
var h_range=21;
var h_x;
var h_y;
var h_lon;
var h_lat;

var projHash = {};
function initProj4js() {
  for (var def in Proj4js.defs) {
    projHash[def] = new Proj4js.Proj(def);    //create a Proj for each definition
  }  // for
}
function setHexSize(_level){
  level = _level;
  return h_base/Math.pow(2,_level)/3;
}

function getZoneByLocation( _lat, _lon, _level){
    var hex_pos;
    h_size = setHexSize(_level);
    var zone = new Array();


    var locxy = ""+_lon + "," + _lat;
    var z_xy = loc2xy_o(locxy);

    var lon_grid = z_xy.x;
    var lat_grid = z_xy.y;
    var unit_x = 6* h_size;
    var unit_y = 6* h_size*h_k;
    
    var h_pos_x = (lon_grid + lat_grid/h_k)/unit_x;
    var h_pos_y = (lat_grid - h_k*lon_grid)/unit_y;
    var h_x_0 = Math.floor(h_pos_x);
    var h_y_0 = Math.floor(h_pos_y);
    var h_x_q = Math.floor((h_pos_x - h_x_0)*100)/100;
    var h_y_q = Math.floor((h_pos_y - h_y_0)*100)/100;
    var h_x = Math.round(h_pos_x);
    var h_y = Math.round(h_pos_y);

    var h_max=Math.round(h_base/unit_x + h_base/unit_y);

    if(h_y_q>-h_x_q+1){
        if((h_y_q<2*h_x_q)&&(h_y_q>0.5*h_x_q)){
            h_x = h_x_0 + 1;
            h_y = h_y_0 + 1;
        }
    }else if(h_y_q<-h_x_q+1){
        if((h_y_q>(2*h_x_q)-1)&&(h_y_q<(0.5*h_x_q)+0.5)){
            h_x = h_x_0;
            h_y = h_y_0;
        }
    }
    var h_lat = (h_k*h_x*unit_x + h_y*unit_y)/2;
    var h_lon = (h_lat - h_y*unit_y)/h_k;

    var xyloc = ""+h_lon + "," + h_lat;
    var z_loc = xy2loc_o(xyloc);
    var z_loc_x = z_loc.x;
    var z_loc_y = z_loc.y;
    if(h_base - h_lon <h_size){
       z_loc_x = 180;
       var h_xy = h_x;
       h_x = h_y;
       h_y = h_xy;
    }

    var h_x_p =0;
    var h_y_p =0;
    if(h_x<0) h_x_p = 1;
    if(h_y<0) h_y_p = 1;
    var h_x_abs = Math.abs(h_x)*2+h_x_p;
    var h_y_abs = Math.abs(h_y)*2+h_y_p;
//    var h_x_100000 = Math.floor(h_x_abs/77600000);
    var h_x_10000 = Math.floor((h_x_abs%77600000)/1296000);
    var h_x_1000 = Math.floor((h_x_abs%1296000)/216000);
    var h_x_100 = Math.floor((h_x_abs%216000)/3600);
    var h_x_10 = Math.floor((h_x_abs%3600)/60);
    var h_x_1 = Math.floor((h_x_abs%3600)%60);
//    var h_y_100000 = Math.floor(h_y_abs/77600000);
    var h_y_10000 = Math.floor((h_y_abs%77600000)/1296000);
    var h_y_1000 = Math.floor((h_y_abs%1296000)/216000);
    var h_y_100 = Math.floor((h_y_abs%216000)/3600);
    var h_y_10 = Math.floor((h_y_abs%3600)/60);
    var h_y_1 = Math.floor((h_y_abs%3600)%60);

    var h_code = "" + h_key.charAt(level%60);

//    if(h_max >=77600000/2) h_code = h_code +h_key.charAt(h_x_100000)+h_key.charAt(h_y_100000);
    if(h_max >=1296000/2) h_code = h_code +h_key.charAt(h_x_10000)+h_key.charAt(h_y_10000);
    if(h_max >=216000/2) h_code = h_code +h_key.charAt(h_x_1000)+h_key.charAt(h_y_1000);
    if(h_max >=3600/2) h_code = h_code +h_key.charAt(h_x_100)+h_key.charAt(h_y_100);
    if(h_max >=60/2) h_code = h_code +h_key.charAt(h_x_10)+h_key.charAt(h_y_10);
    h_code = h_code +h_key.charAt(h_x_1)+h_key.charAt(h_y_1);


    zone["lat"] = z_loc_y;
    zone["lon"] = z_loc_x;
    zone["x"] = h_x;
    zone["y"] = h_y;
    zone["code"] = h_code;
    return zone;
}

function getZoneByCode(_code){
    var c_length = _code.length;
    var zone = new Array();
    level = h_key.indexOf(_code.charAt(0));
    scl = level;
    var h_base = 20037508.3;
    h_size =  h_base/Math.pow(2,level)/3;
    var unit_x = 6* h_size;
    var unit_y = 6* h_size*h_k;
    var h_max=Math.round(h_base/unit_x + h_base/unit_y);
    h_x=0;
    h_y=0;

/*    if(h_max >=77600000/2){
      h_x = h_key.indexOf(_code.charAt(1))*77600000+h_key.indexOf(_code.charAt(3))*1296000+h_key.indexOf(_code.charAt(5))*216000+h_key.indexOf(_code.charAt(7))*3600+h_key.indexOf(_code.charAt(9))*60+h_key.indexOf(_code.charAt(11));
      h_y = h_key.indexOf(_code.charAt(3))*77600000+h_key.indexOf(_code.charAt(4))*1296000+h_key.indexOf(_code.charAt(6))*216000+h_key.indexOf(_code.charAt(8))*3600+h_key.indexOf(_code.charAt(10))*60+h_key.indexOf(_code.charAt(12));
    }else
*/
     if(h_max >=1296000/2){
      h_x = h_key.indexOf(_code.charAt(1))*1296000+h_key.indexOf(_code.charAt(3))*216000+h_key.indexOf(_code.charAt(5))*3600+h_key.indexOf(_code.charAt(7))*60+h_key.indexOf(_code.charAt(9));
      h_y = h_key.indexOf(_code.charAt(2))*1296000+h_key.indexOf(_code.charAt(4))*216000+h_key.indexOf(_code.charAt(6))*3600+h_key.indexOf(_code.charAt(8))*60+h_key.indexOf(_code.charAt(10));
    }else if(h_max >=216000/2){
      h_x = h_key.indexOf(_code.charAt(1))*216000+h_key.indexOf(_code.charAt(3))*3600+h_key.indexOf(_code.charAt(5))*60+h_key.indexOf(_code.charAt(7));
      h_y = h_key.indexOf(_code.charAt(2))*216000+h_key.indexOf(_code.charAt(4))*3600+h_key.indexOf(_code.charAt(6))*60+h_key.indexOf(_code.charAt(8));
    }else if(h_max >=3600/2){
      h_x = h_key.indexOf(_code.charAt(1))*3600+h_key.indexOf(_code.charAt(3))*60+h_key.indexOf(_code.charAt(5));
      h_y = h_key.indexOf(_code.charAt(2))*3600+h_key.indexOf(_code.charAt(4))*60+h_key.indexOf(_code.charAt(6));
    }else if(h_max >=60/2){
      h_x = h_key.indexOf(_code.charAt(1))*60+h_key.indexOf(_code.charAt(3));
      h_y = h_key.indexOf(_code.charAt(2))*60+h_key.indexOf(_code.charAt(4));
    }else{
      h_x = h_key.indexOf(_code.charAt(1));
      h_y = h_key.indexOf(_code.charAt(2));
    }
//alert('ZONE: ' + _code);

//    var h_lat_y = (h_k*(h_x - Math.floor(h_max/2) -1)*unit_x + (h_y - Math.floor(h_max/2) -1)*unit_y)/2;
//    var h_lon_x = (h_lat_y - (h_y - Math.floor(h_max/2) -1)*unit_y)/h_k;

    h_x=(h_x%2)?-(h_x-1)/2:h_x/2;
    h_y=(h_y%2)?-(h_y-1)/2:h_y/2;
    var h_lat_y = (h_k*h_x*unit_x + h_y*unit_y)/2;
    var h_lon_x = (h_lat_y - h_y*unit_y)/h_k;

    var h_lon = xy2loc_o(h_lon_x + "," + h_lat_y).x;
    var h_lat = xy2loc_o(h_lon_x + "," + h_lat_y).y;
    zone["code"] = _code;
    zone["lat"] = h_lat;
    zone["lon"] = h_lon;
    zone["x"] = h_x;
    zone["y"] = h_y;
    return zone;
}

function drawHex(_zone,_linecolor,_fillcolor,_popinfo){
//   document.getElementById("cnt_zone").innerHTML = _zone.code;
    if(h_stamp[_zone.code] != 1){

    var locxy = ""+_zone.lon + "," + _zone.lat;
    var h_lat =_zone.lat;
    var h_lon =_zone.lon;
    var h_xy = loc2xy_o(locxy);
    var h_x = h_xy.x;
    var h_y = h_xy.y;
    var h_deg = Math.tan(Math.PI*(60/180));
    var h_top = xy2loc_o(h_x+","+(h_y + h_deg* h_size)).y;
    var h_btm = xy2loc_o(h_x+","+(h_y - h_deg* h_size)).y;


    if((h_btm> 85.051128514)||(h_top<-85.051128514)) return;

    var h_l = xy2loc_o((h_x - 2* h_size)+","+h_y).x;
    var h_r = xy2loc_o((h_x + 2* h_size)+","+h_y).x;
    var h_cl = xy2loc_o((h_x - 1* h_size)+","+h_y).x;
    var h_cr = xy2loc_o((h_x + 1* h_size)+","+h_y).x;

    var triangleCoords = [
        new google.maps.LatLng(h_lat,h_l),
        new google.maps.LatLng(h_top,h_cl),
        new google.maps.LatLng(h_top,h_cr),
        new google.maps.LatLng(h_lat,h_r),
        new google.maps.LatLng(h_btm,h_cr),
        new google.maps.LatLng(h_btm,h_cl),
        new google.maps.LatLng(h_lat,h_l)
		  ];

    // Construct the polygon
    hexPolygon = new google.maps.Polygon({
      paths: triangleCoords,
      strokeColor: _linecolor,
      strokeOpacity: 1,
      strokeWeight: 1,
      fillColor: _fillcolor,
      fillOpacity: 0.1
    });

   hexPolygon.setMap(map);

        h_stamp[_zone.code] = 1;
    }

        if(_popinfo){
            if(infowin) infowin.close();
            var myHtml = "[ZONE] <a href='/"+_zone.code+"/'>"+_zone.code+"</a>";            url="http://twitter.com/?status=http://geohex.net/"+_zone.code;

            myHtml += "<br />[LEVEL] "+level;
            myHtml += "<br />[X,Y] "+_zone.x+"/"+_zone.y;
            myHtml += "<div id='sendURL' style='height:24px;width:24px;background:url(/tw_on.png) no-repeat center center;border:1px solid #BCBCBC;float:right;cursor:pointer; -webkit-border-radius: 3px; -moz-border-radius: 3px' onclick='window.open(decodeHTML(url))'></div></div>";
            var point = new google.maps.LatLng(_zone.lat,_zone.lon);
            infowin = new google.maps.InfoWindow(
              { content: myHtml,
                position: point
              });
            infowin.open(map);

         }
            google.maps.event.addListener(hexPolygon,"click",function(event){
            var zone = getZoneByLocation(event.latLng.lat(), event.latLng.lng(), level);
            drawHex(zone ,"#FF0000","#FF8a00",1);
/*
            if(infowin) infowin.close();
            var point = new google.maps.LatLng(_zone.lat,_zone.lon);
            infowin = new google.maps.InfoWindow(
              { content: myHtml,
                position: point
              });
            infowin.open(map);
*/
            });
 
}
function decodeHTML(str) {
    return str.replace(/&nbsp;/ig," ").replace(/&quot;/ig,"\"").replace(/&gt;/ig,">").replace(/&lt;/ig,"<").replace(/&amp;/ig,"&");
}

function loc2xy_s(point) {
  projSource = projHash['WGS84'];
  projDest = projHash['GOOGLE'];
  var pointSource = new Proj4js.Point(point);
  var pointDest = Proj4js.transform(projSource, projDest, pointSource);
  return pointDest.toShortString();
}
function loc2xy_o(point) {
  projSource = projHash['WGS84'];
  projDest = projHash['GOOGLE'];
  var pointSource = new Proj4js.Point(point);
  var pointDest = Proj4js.transform(projSource, projDest, pointSource);
  return pointDest.toPointObj();
}
function xy2loc_s(point) {
  projSource = projHash['GOOGLE'];
  projDest = projHash['WGS84'];
  var pointSource = new Proj4js.Point(point);
  var pointDest = Proj4js.transform(projSource, projDest, pointSource);
  return pointDest.toShortString();
}
function xy2loc_o(point) {
  projSource = projHash['GOOGLE'];
  projDest = projHash['WGS84'];
  var pointSource = new Proj4js.Point(point);
  var pointDest = Proj4js.transform(projSource, projDest, pointSource);
  return pointDest.toPointObj();
}