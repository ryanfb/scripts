#!/usr/bin/env ruby

# Converts from ASCII surf (vertices+uv+faces) to ASCII ply.
# -c indicates we want conversion from UV to RGB (unimplemented)
# -f will pull in a list of faces formed from the vertices

require 'optparse'

@option_rgb = false

opts = OptionParser.new
opts.on('-c', '--color') { @option_rgb = true }
opts.on('-i MANDATORY', '--image MANDATORY') { |i| @option_image = i }

opts.parse!(ARGV)

surf = File.open(ARGV[0].to_s, "r")
ply = File.new(ARGV[1].to_s, "w")


def read_elements(file,count,array,&mapfun)
	(1..count.to_i).each do |c|
		line = file.gets
		elements = line.split(/\s+/)
		elements.map! {|e| mapfun.call(e)}
		array.push elements
	end
end

vtx_head = surf.gets
vertices = []
if vtx_head =~ /Vertices (\d+)/
	read_elements(surf, $1, vertices) { |e| e.to_f }
end

face_head = surf.gets
faces = []
if face_head =~/Triangles (\d+)/
	read_elements(surf, $1, faces) { |e| e.to_i - 1 }
end

ply.puts "ply"
ply.puts "format ascii 1.0"

if @option_image
	ply.puts "comment TextureFile #{@option_image}"
end

ply.puts "element vertex #{vertices.length}"

ply.puts <<EOH
property float x
property float y
property float z
EOH

if @option_rgb
	['red','green','blue'].each do |c|
		ply.puts "property uchar #{c}"
	end
end

ply.puts "element face #{faces.length}"
ply.puts "property list uchar int vertex_indices"
ply.puts "property list uchar float texcoord"
ply.puts "end_header"

vertices.each do |v|
	ply.puts v[0,3].join(" ")
end

faces.each do |f|
	ply.puts "3 #{f.join(" ")}"
	uv = []
	f.each do |v|
		ref = vertices.at(v)
		tex = ref[3,2]
		uv.push tex.map{|t| 1.0 - t}.reverse
	end
	ply.puts "6 #{uv.join(" ")}"
end