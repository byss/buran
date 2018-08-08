#!/usr/bin/env ruby

require 'json'
require 'optparse'
require 'fileutils'
require 'spaceship'

LASTCONFFILE = File.expand_path('~/.config/buran/last.conf')

begin
	CONF = JSON.parse(File.read(LASTCONFFILE))
rescue
	CONF = {}
end

['DEVCENTER_LOGIN', 'TEAM_ID', 'BUNDLE_REGEX', 'ADD_DEVICES', 'ADD_DEVELOPERS', 'DOWNLOAD'].each do |conf_key|
	CONF[conf_key] = ENV[conf_key] unless ENV[conf_key].nil?
end

OptionParser.new do |opts|
	opts.banner = 'Usage: buran.rb [options]'

	opts.on('-l', '--login [LOGIN]', 'Apple Developer Center login (email)') do |login|
		CONF['DEVCENTER_LOGIN'] = login unless login.nil?
	end

	opts.on('-t', '--team-id [TEAM_ID]', 'Development team ID (required for multi-team accounts)') do |team_id|
		CONF['TEAM_ID'] = team_id unless team_id.nil?
	end

	opts.on('-b', '--bundle-regex [REGEX]', 'Regex for affected bundle ids') do |regex|
		CONF['BUNDLE_REGEX'] = regex unless regex.nil?
	end

	opts.on('-a', '--[no-]add-devices', 'Add all devices to affected profiles') do |add|
		CONF['ADD_DEVICES'] = add
	end

	opts.on('-A', '--[no-]add-developers', 'Add all developers to affected profiles') do |add|
		CONF['ADD_DEVELOPERS'] = add
	end

	opts.on('-d', '--[no-]download', 'Download profiles to default profiles directory') do |download|
		CONF['DOWNLOAD'] = download
	end

	opts.on('-D', '--[no-]debug', 'Enables various debugging stuff') do |debug|
		CONF['DEBUG'] = debug
	end

	opts.on_tail('-h', '--help', 'Show this message') do
		puts opts
		exit
	end
end.parse!

CONF['ADD_DEVICES'] = false unless CONF.has_key? 'ADD_DEVICES'
CONF['ADD_DEVELOPERS'] = false unless CONF.has_key? 'ADD_DEVELOPERS'
CONF['DOWNLOAD'] = true unless CONF.has_key? 'DOWNLOAD'

if CONF['DEBUG']
	puts CONF
end

DEVCENTER_LOGIN = CONF['DEVCENTER_LOGIN']
if DEVCENTER_LOGIN.nil?
	puts 'DEVCENTER_LOGIN is missing'
	exit 13
end

Spaceship::Portal.login(DEVCENTER_LOGIN)
Spaceship::Portal.client.team_id = CONF['TEAM_ID'] if CONF.has_key? 'TEAM_ID'

puts 'Successfully logged in'

all_devices = nil
all_udids = nil
if CONF['ADD_DEVICES']
	all_devices = Spaceship::Portal.device.all
	all_udids = all_devices.map { |device| device.udid }.sort
	puts "Got devices list (#{all_devices.length})"
	if CONF['DEBUG']
		puts "UDIDs: #{all_udids}"
	end
end

if CONF['ADD_DEVELOPERS']
	all_certs = Spaceship::Portal.certificate.development.all
	all_cert_ids = all_certs.map { |cert| cert.id }.sort
	puts "Got developers list (#{all_cert_ids.length})"
	if CONF['DEBUG']
		puts "UDIDs: #{all_cert_ids}"
	end
end

profiles_path=File.expand_path("~/Library/MobileDevice/Provisioning Profiles/")
if CONF['DOWNLOAD']
	FileUtils.mkdir_p(profiles_path)
end

bundle_regex = /#{CONF['BUNDLE_REGEX']}/ if CONF.has_key? 'BUNDLE_REGEX'
Spaceship::Portal.provisioning_profile.all.each do |profile|
	puts "Next: #{profile.name} for #{profile.app.bundle_id}"
	next unless bundle_regex.nil? || bundle_regex.match(profile.app.bundle_id)

	devicesUpdated = false
	if CONF['ADD_DEVICES']
		if profile.devices.length == 0
			puts 'AppStore profile, leaving devices as is'
		else
			profile_udids = profile.devices.map { |device| device.udid }.sort
			if (profile_udids == all_udids) && (profile.status == 'Active')
				puts 'All devices are already added'
			else
				profile.devices = all_devices
				devicesUpdated = true
			end
		end
	end

	certsUpdated = false
	if CONF['ADD_DEVELOPERS'] && (profile.distribution_method == 'limited')
		profile_cert_ids = profile.certificates.map { |cert| cert.id }.sort
		if (profile_cert_ids == all_cert_ids) && (profile.status == 'Active')
			puts 'All devices are already added'
		else
			profile.certificates = all_certs
			certsUpdated = true
		end
	end

	if devicesUpdated || certsUpdated
		profile = profile.update!
		if devicesUpdated
			if certsUpdated
				puts "Updated #{profile.name} with #{all_devices.length} device(s) & #{all_certs.length} certificate(s)"
			else
				puts "Updated #{profile.name} with #{all_devices.length} device(s)"
			end
		else
			puts "Updated #{profile.name} with #{all_certs.length} certificate(s)"
		end
	end

	if CONF['DOWNLOAD']
		puts "Downloading #{profile.name}…"
		File.write("#{profiles_path}/#{profile.name}.mobileprovision", profile.download)
	end
end


FileUtils.mkdir_p(File.dirname(LASTCONFFILE))
File.write(LASTCONFFILE, JSON.generate(CONF.select { |key, value| ['DEVCENTER_LOGIN', 'TEAM_ID', 'BUNDLE_REGEX'].include?(key) }))
