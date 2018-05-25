<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	// 사용자의 아이디와 방 정볼르 받는 객체 생성
	String chat_id = request.getParameter("chat_id");
	String room = (String)request.getAttribute("room");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>채팅방 : <%=room %></title>
<script src="<%=request.getContextPath()%>/resources/js/jquery-3.3.1.min.js"></script>
<style>
 #messageWindow {
    background:LightSkyBlue;
    height:300px;
    overflow:auto;
 }
 .chat_content{
    background: rgb(255, 255, 102);
    padding: 10px;
    border-radius: 10px;
    display: inline-block;
    position: relative;
    margin: 10px;
    float: right;
    clear: both;
 }
 
 .chat_content:after{
    content: '';
   position: absolute;
   right: 0;
   top: 50%;
   width: 0;
   height: 0;
   border: 20px solid transparent;
   border-left-color: rgb(255, 255, 102);
   border-right: 0;
   border-top: 0;
   margin-top: -3.5px;
   margin-right: -10px;
 }
 
 .other-side {
    background: white;
    float:left;
    clear:both;
 }
 
 .other-side:after{
    content: '';
   position: absolute;
   left: 0;
   top: 50%;
   width: 0;
   height: 0;
   border: 20px solid transparent;
   border-right-color: white;
   border-left: 0;
   border-top: 0;
   margin-top: -3.5px;
   margin-left: -10px;
 }
</style>
</head>
<body>
	<h1>채팅방 : <%=room %> / 사용자명 : <%=chat_id %></h1>
	<div id="chatbox">
		<fieldset>
			<div id="messageWindow"></div>
			<input type="text" id="inputMessage" onkeyup="enterKey()"/>
			<input type="submit" id="sendMsg" value="보내기" onclick="send()"/>
			<button type="button" id="endBtn">나가기</button>
		</fieldset>
	</div>
	
<script>
	var chat_id = '<%=chat_id%>';
	var $textarea = $('#messageWindow');	// 채팅창 내용 부분
	// 채팅서버
	var webSocket =  new WebSocket('ws://192.168.20.62:8088<%=request.getContextPath()%>/multicast/<%=room%>');			
	var $inputMessage = $('#inputMessage');	// 내가 보낼 문자열을 담은 input 태그
	
	webSocket.onopen = function(event){
		$textarea.html("<p class='chat_content'>"+chat_id+"님이 입장하셨습니다.</p><br>"); 
		
		// 웹 소켓을 통해 만든 채팅 서버에 참여한 내용을 메시지로 전달
		// 내가 보낼 때에는 send / 서버로부터 받을 때에는 message
		webSocket.send(chat_id+"|님이 입장하셨습니다.");
	};
	
	// 서버로부터 메시지를 전달 받을 때 동작하는 메소드
	webSocket.onmessage = function(event){
		onMessage(event);
	};
	
	// 서버에서 에러가 발생할 경우 동작할 메소드
	webSocket.onerror = function(event){
		onError(event);
	};
	
	// 서버와의 연결이 종료될 경우 동작하는 메소드
	webSocket.onclose = function(event){
			/* onClose(event); */
	};
	
	function send(){
		if($inputMessage.val() == ""){
			// 메시지를 입력하지 않을 경우
			alert("메시지를 입력해 주세요 !");
		} else{
			// 메시지가 입력 되었을 경우
			$textarea.html($textarea.html() + "<p class='chat_content'>나 : " + $inputMessage.val() + "</p><br>");
			
			webSocket.send(chat_id + "|" + $inputMessage.val());
			
			$inputMessage.val("");
		}
		
		$textarea.scrollTop($textarea.height());
	}
	
	// 서버로부터 메시지를 받을 때 수행할 메소드
	function onMessage(event){
		var message = event.data.split("|");
		var sender = message[0];	// 보낸 사람의 ID
		var content = message[1];	// 전달한 내용
		
		if(content == "") {
			// 전달된 글이 없을 경우
		} else {
			$textarea.html($textarea.html() + "<p class='chat_content other-side'>" + sender + " : " + content + "</p><br>");
		}
		$textarea.scrollTop($textarea.height());
	}
	
	function onError(event){
		alert(event.data);
	}
	
	function onClose(event){
		alert(event);
	}
	
	// 엔터키를 누를 경우 메세지 보내기
	function enterKey(){
		if(window.event.keyCode == 13) {
			send();
			$textarea.scrollTop($textarea.height());
		}
	}
	
	$('#endBtn').on('click', function(){
		webSocket.send(chat_id + "|님이 채팅방을 퇴장하였습니다.");
		webSocket.close();
		location.href = "multiView.do";
	});
	
</script>
</body>
</html>