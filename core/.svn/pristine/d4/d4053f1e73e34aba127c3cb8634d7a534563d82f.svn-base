// json rpc client
// 依赖 jquery， jQuery timer


// 单项链表封装
function LList(){
	/*节点定义*/
	var Node = function(element){
		this.element = element; //存放节点内容
		this.next = null; //指针
	}
 
	var length = 0, //存放链表长度
	    head = null; //头指针
 
	this.append = function(element){
	 	var node = new Node(element), 
	 	    current; //操作所用指针
 
	 	if (!head){
	 		head = node;
	 	}else {
	 		current = head;
 
	 		while(current.next){
	 			current = current.next;
	 		}
 
	 		current.next = node;
	 	}
 
	 	length++;
	 	return true;
	};
 
	this.insert = function(position, element){
	 	if (position >= 0 && position <= length) {
	 		var node = new Node(element),
		 		current = head,
		 		previous,
		 		index = 0;
 
	 		if(position === 0){
	 			node.next = current;
	 			head = node;
	 		}else{
	 			while(index++ < position){
	 				previous = current;
	 				current = current.next;
	 			}
	 			node.next = current;
	 			previous.next = node;
	 		}
	 		length++;
	 		return true;
	 	}else{
	 		return false;
	 	}
	 };
	this.removeAt = function(position){
	 	if(position > -1 && position < length){
	 		var current = head,
	 		    previous,
	 		    index = 0;
	 		if (position === 0) {
	 			head = current.next;
	 		}else{
	 			while (index++ < position){
	 				previous = current;
	 				current = current.next;
	 			}
	 			previous.next = current.next;
	 		};
	 		length--;
	 		return current.element;
	 	}else{
	 		return null;
	 	}
	};
	this.remove = function(element){
	 	var current = head,
	 	    previous;
	 	if(element === current.element){
	 		head = current.next;
	 		length--;
	 		return true;
	 	}
	 	previous = current;
	 	current = current.next;
	 	while(current){
	 		if(element === current.element){
	 			previous.next = current.next;
	 			length--;
	 			return true;
	 		}else{
	 			previous = current;
	 			current = current.next;
	 		}
	 	}
	 	return false;
	};
	this.remove = function(){
	 	if(length < 1){
	 		return false;
	 	}
	 	var current = head,
 		previous;
	 	if(length == 1){
	 		head = null;
	 		length--;
	 		return current.element;
	 	}
 	
	 	while(current.next !== null){
	 		previous = current;
	 		current = current.next;
	 	}
	 	previous.next = null;
	 	length--;
	 	return current.element;
	};
	this.indexOf = function(element){
	 	var current = head,
	 	    index = 0;
	 	while(current){
	 		if(element === current.element){
	 			return index;
	 		}
	 		index++;
	 		current = current.next;
	 	}
	 	return false;
	};
	this.isEmpty = function(){
	 	return length === 0;
	};
	this.size = function(){
	 	return length;
	};
	this.toString = function(){
	 	var current = head,
	 	    string = '';
	 	while(current){
	 		string += current.element;
	 		current = current.next;
	 	}
	 	return string;
	};	 
	this.getHead = function(){
	 	return head;
	};
	
	this.display = function() {
		var current = head;
		if (current == null) {
			console.log("list is null");
		}
		while(!(current == null)) {
			console.log(current.element);
			current = current.next;
		}
	}
}


function RPCC() {
	this.opt = {
		timeout : 3000, // 3000 ms
	};
	
	this.sendFunction = null;
	// 创建一个缓存队列
	this.list = new LList();
	
	this.timerStartFlag = false;
	this.startTimer = function(ower) {
		if (this.timerStartFlag != false) return;
		this.timerStartFlag = true;
		// 开启个定时器
		$("body").everyTime('100ms', 'rpcccheck', function() {
			if (ower.list.isEmpty() == true) return;
			var head = ower.list.getHead();
			var pos = 0;
			while(!(head == null)) {
				//console.log(head.element);
				var item = head.element;
				item.timeout++;
				if (item.timeout*100 > ower.opt.timeout) {
					var resp = {
						result : "error",
						error: "timeout",
					};
					item.callback(resp);
					ower.list.removeAt(pos);
					break;
				}
				
				head = head.next;
				pos++;
			}
		});	
	}
	
	// 用于生产唯一id
	this.uuid = function() {
		function createS4() {
	        return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
	   }
	
	   return (createS4()+"-"+createS4()+"-"+createS4()+"-"+createS4()+createS4());
	};
	
	this.isNull = function (p) {
		if (p == undefined || p == null || p == '') {
			return true;
		}
		return false;
	};
	
	// 调用远程函数
	// method 函数名
	// params 传入参数
	// callback 返回结果以callback方式
	this.call = function(method, params, callback, filter) {
		this.startTimer(this);
		if (this.isNull(this.sendFunction) == true) {
			console.log("rpcc: sendFunction canot be null!");
			return;
		}
		
		if (this.isNull(method) == true) {
			console.log("rpcc: method canot be null!");
			return;
		}
		
		var msg = {
			messageId : this.uuid(),
			method : method,
		}
		
		if (this.isNull(params) == false) {
			msg.params = params;
		}
		
		if (this.isNull(filter) == false) {
			msg.filter = filter;
		}
		
		// 如果callback不为空，并且是个function，那么要把记录放在list里，否则就不记录
		if (this.isNull(callback) == false && typeof(callback) == 'function') {
			var item = {
				timeout : 0,
				messageId : msg.messageId,
				method : method,
				callback : callback,
			}
			
			if (this.isNull(params) == false) {
				item.params = params;
			}
			
			if (this.isNull(filter) == false) {
				item.filter = filter;
			}
			
			this.list.append(item);
		}

		// send message
		this.sendFunction(JSON.stringify(msg));
	};
	
	// 处理接收来的消息
	this.process = function(msg) {
		if (this.isNull(msg) == true) {
			console.log("rpcc process: param is null!");
			return;
		}
		
		var response = JSON.parse(msg);
		if (this.isNull(response) == true) {
			console.log("rpcc process: param is not json!");
			return;
		}
		
		var messageId = response.messageId;
		
		//console.log("11111111111");
		//this.list.display();
		
		var head = this.list.getHead();
		var pos = 0;
		while(!(head == null)) {
			//console.log(head.element);
			var item = head.element;
			if (item.messageId == messageId) {
				item.callback(response);
				this.list.removeAt(pos);
				break;
			}
			
			head = head.next;
			pos++;
		}
		
		//console.log("22222222222222");
		//this.list.display();
	};
}
