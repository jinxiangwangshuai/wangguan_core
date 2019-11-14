//http://mishengqiang.com/sweetalert2/

var g_status = null;
$(this).ready(function() {
	$("#setNameBtn").on('click', setName);
	$("#setNetworkBtn").on('click', setNetwork);
	
	var opt = {
		subscribeTopic : 'tool/notify',
		revCallback : mqttRev,
		connectedCallback : mqttConnected,
	}
	MYMQ.setOption(opt);
	MYMQ.start();
});

function setName() {
	var name = $("#name").val();
	if (isNull(name) || name == ' ') {
		swal({
			text: '名称不能为空！',
			type: 'warning',
			width: '300px',
		});
	}

	if (g_status != null && g_status.name == name) {
		swal({
			text: '您没有修改名称',
			type: 'info',
			width: '300px',
		});
		return;
	}

	var msg = {
		action : 'set_name',
		name : name,
	}
	MYMQ.publish('gw/common', msg);
	
	swal({
		text: '设置成功',
		type: 'info',
		width: '300px',
	});
}

function setNetwork() {
	var msg = {
		ip: $("#ip").val(),
		netmask: $("#mask").val(),
		gateway: $("#gw").val(),
		dns1: $("#dns1").val(),
		dns2: $("#dns2").val(),
	}
	
	if (isNull(msg.ip)) {
		swal({
			text: 'IP地址不能为空！',
			type: 'warning',
			width: '300px',
		});
		return;
	}
	
	if (!isValidIP(msg.ip)) {
		swal({
			text: '请输入正确的IP地址！',
			type: 'warning',
			width: '300px',
		});
		return;
	}
	
	if (isNull(msg.netmask)) {
		swal({
			text: '子网掩码不能为空！',
			type: 'warning',
			width: '300px',
		});
		return;
	}
	
	if (!isValidIP(msg.netmask)) {
		swal({
			text: '请输入正确的子网掩码！',
			type: 'warning',
			width: '300px',
		});
		return;
	}
	
	if (isNull(msg.gateway)) {
		swal({
			text: '网关地址不能为空！',
			type: 'warning',
			width: '300px',
		});
		return;
	}
	
	if (!isValidIP(msg.gateway)) {
		swal({
			text: '请输入正确的网关地址！',
			type: 'warning',
			width: '300px',
		});
		return;
	}
	
	if (isNull(msg.dns1)) {
		msg.dns1 = msg.gateway;
		swal({
			text: 'DNS1不建议为空，如果您不清楚填写什么，可以填写上面网关地址！',
			type: 'warning',
			width: '300px',
		});
		return;
	}
	else{
		if (!isValidIP(msg.dns1)) {
			swal({
				text: '请输入正确的DNS1！',
				type: 'warning',
				width: '300px',
			});
			return;
		}
	}
	
	if (!isNull(msg.dns2)) {
		if (!isValidIP(msg.dns2)) {
			swal({
				text: '请输入正确的DNS2！',
				type: 'warning',
				width: '300px',
			});
			return;
		}
	}
	else {
		delete msg.dns2;
	}
	
	if (g_status == null) return;
	var isSet = false;
	do {
		if (msg.ip != g_status.ip) {
			isSet = true;
			break;
		}
		
		if (msg.netmask != g_status.netmask) {
			isSet = true;
			break;
		}
		
		if (msg.gateway != g_status.gateway) {
			isSet = true;
			break;
		}
		
		if (msg.dns1 != g_status.dns1) {
			isSet = true;
			break;
		}
		
		if ((!isNull(msg.dns2)) && (msg.dns2 != g_status.dns2)) {
			console.log(msg.dns2);
			console.log(g_status.dns2);
			isSet = true;
			break;
		}
	} while(false);
	
	if (isSet == false) {
		swal({
			text: '您没有修改网络配置',
			type: 'info',
			width: '300px',
		});
		return;
	}
	
	swal({
	  title: '确定修改网络设置吗？', 
	  text: '修改后设备将自动重启', 
//	  type: 'warning',
	  width: "400px",
	  showCancelButton: true, 
	  confirmButtonColor: '#3085d6',
	  cancelButtonColor: '#d33',
	  allowOutsideClick: false,
	  confirmButtonText: '确定', 
	  cancelButtonText: '取消',
	  confirmButtonClass: 'btn btn-success',
	  cancelButtonClass: 'btn btn-danger',
	  buttonsStyling: true,
	}).then(function() {
		msg.action = 'network_config'
		MYMQ.publish('gw/common', msg);
		
	}, function(dismiss) {
	  // dismiss的值可以是'cancel', 'overlay',
	  // 'close', 'timer'
	  if (dismiss === 'cancel') {
		// do nothing
	  } 
	})
}

function mqttConnected() {
	var msg = {
		action : 'get_baseinfo',
	}
	MYMQ.publish('gw/common', msg);
}

function mqttRev(topic, message) {
	var msg = json2table(message);
	console.log(msg);
	if (msg.action == 'baseinfo_notify') {
		g_status = msg;
		$("#name").val(msg.name);
		$("#ip").val(msg.ip);
		$("#mask").val(msg.netmask);
		$("#gw").val(msg.gateway);
		if (!isNull(msg.dns1) && msg.dns1 != ' ') {
			$("#dns1").val(msg.dns1);
		}
		else {
			g_status.dns1 = '';
		}
		
		if (!isNull(msg.dns2) && msg.dns2 != ' ') {
			$("#dns2").val(msg.dns2);
		}
		else {
			g_status.dns2 = '';
		}
	}
	else if (msg.action == 'name_notify') {
		$("#name").val(msg.name);
	}
	else if (msg.action == 'network_config_resp') {
		if (msg.result == 'success') {
			swal({
				text: '设置成功，设备正在重启',
				type: 'info',
				width: '400px',
			});
		}
	}
}
