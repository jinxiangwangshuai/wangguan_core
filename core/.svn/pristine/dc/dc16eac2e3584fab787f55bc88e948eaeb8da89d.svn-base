// 本js封装mqtt，依赖如下
// jQuery
// jQuery.timers
// paho-mqtt

var MYMQ = {
	isInit : false,
	mqtt : null,
	isMqttConnected : false,
	uuid : function() {
		function S4() {
	        return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
	    }
	    
	    return (S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4());
	},
	
	isNull : function(p) {
		if (p == undefined || p == null || p == '') {
			return true;
		}
		return false;
	},
}

MYMQ.opt = {
	clientId : MYMQ.uuid(),
	ip : window.document.location.hostname,
	port : 1998,
	subscribeTopic : null,
	revCallback : null,
	connectedCallback : null,
	disconnectedCallback : null,
}

MYMQ.setOption = function(opt) {
	if (!MYMQ.isNull(opt.clientId)) {
		MYMQ.opt.clientId = opt.clientId;
	}
	
	if (!MYMQ.isNull(opt.ip)) {
		MYMQ.opt.ip = opt.ip;
	}
		
	if (!MYMQ.isNull(opt.port)) {
		MYMQ.opt.port = opt.port;
	}
	
	if (!MYMQ.isNull(opt.subscribeTopic)) {
		MYMQ.opt.subscribeTopic = opt.subscribeTopic;
	}
		
	if (!MYMQ.isNull(opt.revCallback)) {
		MYMQ.opt.revCallback = opt.revCallback;
	}
			
	if (!MYMQ.isNull(opt.connectedCallback)) {
		MYMQ.opt.connectedCallback = opt.connectedCallback;
	}
	
	if (!MYMQ.isNull(opt.disconnectedCallback)) {
		MYMQ.opt.disconnectedCallback = opt.disconnectedCallback;
	}
}

MYMQ.start = function() {
	// 单例
	if (!MYMQ.isInit) {
		MYMQ.isInit = true;
	}
	else {
		return;
	}
	
	MYMQ.mqtt = new Paho.MQTT.Client(MYMQ.opt.ip, MYMQ.opt.port, MYMQ.opt.clientId);
	MYMQ.mqtt.onConnectionLost = MYMQ.mqttDisconnect;
	MYMQ.mqtt.onMessageArrived = MYMQ.mqttMsgRev;
	MYMQ.mqtt.connect({onSuccess:MYMQ.mqttConnect});
	
	// 开启个定时器，定时检测mqtt连接情况
	$("body").everyTime('3s', 'mqttCheck', function() {
		if (!MYMQ.isMqttConnected) {
			console.log("-- try to connect mqtt server --");
			MYMQ.mqtt.connect({onSuccess:MYMQ.mqttConnect});
		}
	});	
}

// mqtt 连接回调函数
MYMQ.mqttConnect = function() {
	MYMQ.isMqttConnected = true;
  	console.log("-- mqtt connected --");
    // 订阅主体
    if (typeof MYMQ.opt.subscribeTopic == 'string') {
    	MYMQ.mqtt.subscribe(MYMQ.opt.subscribeTopic);
    }
    else if (typeof MYMQ.opt.subscribeTopic == 'object') {
    	MYMQ.opt.subscribeTopic.forEach(function(item, index) {
    		MYMQ.mqtt.subscribe(item);
    	});
    }
  	
  	if (!MYMQ.isNull(MYMQ.opt.connectedCallback)) {
  		MYMQ.opt.connectedCallback();
  	}
}

// mqtt 断开回调函数
MYMQ.mqttDisconnect = function(responseObject) {
  	if (responseObject.errorCode !== 0) {
  		MYMQ.isMqttConnected = false;
  		console.log("-- mqtt disconnected --" + responseObject.errorMessage);
  	}
  	
  	if (!MYMQ.isNull(MYMQ.opt.disconnectedCallback)) {
  		MYMQ.opt.disconnectedCallback();
  	}
}

// mqtt 获得消息回调函数
MYMQ.mqttMsgRev = function(message) {
//	console.log(message.destinationName + "->onMessageArrived:"+message.payloadString);
  	if (!MYMQ.isNull(MYMQ.opt.revCallback)) {
  		MYMQ.opt.revCallback(message.destinationName, message.payloadString);
  	} 
}

MYMQ.mqttSend = function(topic, message) {
	if (!MYMQ.isMqttConnected) return;
//	console.log(topic + ":");
//	console.log(message);
	if (MYMQ.mqtt == null) return;
	if (typeof message == "object") {
		message = JSON.stringify(message);
	}
	//console.log(message);
	var sndMsg = new Paho.MQTT.Message(message);
  	sndMsg.destinationName = topic;
	MYMQ.mqtt.send(sndMsg);
}

MYMQ.publish = MYMQ.mqttSend;