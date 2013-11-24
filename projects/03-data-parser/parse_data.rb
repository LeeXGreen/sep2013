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

    def correlate(key)
        @by_key ||= {}

        @stats.each do |subdir, sub_stats|
            @by_key[key] ||= {}
            @by_key[key][subdir] ||= []

            sub_stats.each do |file, file_stats|
                value = file_stats[key] rescue nil
                @by_key[key][subdir] << value
            end 
        end

        @by_key[key].each do |subdir, sub_values|
            sub_values.uniq!
            sub_values.sort!
        end

        @by_key[key]
    end
end

if (__FILE__ == $0)
    data_dir = File.join(File.dirname(__FILE__), 'data')
    m = MediaInfoParser.new(data_dir)
    m.parse_data

    #p m.stats

    %w{fps bitrate v_codec a_codec}.each do |key|
        puts "correlating #{key}:"
        data = m.correlate(key)
        data.each do |subdir, values|
            print "\tsubdir=#{subdir}\n\t\t"
            p values
        end

        print "\tonly in not_working:\n\t\t"
        p data['not_working'] - data['working']
    end
end
