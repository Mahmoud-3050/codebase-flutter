# frozen_string_literal: true

require_relative 'test_helper'

class FlutterBuildTest < Minitest::Test
  include ReleaseTestHelper

  def teardown
    %w[
      USES_FLAVORS FLAVOR ENTRYPOINT IOS_SCHEME IOS_CONFIGURATION
    ].each { |key| ENV.delete(key) }
  end

  def test_flavored_build_args_and_aab_path
    with_env(
      'USES_FLAVORS' => 'true',
      'FLAVOR' => 'live',
      'ENTRYPOINT' => 'lib/main_live.dart'
    ) do
      assert_equal(
        ['--flavor', 'live', '-t', 'lib/main_live.dart'],
        FlutterBuild.build_arg_list
      )
      assert_equal(
        'build/app/outputs/bundle/liveRelease/app-live-release.aab',
        FlutterBuild.aab_path
      )
    end
  end

  def test_flavored_dev_aab_path
    with_env('USES_FLAVORS' => 'true', 'FLAVOR' => 'dev', 'ENTRYPOINT' => 'lib/main_dev.dart') do
      assert_equal(
        'build/app/outputs/bundle/devRelease/app-dev-release.aab',
        FlutterBuild.aab_path
      )
    end
  end

  def test_non_flavored_build_args_and_aab_path
    with_env(
      'USES_FLAVORS' => 'false',
      'FLAVOR' => '',
      'ENTRYPOINT' => 'lib/main.dart'
    ) do
      assert_equal(['-t', 'lib/main.dart'], FlutterBuild.build_arg_list)
      assert_equal(
        'build/app/outputs/bundle/release/app-release.aab',
        FlutterBuild.aab_path
      )
    end
  end

  def test_flavored_without_flavor_raises
    with_env('USES_FLAVORS' => 'true', 'FLAVOR' => '') do
      error = assert_raises(RuntimeError) { FlutterBuild.build_arg_list }
      assert_match(/FLAVOR is required/, error.message)
    end
  end

  def test_ios_scheme_and_configuration_defaults
    with_env('IOS_SCHEME' => '', 'IOS_CONFIGURATION' => '') do
      assert_equal('Runner', FlutterBuild.ios_scheme)
      assert_equal('Release', FlutterBuild.ios_configuration)
    end
  end

  def test_ios_scheme_and_configuration_from_env
    with_env('IOS_SCHEME' => 'live', 'IOS_CONFIGURATION' => 'Release-live') do
      assert_equal('live', FlutterBuild.ios_scheme)
      assert_equal('Release-live', FlutterBuild.ios_configuration)
    end
  end
end
