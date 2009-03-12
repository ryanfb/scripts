#!/usr/bin/env ruby

# mess tools
# deal with messy home directories

require 'fileutils'
require 'date'

MESSDIR = ENV["MESSDIR"] ||= File.expand_path("~/mess")
MESSVERSION = "0.1"

FU = FileUtils #::DryRun

unless ARGV.empty?
  warn <<EOF.strip
mess.rb #{MESSVERSION}
Copyright (C) 2005  Christian Neukirchen <chneukirchen@gmail.com>
EOF
else
  d = Date.today
  current = File.join(MESSDIR, d.year.to_s, "%02d" % d.cweek)
  current_link = File.join(MESSDIR, "current")
	downloads = File.join(current, "Downloads")
	downloads_link = File.join(MESSDIR, "Downloads")

  unless File.directory? current
    FU.mkdir_p current
    warn "Created messdir #{current}"

		FU.mkdir_p downloads
		warn "Created Downloads dir #{downloads}"

    # Set a snazzy icon on Mac OS X
    iconfile = File.join(MESSDIR, "Icon\r")
    if File.exist?(iconfile)
      system("cp #{iconfile} #{File.join(current,"Icon\r")}")
      system("/Developer/Tools/SetFile -a C #{current}")
      warn "Set icon"
    end
  end

	[[current_link, current], [downloads_link, downloads]].each do |mess_link_pair|
		if File.exist?(mess_link_pair[0]) && !File.symlink?(mess_link_pair[0])
			warn "`#{mess_link_pair[0]}' is not a symlink, something is wrong."
		else
			if File.expand_path(mess_link_pair[0]) != File.expand_path(mess_link_pair[1])
				FU.rm_f mess_link_pair[0]
				FU.ln_s mess_link_pair[1], mess_link_pair[0]
			end
		end
	end
	puts current_link
end
