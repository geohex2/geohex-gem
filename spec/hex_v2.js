///////////[2010.0908 PROJ4を撤去、関数をloc2xy、xy2locに統合し、カンマ区切り引数に変更、xy2locの戻り値をx,y→lon,latに変更/////////
///////////[2010.0909 @antimon2さんのコードにリプレース/////////
///////////[2010.0915 getZoneByXY(x,y,level) Hex座標からZone取得関数追加/////////
///////////[2010.0915 getXYListBySteps(zone,radius) 半径指定Hexリスト取得関数)追加/////////
///////////[2010.0915 getXYListByPath(start,end) 2ゾーン間Hexリスト取得関数追加/////////
///////////[2010.0916 getSteps(start,end) 2ゾーン間ステップ数取得関数追加/////////
///////////[2010.0917 getXYListByRadius→getXYListByStepsに関数名変更/////////
///////////[2010.0917 getXYListByPath→getXYListByZonePathに関数名変更/////////
///////////[2010.0917 getXYListByCoodPath(start,end)を追加/////////
///////////[2010.0922 steps数の演算処理を修正/////////
///////////[2010.0925 エンコードロジック内1296000⇒12960000に修正/////////
///////////[2010.0928 エンコードロジック内77600000⇒777600000に修正/////////
///////////[2010.0928 関数名getXYListByCoodPath⇒getXYListByCoordPathに修正/////////
///////////[2010.0928 getXYListByCoodPathの引数にlevel追加/////////

(function (win) {	// グローバルを汚さないように関数化

// namspace GeoHex;
if (!win.GeoHex)	win.GeoHex = function(){};
// version: 2.03
GeoHex.version = "2.03";

// *** Share with all instances ***
var h_key = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
var h_base = 20037508.34;
var h_deg = Math.PI*(30/180);
var h_k = Math.tan(h_deg);

// private static
var _zoneCache = {};

// *** Share with all instances ***
// private static
function calcHexSize(level) {
	return h_base/Math.pow(2, level)/3;
}

// private class
function Zone(lat, lon, x, y, code) {
	this.lat = lat;
	this.lon = lon;
	this.x = x;
	this.y = y;
	this.code = code;
}
Zone.prototype.getLevel = function () {
	return h_key.indexOf(this.code.charAt(0));
};
Zone.prototype.getHexSize = function () {
	return calcHexSize(this.getLevel());
};
Zone.prototype.getHexCoords = function () {
	var h_lat = this.lat;
	var h_lon = this.lon;
	var h_xy = loc2xy(h_lon, h_lat);
	var h_x = h_xy.x;
	var h_y = h_xy.y;
	var h_deg = Math.tan(Math.PI * (60 / 180));
	var h_size = this.getHexSize();
	var h_top = xy2loc(h_x, h_y + h_deg *  h_size).lat;
	var h_btm = xy2loc(h_x, h_y - h_deg *  h_size).lat;

	var h_l = xy2loc(h_x - 2 * h_size, h_y).lon;
	var h_r = xy2loc(h_x + 2 * h_size, h_y).lon;
	var h_cl = xy2loc(h_x - 1 * h_size, h_y).lon;
	var h_cr = xy2loc(h_x + 1 * h_size, h_y).lon;
	return [
		{lat: h_lat, lon: h_l},
		{lat: h_top, lon: h_cl},
		{lat: h_top, lon: h_cr},
		{lat: h_lat, lon: h_r},
		{lat: h_btm, lon: h_cr},
		{lat: h_btm, lon: h_cl}
	];
};

// public static
function getZoneByLocation(lat, lon, level) {
	var h_size = calcHexSize(level);

	var z_xy = loc2xy(lon, lat);
	var lon_grid = z_xy.x;
	var lat_grid = z_xy.y;
	var unit_x = 6 * h_size;
	var unit_y = 6 * h_size * h_k;
	var h_pos_x = (lon_grid + lat_grid / h_k) / unit_x;
	var h_pos_y = (lat_grid - h_k * lon_grid) / unit_y;
	var h_x_0 = Math.floor(h_pos_x);
	var h_y_0 = Math.floor(h_pos_y);
	var h_x_q = h_pos_x - h_x_0; //桁丸め修正
	var h_y_q = h_pos_y - h_y_0;
	var h_x = Math.round(h_pos_x);
	var h_y = Math.round(h_pos_y);

	var h_max=Math.round(h_base / unit_x + h_base / unit_y);

	if (h_y_q > -h_x_q + 1) {
		if((h_y_q < 2 * h_x_q) && (h_y_q > 0.5 * h_x_q)){
			h_x = h_x_0 + 1;
			h_y = h_y_0 + 1;
		}
	} else if (h_y_q < -h_x_q + 1) {
		if ((h_y_q > (2 * h_x_q) - 1) && (h_y_q < (0.5 * h_x_q) + 0.5)){
			h_x = h_x_0;
			h_y = h_y_0;
		}
	}

	var h_lat = (h_k * h_x * unit_x + h_y * unit_y) / 2;
	var h_lon = (h_lat - h_y * unit_y) / h_k;

	var z_loc = xy2loc(h_lon, h_lat);
	var z_loc_x = z_loc.lon;
	var z_loc_y = z_loc.lat;
	if(h_base - h_lon < h_size){
		z_loc_x = 180;
		var h_xy = h_x;
		h_x = h_y;
		h_y = h_xy;
	}

	var h_x_p =0;
	var h_y_p =0;
	if (h_x < 0) h_x_p = 1;
	if (h_y < 0) h_y_p = 1;
	var h_x_abs = Math.abs(h_x) * 2 + h_x_p;
	var h_y_abs = Math.abs(h_y) * 2 + h_y_p;
//	var h_x_100000 = Math.floor(h_x_abs/777600000);
	var h_x_10000 = Math.floor((h_x_abs%777600000)/12960000);
	var h_x_1000 = Math.floor((h_x_abs%12960000)/216000);
	var h_x_100 = Math.floor((h_x_abs%216000)/3600);
	var h_x_10 = Math.floor((h_x_abs%3600)/60);
	var h_x_1 = Math.floor((h_x_abs%3600)%60);
//	var h_y_100000 = Math.floor(h_y_abs/777600000);
	var h_y_10000 = Math.floor((h_y_abs%777600000)/12960000);
	var h_y_1000 = Math.floor((h_y_abs%12960000)/216000);
	var h_y_100 = Math.floor((h_y_abs%216000)/3600);
	var h_y_10 = Math.floor((h_y_abs%3600)/60);
	var h_y_1 = Math.floor((h_y_abs%3600)%60);

	var h_code = h_key.charAt(level % 60);
//	if(h_max >=77600000/2) h_code += h_key.charAt(h_x_100000) + h_key.charAt(h_y_100000);
	if(h_max >=12960000/2) h_code += h_key.charAt(h_x_10000) + h_key.charAt(h_y_10000);
	if(h_max >=216000/2) h_code += h_key.charAt(h_x_1000) + h_key.charAt(h_y_1000);
	if(h_max >=3600/2) h_code += h_key.charAt(h_x_100) + h_key.charAt(h_y_100);
	if(h_max >=60/2) h_code += h_key.charAt(h_x_10) + h_key.charAt(h_y_10);
	h_code += h_key.charAt(h_x_1) + h_key.charAt(h_y_1);

	if (!!_zoneCache[h_code])	return _zoneCache[h_code];
	return (_zoneCache[h_code] = new Zone(z_loc_y, z_loc_x, h_x, h_y, h_code));
}

function getZoneByCode(code) {
	if (!!_zoneCache[code])	return _zoneCache[code];
	var c_length = code.length;
	var level = h_key.indexOf(code.charAt(0));
	var scl = level;
	var h_size =  calcHexSize(level);
	var unit_x = 6 * h_size;
	var unit_y = 6 * h_size * h_k;
	var h_max = Math.round(h_base / unit_x + h_base / unit_y);
	var h_x = 0;
	var h_y = 0;

/*	if (h_max >= 777600000 / 2) {
	h_x = h_key.indexOf(code.charAt(1)) * 777600000 + 
		  h_key.indexOf(code.charAt(3)) * 12960000 + 
		  h_key.indexOf(code.charAt(5)) * 216000 + 
		  h_key.indexOf(code.charAt(7)) * 3600 + 
		  h_key.indexOf(code.charAt(9)) * 60 + 
		  h_key.indexOf(code.charAt(11));
	h_y = h_key.indexOf(code.charAt(2)) * 777600000 + 
		  h_key.indexOf(code.charAt(4)) * 12960000 + 
		  h_key.indexOf(code.charAt(6)) * 216000 + 
		  h_key.indexOf(code.charAt(8)) * 3600 + 
		  h_key.indexOf(code.charAt(10)) * 60 + 
		  h_key.indexOf(code.charAt(12));
	} else
*/
	if (h_max >= 12960000 / 2) {
		h_x = h_key.indexOf(code.charAt(1)) * 12960000 + 
			  h_key.indexOf(code.charAt(3)) * 216000 + 
			  h_key.indexOf(code.charAt(5)) * 3600 + 
			  h_key.indexOf(code.charAt(7)) * 60 + 
			  h_key.indexOf(code.charAt(9));
		h_y = h_key.indexOf(code.charAt(2)) * 12960000 + 
			  h_key.indexOf(code.charAt(4)) * 216000 + 
			  h_key.indexOf(code.charAt(6)) * 3600 + 
			  h_key.indexOf(code.charAt(8)) * 60 + 
			  h_key.indexOf(code.charAt(10));
	} else if (h_max >= 216000 / 2) {
		h_x = h_key.indexOf(code.charAt(1)) * 216000 + 
			  h_key.indexOf(code.charAt(3)) * 3600 + 
			  h_key.indexOf(code.charAt(5)) * 60 + 
			  h_key.indexOf(code.charAt(7));
		h_y = h_key.indexOf(code.charAt(2)) * 216000 + 
			  h_key.indexOf(code.charAt(4)) * 3600 + 
			  h_key.indexOf(code.charAt(6)) * 60 + 
			  h_key.indexOf(code.charAt(8));
	} else if (h_max >= 3600 / 2) {
		h_x = h_key.indexOf(code.charAt(1)) * 3600 + 
			  h_key.indexOf(code.charAt(3)) * 60 + 
			  h_key.indexOf(code.charAt(5));
		h_y = h_key.indexOf(code.charAt(2)) * 3600 + 
			  h_key.indexOf(code.charAt(4)) * 60 + 
			  h_key.indexOf(code.charAt(6));
	} else if (h_max >= 60 / 2) {
		h_x = h_key.indexOf(code.charAt(1)) * 60 + 
			  h_key.indexOf(code.charAt(3));
		h_y = h_key.indexOf(code.charAt(2)) * 60 + 
			  h_key.indexOf(code.charAt(4));
	}else{
		h_x = h_key.indexOf(code.charAt(1));
		h_y = h_key.indexOf(code.charAt(2));
	}
	h_x = (h_x % 2) ? -(h_x - 1) / 2 : h_x / 2;
	h_y = (h_y % 2) ? -(h_y - 1) / 2 : h_y / 2;
	var h_lat_y = (h_k * h_x * unit_x + h_y * unit_y) / 2;
	var h_lon_x = (h_lat_y - h_y * unit_y) / h_k;

	var h_loc = xy2loc(h_lon_x, h_lat_y);
    var _r = new Zone(h_loc.lat, h_loc.lon, h_x, h_y, code)
	return (_zoneCache[code] = new Zone(h_loc.lat, h_loc.lon, h_x, h_y, code));
}

function getZoneByXY(x, y, level) {
	var scl = level;
	var h_size =  calcHexSize(level);
	var unit_x = 6 * h_size;
	var unit_y = 6 * h_size * h_k;
	var h_max = Math.round(h_base / unit_x + h_base / unit_y);
	var h_lat_y = (h_k * x * unit_x + y * unit_y) / 2;
	var h_lon_x = (h_lat_y - y * unit_y) / h_k;

	var h_loc = xy2loc(h_lon_x, h_lat_y);
	var x_p =0;
	var y_p =0;
	if (x < 0) x_p = 1;
	if (y < 0) y_p = 1;
	var x_abs = Math.abs(x) * 2 + x_p;
	var y_abs = Math.abs(y) * 2 + y_p;
//	var x_100000 = Math.floor(x_abs/777600000);
	var x_10000 = Math.floor((x_abs%777600000)/12960000);
	var x_1000 = Math.floor((x_abs%12960000)/216000);
	var x_100 = Math.floor((x_abs%216000)/3600);
	var x_10 = Math.floor((x_abs%3600)/60);
	var x_1 = Math.floor((x_abs%3600)%60);
//	var y_100000 = Math.floor(y_abs/777600000);
	var y_10000 = Math.floor((y_abs%777600000)/12960000);
	var y_1000 = Math.floor((y_abs%12960000)/216000);
	var y_100 = Math.floor((y_abs%216000)/3600);
	var y_10 = Math.floor((y_abs%3600)/60);
	var y_1 = Math.floor((y_abs%3600)%60);

	var h_code = h_key.charAt(level % 60);

//	if(h_max >=77600000/2) h_code += h_key.charAt(x_100000) + h_key.charAt(y_100000);
	if(h_max >=12960000/2) h_code += h_key.charAt(x_10000) + h_key.charAt(y_10000);
	if(h_max >=216000/2) h_code += h_key.charAt(x_1000) + h_key.charAt(y_1000);
	if(h_max >=3600/2) h_code += h_key.charAt(x_100) + h_key.charAt(y_100);
	if(h_max >=60/2) h_code += h_key.charAt(x_10) + h_key.charAt(y_10);
	h_code += h_key.charAt(x_1) + h_key.charAt(y_1);

	return (_zoneCache[h_code] = new Zone(h_loc.lat, h_loc.lon, x, y, h_code));
}

function getXYListBySteps(zone, radius) {
	var list = new Array();

	for(var i=0;i<radius;i++){
		list[i] = new Array();
	}
		
	list[0].push((zone.x) + "_" + (zone.y));
	for(var i=0;i<radius;i++){
          for(var j=0;j<radius;j++){
            if(i||j){
	      if(i>=j) list[i].push((zone.x + i) + "_" + (zone.y + j)); else list[j].push((zone.x + i) + "_" + (zone.y + j)) ;
	      if(i>=j) list[i].push((zone.x - i) + "_" + (zone.y - j)); else list[j].push((zone.x - i) + "_" + (zone.y - j)) ;
              if(i>0&&j>0&&(i+j<=radius-1)){
	        list[i+j].push((zone.x - i) + "_" + (zone.y + j));
	        list[i+j].push((zone.x + i) + "_" + (zone.y - j));
	      }
            }
          }
        }
	return (list);
}
function getXYListByCoordPath(start, end, level) {
	var zone0 = GeoHex.getZoneByLocation(start.lat, start.lon, level);
	var zone1 = GeoHex.getZoneByLocation(end.lat, end.lon, level);
        var startx = parseFloat(zone0.x);
        var starty = parseFloat(zone0.y);
        var endx = parseFloat(zone1.x);
        var endy = parseFloat(zone1.y);
        var x = endx - startx;
        var y = endy - starty;
	var list = new Array();
	var xabs = Math.abs(x);
	var yabs = Math.abs(y);
	if(xabs) var xqad = x/xabs;
	if(yabs) var yqad = y/yabs;
	var m = 0;
	if(xqad==yqad){
	    if(yabs > xabs) m = x; else m = y;
	}
	var mabs = Math.abs(m);
	var steps = xabs + yabs - mabs + 1;
	var start_xy = loc2xy(start.lon, start.lat);
	var start_x = start_xy.x;
	var start_y = start_xy.y;
	var end_xy = loc2xy(end.lon, end.lat);
	var end_x = end_xy.x;
	var end_y = end_xy.y;
	var h_size = calcHexSize(level);
	var unit_x = 6 * h_size;
	var unit_y = 6 * h_size * h_k;
	var pre_x=0;
	var pre_y=0;
	var cnt=0;

	for(var i=0;i<=steps*2;i++){
	    var lon_grid = start_x + (end_x - start_x)*i/(steps*2);
	    var lat_grid = start_y + (end_y - start_y)*i/(steps*2);
	    var h_pos_x = (lon_grid + lat_grid / h_k) / unit_x;
	    var h_pos_y = (lat_grid - h_k * lon_grid) / unit_y;
	    var h_x_0 = Math.floor(h_pos_x);
	    var h_y_0 = Math.floor(h_pos_y);
	    var h_x_q = h_pos_x - h_x_0;
	    var h_y_q = h_pos_y - h_y_0;
	    var h_x = Math.round(h_pos_x);
	    var h_y = Math.round(h_pos_y);

	    var h_max=Math.round(h_base / unit_x + h_base / unit_y);

	if (h_y_q > -h_x_q + 1) {
		if((h_y_q < 2 * h_x_q) && (h_y_q > 0.5 * h_x_q)){
			h_x = h_x_0 + 1;
			h_y = h_y_0 + 1;
		}
	} else if (h_y_q < -h_x_q + 1) {
		if ((h_y_q > (2 * h_x_q) - 1) && (h_y_q < (0.5 * h_x_q) + 0.5)){
			h_x = h_x_0;
			h_y = h_y_0;
		}
	}
	    if(pre_x!=h_x||pre_y!=h_y){
		cnt++;
		list[cnt] = new Array();
		list[cnt].push(h_x + "_" + h_y) ;
	    }
	    pre_x = h_x;
	    pre_y = h_y;    
	}

	return (list);
}
function getXYListByZonePath(start, end) {
        var x = end.x - start.x;
        var y = end.y - start.y;
	var list = new Array();
	var xabs = Math.abs(x);
	var yabs = Math.abs(y);
	if(xabs) var xqad = x/xabs;
	if(yabs) var yqad = y/yabs;
	var m = 0;
	if(xqad==yqad){
	    if(yabs > xabs) m = x; else m = y;
	}
	var mabs = Math.abs(m);
	var steps = xabs + yabs - mabs + 1;
	for(var i=0;i<steps;i++){
		list[i] = new Array();
	}
	var j = 0;
	if(m){
	  var mqad = m/mabs;
	  var pase = Math.abs(steps/m);
	  if(x){
	    for(var i=0;i<steps;i++){
	       if(i>j*pase){
	          j++;
	          list[i].push((start.x + i*mqad) + "_" + (start.y + j*mqad));
	       }else{
	          list[i].push((start.x + i*mqad) + "_" + (start.y + j*mqad));
	       }
            }
	  }else{
	    for(var i=0;i<steps;i++){
	       if(i>j*pase){
	          j++;
	          list[i].push((start.x + j*mqad) + "_" + (start.y + i*mqad));
	       }else{
	          list[i].push((start.x + j*mqad) + "_" + (start.y + i*mqad));
	       }
	    }
	  }
	}else{
          if(xabs&&yqad){
	    var pase = Math.abs(steps/xabs);
	    for(var i=0;i<steps;i++){
	       if(i>j*pase) j++;
	          list[i].push((start.x + j*xqad) + "_" + (start.y + (i-j)*yqad));
            }
	  }else if(xabs){
	    for(var i=0;i<steps;i++){
	          list[i].push((start.x + i*xqad) + "_" + (start.y));
            }
	  }else{
	    for(var i=0;i<steps;i++){
	          list[i].push((start.x) + "_" + (start.y + i*yqad));
            }
	  }
	}
	return (list);
}
function getSteps(start,end){
        var x = end.x - start.x;
        var y = end.y - start.y;
	var list = new Array();
	var xabs = Math.abs(x);
	var yabs = Math.abs(y);
	if(xabs) var xqad = x/xabs;
	if(yabs) var yqad = y/yabs;
	var m = 0;
	if(xqad==yqad){
	    if(yabs > xabs) m = x; else m = y;
	}
	var mabs = Math.abs(m);
	var steps = xabs + yabs - mabs + 1;
	return steps;
}

// private static
function loc2xy(lon, lat) {
	var x = lon * h_base / 180;
	var y = Math.log(Math.tan((90 + lat) * Math.PI / 360)) / (Math.PI / 180);
	y *= h_base / 180;
	return { x: x, y: y };
}
// private static
function xy2loc(x, y) {
	var lon = (x / h_base) * 180;
	var lat = (y / h_base) * 180;
	lat = 180 / Math.PI * (2 * Math.atan(Math.exp(lat * Math.PI / 180)) - Math.PI / 2);
	return { lon: lon, lat: lat };
}

// EXPORT
GeoHex.getZoneByLocation = getZoneByLocation;
GeoHex.getXYListBySteps = getXYListBySteps;
GeoHex.getXYListByZonePath = getXYListByZonePath;
GeoHex.getXYListByCoordPath = getXYListByCoordPath;
GeoHex.getZoneByXY = getZoneByXY;
GeoHex.getZoneByCode = getZoneByCode;
GeoHex.getSteps = getSteps;

})(this);
