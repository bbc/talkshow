#!/usr/bin/env ruby
$: << './lib/'

require 'talkshow/daemon'

Talkshow::Daemon.new.run

