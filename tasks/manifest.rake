desc "Refreshes the manifest: use this instead of manifest:refresh"
task :manifest do
  sh "find . -type f | grep -v ./.git/ | grep -v -e '\.log$' | sed -E 's!^\./!!' > Manifest.txt"
end
