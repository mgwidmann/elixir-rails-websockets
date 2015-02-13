var socket = null;
var join = function(timeout, url){
  if(socket) {
    socket.close();
  }
  socket = new Phoenix.Socket("/");
  socket.join(timeout, url, function(channel) {

    channel.on("data:update", function(message) {
      $("#data-container").text(JSON.stringify(message, null, 2));
    });

  });
};

var url = null; // Start out in a "is a change" state
var timeout = null;
$('#connect').click(function(){
  // Prevent opening up more than one connection.
  if(url != $('#url').val() || timeout != $('#timeout').val()){
    url = $('#url').val();
    timeout = $('#timeout').val();
    join(timeout, url);
    $('#data-container').show();
  }
});

$('#stop').click(function(){
  socket.close();
  url = null;
  timeout = null;
});

$("#url-container input[type='text']").keyup(function(event){
  if(event.keyCode == 13){
    $("#join").click();
  }
});
