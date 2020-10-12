#!/usr/bin/ruby

require 'cgi'

c = CGI::new

print <<EOF
Content-type: application/json

{ success: true }
EOF
