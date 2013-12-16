PROJECTNAME = 'STASN1der'.freeze

task :default => 'analyze'

desc "Clean #{PROJECTNAME}-iOS and -mac"
task :clean => [ 'ios', 'mac' ].map { |x| 'clean:' + x }

desc "Analyze #{PROJECTNAME}-iOS and -mac"
task :analyze => [ 'ios', 'mac' ].map { |x| 'analyze:' + x }

desc "Execute #{PROJECTNAME}Tests-iOS and -mac"
task :test => [ 'ios', 'mac' ].map { |x| 'test:' + x }

namespace :clean do
	desc "Clean #{PROJECTNAME}-iOS"
	task :ios do Ios.clean or fail end

	desc "Clean #{PROJECTNAME}-mac"
	task :mac do Mac.clean or fail end
end

namespace :analyze do
	desc "Analyze #{PROJECTNAME}-iOS"
	task :ios do Ios.analyze or fail end

	desc "Analyze #{PROJECTNAME}-mac"
	task :mac do Mac.analyze or fail end
end

namespace :test do
	desc "Execute #{PROJECTNAME}Tests-iOS"
	task :ios do Ios.test or fail end

	desc "Execute #{PROJECTNAME}Tests-mac"
	task :mac do Mac.test or fail end
end


module BuildCommands
	def clean
		system('xctool', *(@BUILDARGS + [ 'clean' ])) or fail
	end

	def analyze
		system('xctool', *(@BUILDARGS + [ 'analyze' ])) or fail
	end

	def test
		buildargs = @BUILDARGS + [
			'-configuration', 'Coverage',
		]
		testargs = [
			#'parallelize',
		]
		system('xctool', *(buildargs + [ 'test', *testargs ])) or fail
	end
end

class Ios
	@BUILDARGS = [
		'-project', "#{PROJECTNAME}.xcodeproj",
		'-scheme', "#{PROJECTNAME}-iOS",
		'-sdk', 'iphonesimulator7.0',
		'ONLY_ACTIVE_ARCH=NO',
	].freeze

	extend BuildCommands
end

class Mac
	@BUILDARGS = [
		'-project', "#{PROJECTNAME}.xcodeproj",
		'-scheme', "#{PROJECTNAME}-mac",
		'-sdk', 'macosx10.9',
	].freeze

	extend BuildCommands
end
