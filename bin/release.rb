#!/usr/bin/env ruby


version_file = "VERSION"
current_version = File.exist?(version_file) ? File.read(version_file).strip : "0.0.0"
major, minor, patch = current_version.split('.').map(&:to_i)

# last_tag = `git describe --tags --abbrev=0 2>/dev/null`.strip
range = "v#{current_version}..HEAD"
puts "Commits détectés dans la plage #{range}"
raw_commits = `git fetch --tags --force origin && git log #{range} --pretty=format:"%s (%h)"`.split("\n")
puts "Raw Commits: #{raw_commits}"
if raw_commits.empty?
  puts "✨ Aucun nouveau commit depuis le dernier tag."
  exit
end

# 2. Déterminer le type d'incrément (SemVer)
bump_type = :patch
raw_commits.each do |c|
  clean_commit = c.strip
  if clean_commit.upcase.include?("BREAKING CHANGE") || clean_commit =~ /^[a-z]+(?:\([^)]+\))?!:/
    bump_type = :major
    break
  elsif clean_commit.start_with?("feat")
    bump_type = :minor
  end
end

# 3. Calcul de la nouvelle version
case bump_type
when :major then major += 1; minor = 0; patch = 0
when :minor then minor += 1; patch = 0
when :patch then patch += 1
end
new_version = "#{major}.#{minor}.#{patch}"

# 4. Tri des commits pour le log
groups = { "Features" => [], "Bug Fixes" => [], "Maintenance" => [], "Documentation" => [] }
raw_commits.each do |commit|
  case commit
  when /^feat(\(.*\))?:/ then groups["Features"] << commit
  when /^fix(\(.*\))?:/  then groups["Bug Fixes"] << commit
  when /^chore(\(.*\))?:/, /^refactor(\(.*\))?:/, /^ci(\(.*\))?:/ then groups["Maintenance"] << commit
  when /^docs(\(.*\))?:/ then groups["Documentation"] << commit
  end
end

# 5. Construction du Markdown
date_str = Time.now.strftime('%Y-%m-%d')
new_content = "## v#{new_version} (#{date_str})\n\n"
groups.each do |title, items|
  next if items.empty?
  new_content += "### #{title}\n"
  items.each { |item| new_content += "* #{item.gsub(/^[a-z]+(\(.*\))?!?: /, '')}\n" }
  new_content += "\n"
end

# 6. Écriture des fichiers
File.write(version_file, new_version)

file_path = "CHANGELOG.md"
existing_content = File.exist?(file_path) ? File.read(file_path) : ""
File.write(file_path, new_content + "---\n\n" + existing_content)

puts "⬆️ Version : #{current_version} -> #{new_version} (#{bump_type.to_s.upcase})"
puts "✅ Notes générées dans #{file_path}"
