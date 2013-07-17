ts = new Talkshow(hosturl);

// Set TalkShow client-side logging to use the notify
// method defined in this file
ts.logger = notify;

// Print out a simple . as the connection ticker
ts.tick = notify(".");

ts.log( "TalkShow initialized and waiting for " + ts.url);

ts.initialize();




function notify( string, token, newline  ) {
  
  var item;
  var list = document.getElementById("talkshowconsole");

  if ( token ) {
    string = '-> ' + string
  }

  if ( newline ) {
    item = document.createElement('li')
    var text = document.createTextNode(string);
    item.appendChild(text);
    
    if ( list.childNodes.length > 20 ) {
      list.removeChild(list.childNodes[0]);
    }
    list.appendChild(item);
  }
  // No newline case -- add to existing node
  else {
    var node = list.childNodes.item( list.childNodes.length - 1 )
    node.textContent = node.textContent + string
  }
  
  return string
}