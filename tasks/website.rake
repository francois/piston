namespace :website do
  desc "Publishes the gh-pages branch to RubyForge"
  task :publish do
    repos = Dir.pwd
    sh "rm -rf $TMPDIR/piston"
    sh "mkdir $TMPDIR/piston"
    begin
      Dir.chdir(ENV["TMPDIR"] + "/piston") do
        sh "git clone #{repos}"
        Dir.chdir("piston") do
          sh "git checkout origin/gh-pages"
          sh "jekyll"
          sh "rsync -avz --delete --exclude='*.psd'_site/ rubyforge.org:/var/www/gforge-projects/piston"
        end
      end
    ensure
      sh "rm -rf $TMPDIR/piston"
    end
  end
end
