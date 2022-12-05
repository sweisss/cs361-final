#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

puts JSON.generate(JSON.parse(ARGF.read), array_nl: "\n", object_nl: "\n", indent: '    ')
