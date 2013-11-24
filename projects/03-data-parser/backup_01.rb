#!/usr/bin/env ruby
#
require 'json'

class MediaInfoParser
    attr_accessor :data_dir, :stats

    def initialize(data_dir)
        @data_dir = data_dir
        @stats = {}
    end

    def parse_data
        Dir.foreach(@data_dir) do |f|
            next if f =~ /^\./
            parse_subdir(f)
        end
    end

    def parse_subdir(sub)
        @stats[sub] ||= {}

        path = File.join(@data_dir, sub)
        Dir.foreach(path) do |f|
            next if f =~ /^\./
            
            fullpath = File.join(path, f)

            json = File.read(fullpath)
            obj = JSON.parse(json)
            @stats[sub][f] = obj
        end
    end
end

if (__FILE__ == $0)
    data_dir = File.join(File.dirname(__FILE__), 'data')
    m = MediaInfoParser.new(data_dir)
    m.parse_data

    p m.stats
end
