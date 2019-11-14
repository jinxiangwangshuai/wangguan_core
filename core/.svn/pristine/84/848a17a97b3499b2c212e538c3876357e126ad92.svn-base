

// jquery ajax post 异步方式 json 格式
// _url post 的url
// _data post的数据，数组格式
// _success_callback   post成功的回调函数
// _error_callback  post 失败的回调函数
function post_async(_url, _data, _success_callback, _error_callback) {
	//log(_data['username']);
	$.ajax({
	url:_url,
	data:_data,
	type:"post",
	dataType:"json",
	async:true,
	success: function(data){
		_success_callback(data);
	},
	error: function(data, status, e) {
		_error_callback(data, status, e);
	   }
	});
}

function page_location(_url) {
	window.location.href = _url;
}

//////////// json converter /////////////
function table2json(t) {
	return JSON.stringify(t);
}

function json2table(j) {
	return JSON.parse(j);
}
/////////////////////////////////////////

// 深拷贝
function deepCopy(obj){
    if(typeof obj != 'object'){
        return obj;
    }
    var newobj = {};
    for ( var attr in obj) {
        newobj[attr] = deepCopy(obj[attr]);
    }
    return newobj;
}

// 数字转字符串，可以指定位数，补齐0
function number2string(num, fill) {
	if (fill == null || fill == undefined) {
		return num.toString();
	}
	else {
		var len = ('' + num).length;
	    return (Array(
	        fill > len ? fill - len + 1 || 0 : 0
	    ).join(0) + num);
	}
}

// 描述转换成时间字符串，用于显示耗时一类
function sec2string(count) {
	if (count < 1) return "00:00";
	var result = "";
	//var min = 0;
	//var sec = 0;
	if (count > 3600) {
		var hour = parseInt(count / 3600);
		result = number2string(hour, 2) + ":";
		count = count % 3600;
	}
	var min = parseInt(count / 60);
	result += number2string(min, 2) + ":";

	var sec = count % 60;
	result += number2string(sec, 2);
	return result;
}

function   stamp2str(stamp)   {
	var now = new Date(stamp*1000);
	  var   year=now.getFullYear();     
	  var   month=now.getMonth()+1;     
	  var   date=now.getDate();     
	  var   hour=now.getHours();     
	  var   minute=now.getMinutes();     
	  var   second=now.getSeconds();     
	  return  year+"-"+number2string(month, 2)+"-"+number2string(date, 2)+" "+number2string(hour, 2)+":"+number2string(minute, 2)+":"+number2string(second, 2);     
}  

function global_set(name, value) {
	localStorage.setItem(name, value);
}

function global_get(name) {
	return localStorage.getItem(name);
}

function isNull(p) {
	if (p == undefined || p == null || p == '') {
		return true;
	}
	return false;
}

function isValidIP(ip) {
    var reg = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/
    return reg.test(ip);
} 

function IEVersion() {
    var userAgent = navigator.userAgent; //取得浏览器的userAgent字符串  
    var isIE = userAgent.indexOf("compatible") > -1 && userAgent.indexOf("MSIE") > -1; //判断是否IE<11浏览器  
    var isEdge = userAgent.indexOf("Edge") > -1 && !isIE; //判断是否IE的Edge浏览器  
    var isIE11 = userAgent.indexOf('Trident') > -1 && userAgent.indexOf("rv:11.0") > -1;
    if(isIE) {
        var reIE = new RegExp("MSIE (\\d+\\.\\d+);");
        reIE.test(userAgent);
        var fIEVersion = parseFloat(RegExp["$1"]);
        if(fIEVersion == 7) {
            return 7;
        } else if(fIEVersion == 8) {
            return 8;
        } else if(fIEVersion == 9) {
            return 9;
        } else if(fIEVersion == 10) {
            return 10;
        } else {
            return 6;//IE版本<=7
        }   
    } else if(isEdge) {
        return 'edge';//edge
    } else if(isIE11) {
        return 11; //IE11  
    }else{
        return -1;//不是ie浏览器
    }
}

//参数arr的值分别为[r,g,b]
function rgbToHsv(arr) {
    var h = 0, s = 0, v = 0;
    var r = arr[0], g = arr[1], b = arr[2];
    arr.sort(function (a, b) {
        return a - b;
    })
    var max = arr[2]
    var min = arr[0];
    v = max / 255;
    if (max === 0) {
        s = 0;
    } else {
        s = 1 - (min / max);
    }
    if (max === min) {
        h = 0;//事实上，max===min的时候，h无论为多少都无所谓
    } else if (max === r && g >= b) {
        h = 60 * ((g - b) / (max - min)) + 0;
    } else if (max === r && g < b) {
        h = 60 * ((g - b) / (max - min)) + 360
    } else if (max === g) {
        h = 60 * ((b - r) / (max - min)) + 120
    } else if (max === b) {
        h = 60 * ((r - g) / (max - min)) + 240
    }
    h = parseInt(h);
    s = parseInt(s * 100);
    v = parseInt(v * 100);
    return [h, s, v]
}

//参数arr的3个值分别对应[h, s, v]
function hsvToRgb(arr) {
    var h = arr[0], s = arr[1], v = arr[2];
    s = s / 100;
    v = v / 100;
    var r = 0, g = 0, b = 0;
    var i = parseInt((h / 60) % 6);
    var f = h / 60 - i;
    var p = v * (1 - s);
    var q = v * (1 - f * s);
    var t = v * (1 - (1 - f) * s);
    switch (i) {
        case 0:
            r = v; g = t; b = p;
            break;
        case 1:
            r = q; g = v; b = p;
            break;
        case 2:
            r = p; g = v; b = t;
            break;
        case 3:
            r = p; g = q; b = v;
            break;
        case 4:
            r = t; g = p; b = v;
            break;
        case 5:
            r = v; g = p; b = q;
            break;
        default:
            break;
    }
    r = parseInt(r * 255.0)
    g = parseInt(g * 255.0)
    b = parseInt(b * 255.0)
    return [r, g, b];
}
