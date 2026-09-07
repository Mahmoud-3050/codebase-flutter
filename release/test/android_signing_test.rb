# frozen_string_literal: true

require_relative 'test_helper'

class AndroidSigningTest < Minitest::Test
  def test_escape_properties_special_characters
    assert_equal('plain', AndroidSigning.send(:escape, 'plain'))
    assert_equal('a\\=b', AndroidSigning.send(:escape, 'a=b'))
    assert_equal('host\\:port', AndroidSigning.send(:escape, 'host:port'))
    assert_equal('c\\\\d', AndroidSigning.send(:escape, 'c\\d'))
  end

  def test_write_key_properties
    original_root = DeployConfig::ROOT
    original_release = DeployConfig::RELEASE_DIR
    dir = Dir.mktmpdir('release-signing-')
    keystore = File.join(dir, 'upload.jks')
    File.write(keystore, 'dummy')
    FileUtils.mkdir_p(File.join(dir, 'android'))

    DeployConfig.send(:remove_const, :ROOT)
    DeployConfig.const_set(:ROOT, dir)
    DeployConfig.send(:remove_const, :RELEASE_DIR)
    DeployConfig.const_set(:RELEASE_DIR, dir)

    ENV['ANDROID_KEYSTORE_PATH'] = 'upload.jks'
    ENV['ANDROID_KEYSTORE_PASSWORD'] = 'store=secret'
    ENV['ANDROID_KEY_PASSWORD'] = 'key:secret'
    ENV['ANDROID_KEY_ALIAS'] = 'upload'

    AndroidSigning.write_key_properties!

    contents = File.read(File.join(dir, 'android', 'key.properties'))
    assert_match(/^storePassword=store\\=secret$/, contents)
    assert_match(/^keyPassword=key\\:secret$/, contents)
    assert_match(/^keyAlias=upload$/, contents)
    assert_includes(contents, "storeFile=#{keystore}")
  ensure
    ENV.delete('ANDROID_KEYSTORE_PATH')
    ENV.delete('ANDROID_KEYSTORE_PASSWORD')
    ENV.delete('ANDROID_KEY_PASSWORD')
    ENV.delete('ANDROID_KEY_ALIAS')
    DeployConfig.send(:remove_const, :ROOT)
    DeployConfig.const_set(:ROOT, original_root)
    DeployConfig.send(:remove_const, :RELEASE_DIR)
    DeployConfig.const_set(:RELEASE_DIR, original_release)
    FileUtils.remove_entry(dir) if dir && File.exist?(dir)
  end
end
