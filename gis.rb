#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

# A point represented by a latitude, longitude, and optional elevation, name, and icon.
class Waypoint
  attr_reader :lat, :lon, :ele, :name, :icon, :type, :gtype

  def initialize(lon, lat, ele = nil, name = nil, icon = nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @icon = icon
    @type = 'Feature'
    @gtype = 'Point'
  end

  def properties
    properties = { 'title' => name, 'icon' => icon }
    properties.compact
  end

  def coordinates
    coordinates = [lon, lat, ele]
    coordinates.compact
  end

  def geometry
    { 'type' => gtype, 'coordinates' => coordinates }
  end

  def data
    { 'type' => type, 'properties' => properties, 'geometry' => geometry }
  end

  def to_json(_indent = 0)
    data.to_json
  end
end

# A  list of latitude/longitude pairs (with optional elevation).
class TrackSegment
  attr_reader :waypoints

  def initialize(waypoints)
    @waypoints = waypoints
  end

  def coordinates
    coordinates = []
    waypoints.each do |c|
      coordinates.append(c.coordinates)
    end
    coordinates
  end
end

# A list of Track Segments.
class Track
  attr_reader :segments, :name, :type, :gtype

  def initialize(segments, name: nil)
    @name = name
    @segments = segments
    @type = 'Feature'
    @gtype = 'MultiLineString'
  end

  def properties
    properties = { 'title' => name }
    properties.compact
  end

  def coordinates
    coordinates = []
    segments.each do |s|
      coordinates.append(s.coordinates)
    end
    coordinates
  end

  def geometry
    { 'type' => gtype, 'coordinates' => coordinates }
  end

  def data
    { 'type' => type, 'properties' => properties, 'geometry' => geometry }
  end

  def to_json(_indent = 0)
    data.to_json
  end
end

# Puts together a world of Tracks and Waypoints
class World
  attr_reader :name, :features, :type

  def initialize(name, features)
    @name = name
    @features = features
    @type = 'FeatureCollection'
  end

  def add_feature(feature)
    features.append(feature)
  end

  def collect
    collection = []
    features.each do |f|
      collection.append(f.data)
    end
    collection
  end

  def data
    { 'type' => type, 'features' => collect }
  end

  def to_geojson
    data.to_json
  end
end

def main
  w = Waypoint.new(-121.5, 45.5, 30, 'home', 'flag')
  w2 = Waypoint.new(-121.5, 45.6, nil, 'store', 'dot')
  ts1 = TrackSegment.new([
                           Waypoint.new(-122, 45),
                           Waypoint.new(-122, 46),
                           Waypoint.new(-121, 46)
                         ])

  ts2 = TrackSegment.new([Waypoint.new(-121, 45), Waypoint.new(-121, 46)])

  ts3 = TrackSegment.new([
                           Waypoint.new(-121, 45.5),
                           Waypoint.new(-122, 45.5)
                         ])

  t = Track.new([ts1, ts2], name: 'track 1')
  t2 = Track.new([ts3], name: 'track 2')

  world = World.new('My Data', [w, w2, t, t2])

  puts world.to_geojson
end

main if File.identical?(__FILE__, $PROGRAM_NAME)
