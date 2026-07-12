require 'xcodeproj'

project_path = '/Users/Savishka/TapFrenzy/TapFrenzy.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.first

main_group = project.main_group.groups.find { |g| g.path == 'PlayHubApp' || g.name == 'PlayHubApp' }
if main_group.nil?
  main_group = project.main_group
end

file_ref = main_group.files.find { |f| f.path == 'Assets.xcassets' }
if file_ref.nil?
  file_ref = main_group.new_reference('Assets.xcassets')
end

resources_phase = target.resources_build_phase
unless resources_phase.files_references.include?(file_ref)
  resources_phase.add_file_reference(file_ref, true)
end

project.save
puts "Successfully added Assets.xcassets to the Xcode project."
