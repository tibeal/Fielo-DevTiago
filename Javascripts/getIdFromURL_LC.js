var recordId;
name = 'id';
name = name.replace(/[\[\]]/g, "\\$&");

var url = window.location.href;
var regex = new RegExp("[?&]" + name + "=([^&]+)");
var results = regex.exec(url);
if (!results) recordId = null;
if (!results[1]) {
    recordId =  '';
} else{
    recordId = results[1];
}

console.log(recordId);