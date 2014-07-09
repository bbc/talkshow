// Talkshow constructor, takes a uri which indicates where it
// should look for the server. For example localhost:4567/talkshowhost
function Talkshow(uri) {
  
  this.VERSION = '0.2'
  this.POLL_INCREMENT = 500;
  this.MAXIMUM_POLL_TIME = 5000;
  this.MINIMUM_POLL_TIME = 500;
  
  this.url = "http://" + uri;
  this.logger;
  this.ticker;
  this.nextPoll = this.MAXIMUM_POLL_TIME ;
  
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
    this._jsonp( 'question' )
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

  this.respond = function( response ) {
    //var jsonResponse = JSON.stringify( response )
    this._jsonp( 'answer', response )
  }

  // Create the jsonp url and appends to the document to execute
  this._jsonp = function(type, data) {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.charset = 'utf-8';

    var src = this.url + "/" + type + "/" + this.pollId();

    if (type == 'answer') {
      var content = data['content'];
      // Stringify if we have an object -- we can parse it better
      // from the other side
      if (content != undefined && typeof content == 'object') {
        content = JSON.stringify(content)
      }
      src = src + "/" + data['id']
      src = src + "/" + data['status']
      src = src + "/" + data['object']
      src = src + "/" + encodeURIComponent(content)
      src = src + "?callback=ts.log"
    } else {
      src = src + '?callback=ts.handleTalkShowHostQuestion'
    }
    script.src = src

    var scriptsNode = document.getElementById("scripts")

    scriptsNode.replaceChild(script, scriptsNode.lastChild);
  }
  

  this.check = function() {
    this.log( "Checking status" );
    this.poll;
  }

  this.recover = function() {
    this.log( "Recover");
    location.reload(true);
  }

  this.initialize = function() {
    this.nextExecution(self.nextPoll) // 1 second till first poll
  }

  this.nextExecution = function( time ) {
    var self = this;
    window.setTimeout( function() { ts.poll();
                                    self.nextExecution(self.nextPoll);
                                   }, self.nextPoll )
  }
  
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
      ts.reducePollFrequency();
      ts.tick();
      response['status'] = "nop"
      response['content'] = "nop"
    }
    else if (type == 'code') {
      ts.nextPoll = this.MINIMUM_POLL_TIME;
      try {
        response['content'] = eval(json['content']);
      } catch( err ) {
        response['status'] = 'error';
        response['content'] = err.toString();
      }
    }
    else if (type == 'invocation') {
      ts.nextPoll = this.MINIMUM_POLL_TIME;
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

    ts.respond( response )
  }
  
  
  // Reset the messages
  this.sendClear = function() {
    
    var content = true;
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
