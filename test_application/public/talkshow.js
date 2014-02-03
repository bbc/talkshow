// Talkshow constructor, takes a uri which indicates where it
// should look for the server. For example localhost:4567/talkshowhost
function Talkshow(uri) {
  this.url = "http://" + uri;
  this.logger;
  this.ticker;
  this.nextPoll = 2000;

  this.log = function( text ) {
    var result;
    if (this.logger) {
      result = this.logger(text, true, true);
    }
    return result;
  }

  this.tick = function () {}

  this.poll = function() {
    this.reducePollFrequency();
    this._jsonp( 'question' )
  }

  this.pollId = function() {
    return Math.floor((Math.random()*10000000));
  }

  this.reducePollFrequency = function() {
    if ( this.nextPoll > 0 && this.nextPoll < 5000 ) {
      this.nextPoll = this.nextPoll + 500;
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
      src = src + "/" + data['id']
      src = src + "/" + data['status']
      src = src + "/" + data['object']
      src = src + "/" + data['content']
      src = src + "?callback=notify"
    } else {
      src = src + '?callback=ts.handleTalkShowHostQuestion'
    }
    script.src = src
    notify("Polling: " + src, true, true);

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
      ts.nextPoll = 500;
      try {
        response['content'] = eval(json['content']);
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
    response['object'] = typeof response['content']

    ts.respond( response )
  }
}
