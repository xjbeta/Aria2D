platform :osx, '10.10'
target 'Aria2D' do
	use_frameworks!
	pod 'SwiftyJSON',
		git: 'https://github.com/SwiftyJSON/SwiftyJSON.git'
	pod 'Just',
		git: 'https://github.com/JustHTTP/Just.git'
	pod 'Starscream',
		git: 'https://github.com/daltoniam/Starscream.git'
	# pod 'RealmSwift',
		# git: 'https://github.com/realm/realm-cocoa.git'
	pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git',:submodules => true, branch: 'tg/xcode-9'
	pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git',:submodules => true, branch: 'tg/xcode-9'
	pod 'DevMateKit'
	post_install do |installer|
   		installer.pods_project.targets.each do |target|
    		  	target.build_configurations.each do |config|
        			config.build_settings['SWIFT_VERSION'] = '3.0'
      			end
    		end
  	end
	
end
