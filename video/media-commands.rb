#!/usr/bin/env ruby

# Originally pulled from http://tinyurl.com/vmo7g

require 'progressbar'

class MediaFormatException < StandardError
end

def execute_mencoder(command)
	bar = ProgressBar.new("mencoder", 100)
  progress = nil
  IO.popen(command) do |pipe|
    pipe.each("\r") do |line|
      if line =~ /Pos:[^(]*\(\s*(\d+)%\)/
        p = $1.to_i
        p = 100 if p > 100
        if progress != p
          progress = p
					bar.set(progress)
        end
      end
    end
  end
	bar.finish
  raise MediaFormatException if $?.exitstatus != 0
end

def execute_ffmpeg(command)
  progress = nil
  IO.popen(command) do |pipe|
    pipe.each("\r") do |line|
      if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/
        duration = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 10 + $4.to_i
      end
      if line =~ /time=(\d+).(\d+)/
        if not duration.nil? and duration != 0
          p = ($1.to_i * 10 + $2.to_i) * 100 / duration
        else
          p = 0
        end
        p = 100 if p > 100
        if progress != p
          progress = p
          print "PROGRESS: #{progress}\n"
          $defout.flush
        end
      end
    end
  end
  raise MediaFormatException if $?.exitstatus != 0
end

def safe_execute
  yield
rescue
  print "ERROR\n"
  exit 1
end
