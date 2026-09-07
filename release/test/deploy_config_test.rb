# frozen_string_literal: true

require_relative 'test_helper'

class DeployConfigTest < Minitest::Test
  include ReleaseTestHelper

  def test_truthy_values
    with_env('DRY_RUN' => 'true') { assert DeployConfig.truthy?('DRY_RUN') }
    with_env('DRY_RUN' => 'YES') { assert DeployConfig.truthy?('DRY_RUN') }
    with_env('DRY_RUN' => '1') { assert DeployConfig.truthy?('DRY_RUN') }
    with_env('DRY_RUN' => 'false') { refute DeployConfig.truthy?('DRY_RUN') }
    refute DeployConfig.truthy?('MISSING_KEY')
  end

  def test_secret_path_joins_release_dir
    path = DeployConfig.secret_path('secrets/play-store-service-account.json')
    assert_equal(
      File.join(DeployConfig::RELEASE_DIR, 'secrets/play-store-service-account.json'),
      path
    )
  end

  def test_secret_path_keeps_absolute_paths
    assert_equal('/tmp/key.json', DeployConfig.secret_path('/tmp/key.json'))
  end

  def test_hook_path_prefers_file_under_release
    relative = 'scripts/hooks/pre_build.example.sh'
    assert_equal(
      File.join(DeployConfig::RELEASE_DIR, relative),
      DeployConfig.hook_path(relative)
    )
  end

  def test_hook_path_falls_back_to_project_root
    path = DeployConfig.hook_path('pubspec.yaml')
    assert_equal(File.join(DeployConfig::ROOT, 'pubspec.yaml'), path)
    assert File.file?(path)
  end

  def test_project_path
    assert_equal(
      File.join(DeployConfig::ROOT, 'android', 'key.properties'),
      DeployConfig.project_path('android', 'key.properties')
    )
  end
end
