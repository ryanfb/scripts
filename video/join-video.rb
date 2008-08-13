#!/usr/bin/env ruby

# Joins all videos in the current directory, or takes a directory
# as an argument and joins all videos there.

require 'fileutils'

include FileUtils::Verbose

def join_all_videos(dir = {})
	if dir != {}
		chdir(dir)
	end

	mediafiles = Dir['**/*.avi'] + Dir['**/*.mpg']
	mediafiles.reject! {|a| a =~ /sample/}
	mediafiles.sort!

	if mediafiles.length > 1
		output = mediafiles[0][0..-5] + "-joined" + mediafiles[0][-4..-1]
		mediafiles.map! {|i| "\"#{i}\""}
		input = mediafiles.join(" ") 
		puts "Input: #{input}"
		puts "Output: #{output}"
		
		command = "mencoder -forceidx -noodml -oac copy -ovc copy -o \"#{output}\" #{input}"
		
		system(command)
	end
end

if ARGV.length > 0
	ARGV.each {|dir| join_all_videos(expand_path(dir) + "/")}
else
	join_all_videos
end
