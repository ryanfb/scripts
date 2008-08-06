#!/usr/bin/env ruby

# Converts from ASCII vtx (vertices+normals) to ASCII ply.
# -c indicates that the format is vertices+normals+colors
# -f will pull in a list of faces formed from the vertices

require 'optparse'

@option_rgb = false

opts = OptionParser.new
opts.on('-c', '--color') { @option_rgb = true }
opts.on('-f', '--faces file') { |f| @option_faces = f }

opts.parse!(ARGV)

vtx = File.readlines(ARGV[0].to_s)
ply = File.new(ARGV[1].to_s, "w")

# Strip comments
vtx.delete_if { |v| v =~ /^\#/ }

ply.puts "ply"
ply.puts "format ascii 1.0"
ply.puts "element vertex #{vtx.length}"

ply.puts <<EOH
property float x
property float y
property float z
property float nx
property float ny
property float nz
EOH

if @option_rgb
	['red','green','blue'].each do |c|
		ply.puts "property uchar #{c}"
	end
end

if @option_faces
	faces = File.readlines(@option_faces)
	num_faces = faces.length
else
	num_faces = 0
end

ply.puts "element face #{num_faces}"
ply.puts "property list uchar int vertex_indices"
ply.puts "end_header"

ply.puts vtx

if faces
	ply.puts faces
end
