require_relative './../../util/version.rb'
require_relative './../../util/clean_software.rb'

name 'aptible-toolbelt'
maintainer 'Thomas Orozco <thomas@aptible.com>'
homepage 'https://www.aptible.com'
license 'MIT'
license_file 'LICENSE.md'

install_dir "#{default_root}/#{name}"

build_version do
  source :git, from_dependency: 'aptible-cli'
  output_format :semver_with_platform
end

build_iteration 1

# Creates required build directories
dependency 'preparation'

override :zlib, source: {
  url: 'http://pilotfiber.dl.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.gz'
}

# aptible-cli dependencies/components
dependency 'aptible-cli'
dependency 'ssh'

override :ruby,     version: '2.3.1'
override :rubygems, version: '2.4.8'

# Version manifest file
dependency 'version-manifest'

exclude '**/.git'
exclude '**/bundler/git'

package :pkg do
  identifier 'com.aptible.toolbelt'
  signing_identity 'Developer ID Installer: Chas Ballew (79J6PXK4K8)'
end

project_location_dir = name

package :msi do
  # GUIDs everywhere! These must remain unchanged over time or upgrades will
  # break.
  upgrade_code '1C2B85DF-CDE6-4CE4-BDC7-64AF6E0C5796'

  parameters(
    ProjectLocationDir: project_location_dir,
    AptibleToolbeltPathGuid: '4126FFD9-C230-437B-A102-4B9F29156137'
  )

  # The signing_identity is the SHA1 fingerprint of the cert we use. But, the
  # more interesting part here is this `t` variable. For some reason, the Ruby
  # version we use in our OSX builder doesn't want to allow breaking this
  # expression across multiple lines and wrapping the arguments with ().
  # Unfortunately, our Rubocop config disallows most other things we could try
  # (and we can't use `1` because Omnibus wants `true` or `false`). So,
  # aliasing `true` as `t` it is.
  t = true
  signing_identity '9A25D0866E9F043B218CDB9225081DF2139AF2D2', machine_store: t

  # Use WixUtilExtension to support WixBroadcastEnvironmentChange and notify
  # the system that we're updating an environment variable (the PATH).
  wix_candle_extension 'WixUtilExtension'
  wix_light_extension 'WixUtilExtension'
end
