# frozen_string_literal: true

require_relative 'gis'
require 'json'
require 'test/unit'

# Tests for Waypoint objects in the gis.rb file
class TestWaypoint < Test::Unit::TestCase
  def test_waypoint
    wp = Waypoint.new(-121.5, 45.5, 30, 'home', 'flag')
    expected = JSON.parse('{"type": "Feature",
      "properties": {"title": "home","icon": "flag"},
      "geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(wp.to_json)
    assert_equal(result, expected)
  end

  def test_waypoint_with_nil_elevation
    wp = Waypoint.new(-121.5, 45.5, nil, 'home', 'flag')
    expected = JSON.parse('{"type": "Feature",
      "properties": {"title": "home","icon": "flag"},
      "geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(wp.to_json)
    assert_equal(result, expected)
  end

  def test_waypoint_with_nil_name
    wp = Waypoint.new(-121.5, 45.5, 30, nil, 'flag')
    expected = JSON.parse('{"type": "Feature",
      "properties": {"icon": "flag"},
      "geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(wp.to_json)
    assert_equal(result, expected)
  end

  def test_waypoint_with_nil_icon
    wp = Waypoint.new(-121.5, 45.5, 30, 'home', nil)
    expected = JSON.parse('{"type": "Feature",
      "properties": {"title": "home"},
      "geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(wp.to_json)
    assert_equal(result, expected)
  end

  def test_waypoint_with_nil_ele_and_name
    wp = Waypoint.new(-121.5, 45.5, nil, nil, 'flag')
    expected = JSON.parse('{"type": "Feature",
      "properties": {"icon": "flag"},
      "geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(wp.to_json)
    assert_equal(result, expected)
  end

  def test_waypoint_with_nil_ele_and_icon
    wp = Waypoint.new(-121.5, 45.5, nil, 'store', nil)
    expected = JSON.parse('{"type": "Feature",
      "properties": {"title": "store"},
      "geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(wp.to_json)
    assert_equal(result, expected)
  end
end

# Tests for Track objects in the gis.rb file
class TestTracks < Test::Unit::TestCase
  def test_single_segment_track
    ts = TrackSegment.new(
      [Waypoint.new(-121, 45.5), Waypoint.new(-122, 45.5)]
    )

    t = Track.new([ts], 'track 2')
    expected = JSON.parse('{"type": "Feature",
      "properties": {"title": "track 2"},
      "geometry": {"type": "MultiLineString",
      "coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(t.to_json)
    assert_equal(expected, result)
  end

  def test_2_segment_track
    ts1 = TrackSegment.new([
                             Waypoint.new(-122, 45),
                             Waypoint.new(-122, 46),
                             Waypoint.new(-121, 46)
                           ])

    ts2 = TrackSegment.new(
      [Waypoint.new(-121, 45), Waypoint.new(-121, 46)]
    )

    t = Track.new([ts1, ts2], 'track 1')
    expected = JSON.parse('{"type": "Feature",
      "properties": {"title": "track 1"},
      "geometry": {"type": "MultiLineString",
      "coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.to_json)
    assert_equal(expected, result)
  end
end

# Tests for World objects in the gis.rb file
class TestWorld < Test::Unit::TestCase
  def test_world
    wp = Waypoint.new(-121.5, 45.5, 30, 'home', 'flag')
    wp2 = Waypoint.new(-121.5, 45.6, nil, 'store', 'dot')
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

    t = Track.new([ts1, ts2], 'track 1')
    t2 = Track.new([ts3], 'track 2')

    w = World.new('My Data', [wp, wp2, t, t2])

    expected = JSON.parse('{"type": "FeatureCollection",
      "features": [{"type": "Feature",
        "properties": {"title": "home","icon": "flag"},
        "geometry": {"type": "Point",
        "coordinates": [-121.5,45.5,30]}},
      {"type": "Feature",
      "properties": {"title": "store","icon": "dot"},
      "geometry": {"type": "Point",
        "coordinates": [-121.5,45.6]}},
      {"type": "Feature",
      "properties": {"title": "track 1"},
      "geometry": {"type": "MultiLineString",
        "coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},
      {"type": "Feature",
      "properties": {"title": "track 2"},
      "geometry": {"type": "MultiLineString",
        "coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.to_geojson)
    assert_equal(expected, result)
  end
end
