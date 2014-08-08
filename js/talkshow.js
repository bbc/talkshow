// Talkshow constructor, takes a uri which indicates where it
// should look for the server. For example localhost:4567/talkshowhost
function Talkshow(uri, poll_frequency) {
  
  this.VERSION = '1.0'
  this.POLL_INCREMENT = 100;
  this.MAXIMUM_POLL_TIME = 2000;
  this.MINIMUM_POLL_TIME = poll_frequency || 200;
  this.JSONP_WINDOW = 60;
  
  this.url = "http://" + uri;
  this.logger;
  this.nextPoll = this.MINIMUM_POLL_TIME ;
  
  this.log = function( text ) {
    var result;
    if (this.logger) {
      result = this.logger(text);
    }
    return result;
  }

  this.tick = function() {};
  
  this.ack = function() {};

  this.poll = function() {
    this.reducePollFrequency();
    this._construct_jsonp_url( 'question' )
  }

  // Need a random poll id to augment the jsonp urls
  // otherwise some devices will cache the jsonp call
  this.pollId = function() {
    return Math.floor((Math.random()*10000000));
  }

  this.reducePollFrequency = function() {
    if ( this.nextPoll > 0 && this.nextPoll < this.MAXIMUM_POLL_TIME ) {
      this.nextPoll = this.nextPoll + this.POLL_INCREMENT;
    }
  }

  // Send a response
  // Stringification and chunking logic is handled here
  this.respond = function( response ) {
    //var jsonResponse = JSON.stringify( response )
    
    var content = response['content']
    // Stringify if we have an object -- we can parse it better
    // from the other side
    var payloads = [content] 
    if (content != undefined && typeof content == 'object') {
      content = JSON.stringify(content)
      payloads = this._split_string(content)
    }
    
    
    for (i = 0; i < payloads.length; i++) {
      response['content'] = payloads[i]
      if (payloads.length > 1) {
        response['chunks'] = payloads.length
        response['payload'] = i
      }
      this._construct_jsonp_url( 'answer', response )
    }
  }
  
  this._split_string = function(string) {
    return string.match(/.{1,500}/g)
  }

  // Create the jsonp url and appends to the document to execute
  this._construct_jsonp_url = function(type, data) {
    
    var src = this.url + "/" + type + "/" + this.pollId();

    if (type == 'answer') {
      var content = data['content'];
      src = src + "/" + data['id']
      src = src + "/" + data['status']
      src = src + "/" + data['object']
      src = src + "/" + encodeURIComponent(content)
      src = src + "?callback=ts.ack"
      if (data['chunks']) {
        src = src + '&chunks=' + data['chunks'] + '&payload=' + data['payload'] 
      }
    } else {
      src = src + '?callback=ts.handleTalkShowHostQuestion'
    }
  
    this._make_jsonp_call(src)
  }

  // Do the actual jspnp call
  this._make_jsonp_call = function(src) {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.charset = 'utf-8';
    script.src = src

    var scriptsNode = document.getElementById("scripts")
    
    // We use a rolling window for the jsonp node, otherwise
    // we can end up deleting elements before they're processed
    if ( scriptsNode.childNodes.length > this.JSONP_WINDOW ) {
      var firstChild = scriptsNode.childNodes[0];
      scriptsNode.removeChild(firstChild);
      // Force garbage collection
      for (var elem in firstChild) {
        delete firstChild[elem];
      }
    }
    scriptsNode.appendChild(script, scriptsNode.lastChild);
  }
  

  // Set up the polling
  this.initialize = function() {
    this.nextExecution(self.nextPoll)
  }

  // Set the next poll
  this.nextExecution = function( time ) {
    var self = this;
    window.setTimeout( function() { ts.poll();
                                    self.nextExecution(self.nextPoll);
                                   }, self.nextPoll )
  }
  
  // Execute a function
  this.executeFunction = function( functionName, args ) {
    var namespaces = functionName.split(".");
    var func = namespaces.pop();
    var context = window;
    for (var i = 0; i < namespaces.length; i++) {
        context = context[namespaces[i]];
        if (! context ) {
          throw "Function context '" + namespaces[i]  + "' for " + functionName + " does not exist"
        }
    }
    if (! context[func] ) {
      throw "Function '" + func  + "' does not exist for context '" + context.toString() + "'"
    }

    return context[func].apply(context, args);
  }

  //
  // Callback for handling a question
  // Can deal with three question types:
  //
  // * nop -- do nothing
  // * code -- eval a code string
  // * invocation -- invoke a function
  //
  this.handleTalkShowHostQuestion = function(json) {
    var id = json['id']
    var response = new Array()
    response['id'] = id
    response['status'] = 'ok'

    type = json['type']
    if (type == 'nop') {
      this.reducePollFrequency();
      this.tick();
      response['status'] = "nop"
      response['content'] = "nop"
    }
    else if (type == 'code') {
      this.nextPoll = this.MINIMUM_POLL_TIME;
      try {
        response['content'] = eval(json['content']);
      } catch( err ) {
        response['status'] = 'error';
        response['content'] = err.toString();
      }
    }
    else if (type == 'invocation') {
      this.nextPoll = this.MINIMUM_POLL_TIME;
      func = json['function']
      args = json['args']

      try {
        response['content'] = this.executeFunction( func, args );
      } catch( err ) {
        response['status'] = 'error';
        response['content'] = err.toString();
      }
    }
    else {
      this.reducePollFrequency();
      response['status'] = 'error'
      response['content'] = "Unknown question type";
    }
    response['object'] = typeof response['content'];

    this.respond( response )
  }
  
  
  // Reset the messages
  this.sendClear = function() {
    
    var content = 'ready';
    var object_type = typeof content;
    
    var message = {
      'id': 0,
      'status': 'clear',
      'content': content,
      'object': object_type
    }
    this.respond( message )
  }
  
  
  // Talkshow has loaded, send a clear
  this.sendClear();
}
