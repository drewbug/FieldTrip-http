#!/usr/bin/env ruby

require 'sinatra'

require './fieldtrip.rb'

raise 'Too few arguments' if ARGV.count < 2
raise 'Too many arguments' if ARGV.count > 2

listen = ARGV[0].split(':')
target = ARGV[1].split(':')

raise 'Error parsing target' unless target.count == 2

configure do
  set :port, listen[1] ? listen[1] : listen[0]
  set :bind, listen[1] ? listen[0] : '0.0.0.0'
  set :fieldtrip_client, FieldTrip::Client.new(target[0], target[1])
end

before do
  headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Headers'] = 'accept, authorization, origin'
end

get '/get/hdr' do
  settings.fieldtrip_client.get_header
end

get '/get/dat' do
  settings.fieldtrip_client.get_data params['begsample'].to_i, params['endsample'].to_i
end

get '/get/evt' do
  settings.fieldtrip_client.get_events params['begevent'].to_i, params['endevent'].to_i
end

get '/wait/dat' do
  settings.fieldtrip_client.wait_data params['nsamples'].to_i, params['nevents'].to_i, params['timeout'].to_i
end
