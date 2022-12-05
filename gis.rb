#!/usr/bin/env ruby
# frozen_string_literal: true

class Track
  def initialize(segments, name = nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end
    # set segments to segment_objects
    @segments = segment_objects
  end

  def to_json
    j = '{'
    j += '"type": "Feature", '
    unless @name.nil?
      j += '"properties": {'
      j += "\"title\": \"#{@name}\""
      j += '},'
    end
    j += '"geometry": {'
    j += '"type": "MultiLineString",'
    j += '"coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      j += ',' if index.positive?
      j += '['
      # Loop through all the coordinates in the segment
      tsj = ''
      s.coordinates.each do |c|
        tsj += ',' if tsj != ''
        # Add the coordinate
        tsj += '['
        tsj += "#{c.lon},#{c.lat}"
        tsj += ",#{c.ele}" unless c.ele.nil?
        tsj += ']'
      end
      j += tsj
      j += ']'
    end
    "#{j}]}}"
  end
end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele = nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele = nil, name = nil, type = nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def to_json(_indent = 0)
    j = '{"type": "Feature",'
    # if name is not nil or type is not nil
    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{@lon},#{@lat}"
    j += ",#{@ele}" unless ele.nil?
    j += ']},'
    if !name.nil? || !type.nil?
      j += '"properties": {'
      j += "\"title\": \"#{@name}\"" unless name.nil?
      unless type.nil? # if type is not nil
        j += ',' unless name.nil?
        j += "\"icon\": \"#{@type}\"" # type is the icon
      end
      j += '}'
    end
    j += '}'
    j
  end
end

class World
  def initialize(name, things)
    @name = name
    @features = things
  end

  def add_feature(_f)
    @features.append(t)
  end

  def to_geojson(_indent = 0)
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f, i|
      s += ',' if i != 0
      if f.instance_of?(Track)
        s += f.to_json
      elsif f.instance_of?(Waypoint)
        s += f.to_json
      end
    end
    "#{s}]}"
  end
end

def main
  w = Waypoint.new(-121.5, 45.5, 30, 'home', 'flag')
  w2 = Waypoint.new(-121.5, 45.6, nil, 'store', 'dot')
  ts1 = [
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46)
  ]

  ts2 = [Point.new(-121, 45), Point.new(-121, 46)]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5)
  ]

  t = Track.new([ts1, ts2], 'track 1')
  t2 = Track.new([ts3], 'track 2')

  world = World.new('My Data', [w, w2, t, t2])

  puts world.to_geojson
end

main if File.identical?(__FILE__, $PROGRAM_NAME)
