# frozen_string_literal: true

require_relative 'test_helper'

class FlutterVersionTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('release-version-')
    @pubspec = File.join(@dir, 'pubspec.yaml')
    File.write(@pubspec, "name: demo\nversion: 1.2.3+4\n")
    FlutterVersion.pubspec_override = @pubspec
  end

  def teardown
    FlutterVersion.pubspec_override = nil
    FileUtils.remove_entry(@dir)
  end

  def test_current_reads_name_and_build
    current = FlutterVersion.current
    assert_equal('1.2.3', current[:name])
    assert_equal(4, current[:build])
  end

  def test_write_replaces_version_line
    FlutterVersion.write(name: '1.2.4', build: 9)
    assert_match(/^version: 1.2.4\+9$/, File.read(@pubspec))
    assert_includes(File.read(@pubspec), 'name: demo')
  end

  def test_next_build_number_uses_store_and_local_max
    assert_equal(11, FlutterVersion.next_build_number([7, 10]))
    assert_equal(5, FlutterVersion.next_build_number([1, nil]))
  end

  def test_bump_patch
    assert_equal('1.2.4', FlutterVersion.bump_patch('1.2.3'))
  end

  def test_bump_patch_rejects_short_version
    error = assert_raises(RuntimeError) { FlutterVersion.bump_patch('1.2') }
    assert_match(/MAJOR.MINOR.PATCH/, error.message)
  end

  def test_missing_version_line_raises
    File.write(@pubspec, "name: demo\n")
    error = assert_raises(RuntimeError) { FlutterVersion.current }
    assert_match(/No version/, error.message)
  end
end
