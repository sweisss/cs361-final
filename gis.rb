#!/usr/bin/env ruby
# frozen_string_literal: true

# A point represented by a latitude, longitude, and optional elevation, name, and icon.
class Waypoint
  attr_reader :lat, :lon, :ele, :name, :icon

  def initialize(lon, lat, ele = nil, name = nil, icon = nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @icon = icon
  end

  def properties
    properties = { 'title' => name, 'icon' => icon }
    properties = properties.compact
  end

  def coordinates
    coordinates = [lon, lat, ele]
    coordinates = coordinates.compact
  end

  def data
    data = { 'type' => 'Feature',
             'properties' => properties,
             'geometry' => { 'type' => 'Point',
                             'coordinates' => coordinates } }
  end

  def to_json(_indent = 0)
    data.to_json
  end
end

# A  list of latitude/longitude pairs (with optional elevation).
class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end
end

# A list of Track Segments.
class Track
  attr_reader :segments, :name

  def initialize(segments, name = nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s)) # inject this dependency
    end
    @segments = segment_objects
  end

  def to_json(_indent = 0)
    j = '{'
    j += '"type": "Feature", '
    unless name.nil?
      j += '"properties": {'
      j += "\"title\": \"#{name}\""
      j += '},'
    end
    j += '"geometry": {'
    j += '"type": "MultiLineString",'
    j += '"coordinates": ['
    # Loop through all the segment objects
    segments.each_with_index do |s, index|
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

# Puts together a wolrd or Tracks and Waypoints
class World
  attr_reader :name, :features

  def initialize(name, things)
    @name = name
    @features = things
  end

  def add_feature(_f)
    features.append(t)
  end

  def to_geojson(_indent = 0)
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    features.each_with_index do |f, i|
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
    Waypoint.new(-122, 45),
    Waypoint.new(-122, 46),
    Waypoint.new(-121, 46)
  ]

  ts2 = [Waypoint.new(-121, 45), Waypoint.new(-121, 46)]

  ts3 = [
    Waypoint.new(-121, 45.5),
    Waypoint.new(-122, 45.5)
  ]

  t = Track.new([ts1, ts2], 'track 1')
  t2 = Track.new([ts3], 'track 2')

  world = World.new('My Data', [w, w2, t, t2])

  puts world.to_geojson
end

main if File.identical?(__FILE__, $PROGRAM_NAME)
