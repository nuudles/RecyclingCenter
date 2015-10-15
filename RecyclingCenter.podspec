Pod::Spec.new do |s|
  s.name = 'RecyclingCenter'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'A simple manager to handle recycled and reused objects'
  s.homepage = 'https://github.com/nuudles/RecyclingCenter'
  s.authors = { 'Christopher Luu' => 'nuudles@gmail.com' }
  s.source = { :git => 'https://github.com/nuudles/RecyclingCenter.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/*.swift'

  s.requires_arc = true
end
