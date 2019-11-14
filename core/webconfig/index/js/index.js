// index.html   模块配置页面

var g_mac = 'null';
var g_ip = 'null';
var rpcc = new RPCC();

$(this).ready(function() {  
	mqttStart();
	
	$("body").everyTime('10s', 'performance', function() {
		if (g_isMqttConnected != true) {
			return;
		}
		// 获取基本信息
		var cmd = {
			action : 'get_baseinfo_all',
		}
		mqttSend('gw/common', table2json(cmd));
	});
	
	$("#netConfitBtn").on("click", function() {
		if (g_ip == 'null' || g_ip == undefined || g_ip == null || g_ip.length < 1) {
			swal("稍后再试，还没有获取到网关数据");
		}
		else {
			window.location.href = "http://" + g_ip + "/network";
		}
	});
});

// 基本信息处理
function baseInfoProcess(msg) {
	$("#version").html("系统版本 " + msg.version);
	$("#name").html(msg.name);
	var mac = msg.mac.replace(/[:]/g,"");
	mac = mac.toUpperCase();
	$("#mac").html(mac);
	$("#cpuRate").html(toDecimalStr(msg.cpu / 10) + '%');
	$("#memRate").html(toDecimalStr(msg.mem / 10) + '%');
	$("#temperature").html(toDecimalStr(msg.temp / 1000) + '℃');
	
	$("#ip").html(msg.ip);
	g_ip = msg.ip;
	$("#netmask").html(msg.netmask);
	$("#gateway").html(msg.gateway);
	$("#dns1").html(msg.dns1);
	var dns2 = msg.dns2;
	if (dns2 == undefined || dns2 == null || dns2.length < 1) {
		$("#dns2Div").hide();
	}
	else {
		$("#dns2Div").show();
		$("#dns2").html(dns2);
	}
}

// 提示信息比如警告，错误等
function headerInfoDisplay(txt1, txt2, type) {
	var html = '';
	if (type == 'success') {
		html += '<div class="alert alert-primary">';
		html += '<i class="fa fa-window-restore" aria-hidden="true"></i>';
	}
	else if (type == 'error') {
		html += '<div class="alert alert-danger">';
		html += '<i class="fa fa-exclamation-circle" aria-hidden="true"></i>';
	}
	
	html += ' <strong>' + txt1 + '</strong>' + txt2;
	html += '</div>'
	
	$("#headerInfo").html(html);
}

function number2hexstring(num, fill) {
	if (fill == null || fill == undefined) {
		return num.toString(16);
	}
	else {
		num = num.toString(16).toUpperCase();
		var len = ('' + num).length;
	    return (Array(
	        fill > len ? fill - len + 1 || 0 : 0
	    ).join(0) + num);
	}
}

function mqttconnected() {
	// 获取基本信息
	var cmd = {
		action : 'get_baseinfo_all',
	}
	mqttSend('gw/common', table2json(cmd));
}

function mqttCallback(topic, msg) {
	if (isNull(msg)) return;
	
	//console.log(topic, msg);
	
	if (topic == "s/c/rpc") {
		rpcc.process(msg);
		return;
	}
	else if (topic == "tool/notify") {
		var cmd = json2table(msg);
		if (cmd.action == "baseinfo_all_notify") {
			baseInfoProcess(cmd);
		}
	}

}

/////// mqtt 部分
function create_uuid() {
	//var uuid = "cms"+mydate.getDay()+ mydate.getHours()+ mydate.getMinutes()+mydate.getSeconds()+mydate.getMilliseconds()+ Math.round(Math.random() * 10000);

    function S4() {
        return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
    }
    
    return (S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4());
}

var g_isStoneInit = false;
var g_mqtt = null;
var g_isMqttConnected = false;
function mqttStart() {
	// 单例
	if (!g_isStoneInit) {
		g_isStoneInit = true;
	}
	else {
		return;
	}
	
	var ip = window.document.location.hostname;
	var port = 1998;
	var client_id = create_uuid();
	
	g_mqtt = new Paho.MQTT.Client(ip, port, client_id);
	g_mqtt.onConnectionLost = mqttDisconnect;
	g_mqtt.onMessageArrived = mqttMsgRev;
	g_mqtt.connect({onSuccess:mqttConnect});
	
	// 开启个定时器，定时检测mqtt连接情况
	$("body").everyTime('3s', 'mqttCheck', function() {
		if (!g_isMqttConnected) {
			console.log("-- try to connect mqtt server --");
			g_mqtt.connect({onSuccess:mqttConnect});
		}
	});
}

// mqtt 连接回调函数
function mqttConnect() {
	headerInfoDisplay('网络已连接！', '', 'success');
	g_isMqttConnected = true;
  	console.log("-- mqtt connected --");
    // 订阅主体
  	g_mqtt.subscribe('tool/notify');
  	g_mqtt.subscribe('s/c/rpc');
  	g_mqtt.subscribe('s/c/notify');
  	
  	mqttconnected();
}

// mqtt 断开回调函数
function mqttDisconnect(responseObject) {
  	if (responseObject.errorCode !== 0) {
  		headerInfoDisplay('网络已断开！', '', 'error');
  		g_isMqttConnected = false;
  		console.log("-- mqtt disconnected --" + responseObject.errorMessage);
  	}
}

// mqtt 获得消息回调函数
function mqttMsgRev(message) {
  	//console.log(message.destinationName + "->onMessageArrived:"+message.payloadString);
  	mqttCallback(message.destinationName, message.payloadString);
}

function mqttSend(topic, message) {
	if (!g_isMqttConnected) return;
	//console.log(topic + ":");
	//console.log(message);
	if (g_mqtt == null) return;
	if (typeof message == "object") {
		message = JSON.stringify(message);
	}
	var sndMsg = new Paho.MQTT.Message(message);
  	sndMsg.destinationName = topic;
	g_mqtt.send(sndMsg);
}

///////// end mqtt

function rpccSendMsg(msg) {
//	console.log("-------- send message --------");
//	console.log(msg);
	mqttSend("c/s/rpc", msg);
}

rpcc.sendFunction = rpccSendMsg;


// ------------------------------
function toDecimalStr(num) {
	return num.toFixed(1);
}