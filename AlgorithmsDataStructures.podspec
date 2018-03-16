
Pod::Spec.new do |s|
  s.name             = 'AlgorithmsDataStructures'
  s.version          = '0.1.0'
  s.summary          = 'AlgorithmsDataStructures contains a lot of popular algorithms & data structures.'

  s.description      = <<-DESC
Have you been looking for that one algorithm or data structure for your most recent project?
AlgorithmsDataStructures might help you with that.
                       DESC

  s.homepage         = 'https://github.com/pauljohanneskraft/AlgorithmsDataStructures'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pauljohanneskraft' => 'pauljohanneskraft@icloud.com' }
  s.source           = { :git => 'https://github.com/pauljohanneskraft/AlgorithmsDataStructures.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'AlgorithmsDataStructures/Classes/**/*'
end
