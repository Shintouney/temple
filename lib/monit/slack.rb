#!/usr/bin/ruby

require 'json'
require 'net/https'
require 'uri'

slack_webhook_url = "https://hooks.slack.com/services/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"
body = JSON.generate({text: "#{ %x{hostname}  } - #{ARGV[0]} at #{ Time.now }"})

uri = URI.parse(slack_webhook_url)
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true
https.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Post.new(uri.request_uri)
request.add_field 'Content-Type', 'application/json'
request.body = body

response = https.request(request) 
