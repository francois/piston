(in /Users/francois/Documents/work/piston)
Gem::Specification.new do |s|
  s.name = %q{piston}
  s.version = "1.9.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fran\303\247ois Beausoleil"]
  s.date = %q{2008-11-12}
  s.default_executable = %q{piston}
  s.description = %q{Piston is a utility that eases vendor branch management.}
  s.email = ["francois@teksol.info"]
  s.executables = ["piston"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "website/index.txt"]
  s.files = [".gitignore", "History.txt", "License.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/piston", "config/hoe.rb", "config/requirements.rb", "lib/piston.rb", "lib/piston/cli.rb", "lib/piston/commands.rb", "lib/piston/commands/base.rb", "lib/piston/commands/import.rb", "lib/piston/commands/lock_unlock.rb", "lib/piston/commands/update.rb", "lib/piston/commands/info.rb", "lib/piston/commands/status.rb", "lib/piston/commands/upgrade.rb", "lib/piston/git.rb", "lib/piston/git/client.rb", "lib/piston/git/commit.rb", "lib/piston/git/repository.rb", "lib/piston/git/working_copy.rb", "lib/piston/repository.rb", "lib/piston/revision.rb", "lib/piston/svn.rb", "lib/piston/svn/client.rb", "lib/piston/svn/repository.rb", "lib/piston/svn/revision.rb", "lib/piston/svn/working_copy.rb", "lib/piston/version.rb", "lib/piston/working_copy.rb", "lib/subclass_responsibility_error.rb", "log/.gitignore", "samples/common.rb", "samples/import_git_git.rb", "samples/import_git_svn.rb", "samples/import_svn_git.rb", "samples/import_svn_svn.rb", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "tasks/deployment.rake", "tasks/environment.rake", "tasks/samples.rake", "tasks/test.rake", "tasks/website.rake", "test/integration/test_git_git.rb", "test/integration/test_git_svn.rb", "test/integration/test_import_svn_git.rb", "test/integration/test_svn_svn.rb", "test/integration_helpers.rb", "test/test_helper.rb", "test/unit/git/commit/test_checkout.rb", "test/unit/git/commit/test_each.rb", "test/unit/git/commit/test_rememberance.rb", "test/unit/git/repository/test_at.rb", "test/unit/git/repository/test_basename.rb", "test/unit/git/repository/test_guessing.rb", "test/unit/git/working_copy/test_copying.rb", "test/unit/git/working_copy/test_creation.rb", "test/unit/git/working_copy/test_existence.rb", "test/unit/git/working_copy/test_finalization.rb", "test/unit/git/working_copy/test_guessing.rb", "test/unit/git/working_copy/test_rememberance.rb", "test/unit/svn/repository/test_at.rb", "test/unit/svn/repository/test_basename.rb", "test/unit/svn/repository/test_guessing.rb", "test/unit/svn/revision/test_checkout.rb", "test/unit/svn/revision/test_each.rb", "test/unit/svn/revision/test_rememberance.rb", "test/unit/svn/working_copy/test_copying.rb", "test/unit/svn/working_copy/test_creation.rb", "test/unit/svn/working_copy/test_existence.rb", "test/unit/svn/working_copy/test_finalization.rb", "test/unit/svn/working_copy/test_guessing.rb", "test/unit/svn/working_copy/test_rememberance.rb", "test/unit/working_copy/test_guessing.rb", "test/unit/working_copy/test_rememberance.rb", "tmp/.gitignore", "website/index.html", "website/index.txt", "website/javascripts/rounded_corners_lite.inc.js", "website/stylesheets/screen.css", "website/template.rhtml", "test/unit/git/commit/test_validation.rb", "test/unit/git/repository/test_branchanme.rb", "test/unit/svn/revision/test_validation.rb", "test/unit/svn/working_copy/test_externals.rb", "test/unit/test_info.rb", "test/unit/test_lock_unlock.rb", "test/unit/test_repository.rb", "test/unit/test_revision.rb", "test/unit/working_copy/test_info.rb", "test/unit/working_copy/test_validate.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://piston.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{piston}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Piston is a utility that eases vendor branch management.}
  s.test_files = ["test/integration/test_git_git.rb", "test/integration/test_git_svn.rb", "test/integration/test_import_svn_git.rb", "test/integration/test_svn_svn.rb", "test/test_helper.rb", "test/unit/git/commit/test_checkout.rb", "test/unit/git/commit/test_each.rb", "test/unit/git/commit/test_rememberance.rb", "test/unit/git/commit/test_validation.rb", "test/unit/git/repository/test_at.rb", "test/unit/git/repository/test_basename.rb", "test/unit/git/repository/test_branchanme.rb", "test/unit/git/repository/test_guessing.rb", "test/unit/git/working_copy/test_copying.rb", "test/unit/git/working_copy/test_creation.rb", "test/unit/git/working_copy/test_existence.rb", "test/unit/git/working_copy/test_finalization.rb", "test/unit/git/working_copy/test_guessing.rb", "test/unit/git/working_copy/test_rememberance.rb", "test/unit/svn/repository/test_at.rb", "test/unit/svn/repository/test_basename.rb", "test/unit/svn/repository/test_guessing.rb", "test/unit/svn/revision/test_checkout.rb", "test/unit/svn/revision/test_each.rb", "test/unit/svn/revision/test_rememberance.rb", "test/unit/svn/revision/test_validation.rb", "test/unit/svn/working_copy/test_copying.rb", "test/unit/svn/working_copy/test_creation.rb", "test/unit/svn/working_copy/test_existence.rb", "test/unit/svn/working_copy/test_externals.rb", "test/unit/svn/working_copy/test_finalization.rb", "test/unit/svn/working_copy/test_guessing.rb", "test/unit/svn/working_copy/test_rememberance.rb", "test/unit/test_info.rb", "test/unit/test_lock_unlock.rb", "test/unit/test_repository.rb", "test/unit/test_revision.rb", "test/unit/working_copy/test_guessing.rb", "test/unit/working_copy/test_info.rb", "test/unit/working_copy/test_rememberance.rb", "test/unit/working_copy/test_validate.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<main>, ["~> 2.8"])
      s.add_runtime_dependency(%q<log4r>, ["~> 1.0"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 2.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<main>, ["~> 2.8"])
      s.add_dependency(%q<log4r>, ["~> 1.0"])
      s.add_dependency(%q<activesupport>, ["~> 2.1"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<main>, ["~> 2.8"])
    s.add_dependency(%q<log4r>, ["~> 1.0"])
    s.add_dependency(%q<activesupport>, ["~> 2.1"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
