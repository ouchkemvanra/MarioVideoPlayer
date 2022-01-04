
Pod::Spec.new do |spec|
  spec.name         = "MarioVideoPlayer"
  spec.version      = "0.0.1"
  spec.summary      = "Customizable Video Player"
  spec.homepage     = "https://github.com/ouchkemvanra/MarioVideoPlayer.gitr"
  spec.license      = "MIT"
  spec.author             = { "kemvanra ouch" => "ouchkemvanra1@gmail.com" }
  spec.source       = { :git => "https://github.com/ouchkemvanra/MarioVideoPlayer.git", :tag => "main" }
  spec.platform = :ios, '9.0'
  spec.source_files  = "MarioVideoPlayer/*.{h,m}", "MarioVideoPlayer/**/*.{h,m}"
  spec.frameworks = 'AVKit'
  spec.requires_arc = true

end
