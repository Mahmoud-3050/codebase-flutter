# frozen_string_literal: true

# Resolves Flutter build arguments and artifact paths for flavored and
# non-flavored projects. All flavor branching lives here so lanes stay identical.
module FlutterBuild
  def self.flavored?
    DeployConfig.truthy?('USES_FLAVORS')
  end

  def self.flavor
    return nil unless flavored?

    name = ENV.fetch('FLAVOR', '').strip
    UI.user_error!('FLAVOR is required when USES_FLAVORS=true') if name.empty?
    name
  end

  def self.entrypoint
    ENV.fetch('ENTRYPOINT', 'lib/main.dart')
  end

  def self.build_arg_list
    args = []
    flavor_name = flavor
    args += ['--flavor', flavor_name] if flavor_name
    args += ['-t', entrypoint]
    args
  end

  def self.aab_path
    return 'build/app/outputs/bundle/release/app-release.aab' unless flavored?

    name = flavor
    "build/app/outputs/bundle/#{name}Release/app-#{name}-release.aab"
  end

  def self.ios_scheme
    value = ENV['IOS_SCHEME'].to_s.strip
    value.empty? ? 'Runner' : value
  end

  def self.ios_configuration
    value = ENV['IOS_CONFIGURATION'].to_s.strip
    value.empty? ? 'Release' : value
  end
end
