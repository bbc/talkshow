#!/usr/bin/env ruby
$: << './lib/'

require 'talkshow/server'
require 'thread'

Talkshow::Server.question_queue(Queue.new)
Talkshow::Server.answer_queue(Queue.new)
Talkshow::Server.run!

