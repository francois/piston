# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{piston}
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fran\303\247ois Beausoleil"]
  s.date = %q{2009-02-23}
  s.default_executable = %q{piston}
  s.description = %q{Piston makes it easy to merge vendor branches into your own repository, without worrying about which revisions were grabbed or not.  Piston will also keep your local changes in addition to the remote changes.}
  s.email = %q{josh@technicalpickles.com}
  s.executables = ["piston"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "VERSION.yml", "bin/piston", "lib/piston", "lib/piston/cli.rb", "lib/piston/commands", "lib/piston/commands/base.rb", "lib/piston/commands/convert.rb", "lib/piston/commands/diff.rb", "lib/piston/commands/import.rb", "lib/piston/commands/info.rb", "lib/piston/commands/lock_unlock.rb", "lib/piston/commands/status.rb", "lib/piston/commands/update.rb", "lib/piston/commands/upgrade.rb", "lib/piston/commands.rb", "lib/piston/git", "lib/piston/git/client.rb", "lib/piston/git/commit.rb", "lib/piston/git/repository.rb", "lib/piston/git/working_copy.rb", "lib/piston/git.rb", "lib/piston/repository.rb", "lib/piston/revision.rb", "lib/piston/svn", "lib/piston/svn/client.rb", "lib/piston/svn/repository.rb", "lib/piston/svn/revision.rb", "lib/piston/svn/working_copy.rb", "lib/piston/svn.rb", "lib/piston/version.rb", "lib/piston/working_copy.rb", "lib/piston.rb", "lib/subclass_responsibility_error.rb", "test/integration_helpers.rb", "test/spec_suite.rb", "test/test_helper.rb", "test/unit", "test/unit/git", "test/unit/git/commit", "test/unit/git/commit/test_checkout.rb", "test/unit/git/commit/test_each.rb", "test/unit/git/commit/test_rememberance.rb", "test/unit/git/commit/test_validation.rb", "test/unit/git/repository", "test/unit/git/repository/test_at.rb", "test/unit/git/repository/test_basename.rb", "test/unit/git/repository/test_branchanme.rb", "test/unit/git/repository/test_guessing.rb", "test/unit/git/working_copy", "test/unit/git/working_copy/test_copying.rb", "test/unit/git/working_copy/test_creation.rb", "test/unit/git/working_copy/test_existence.rb", "test/unit/git/working_copy/test_finalization.rb", "test/unit/git/working_copy/test_guessing.rb", "test/unit/git/working_copy/test_rememberance.rb", "test/unit/svn", "test/unit/svn/repository", "test/unit/svn/repository/test_at.rb", "test/unit/svn/repository/test_basename.rb", "test/unit/svn/repository/test_guessing.rb", "test/unit/svn/revision", "test/unit/svn/revision/test_checkout.rb", "test/unit/svn/revision/test_each.rb", "test/unit/svn/revision/test_rememberance.rb", "test/unit/svn/revision/test_validation.rb", "test/unit/svn/working_copy", "test/unit/svn/working_copy/test_copying.rb", "test/unit/svn/working_copy/test_creation.rb", "test/unit/svn/working_copy/test_existence.rb", "test/unit/svn/working_copy/test_externals.rb", "test/unit/svn/working_copy/test_finalization.rb", "test/unit/svn/working_copy/test_guessing.rb", "test/unit/svn/working_copy/test_rememberance.rb", "test/unit/test_info.rb", "test/unit/test_lock_unlock.rb", "test/unit/test_repository.rb", "test/unit/test_revision.rb", "test/unit/working_copy", "test/unit/working_copy/test_guessing.rb", "test/unit/working_copy/test_info.rb", "test/unit/working_copy/test_rememberance.rb", "test/unit/working_copy/test_validate.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://francois.github.com/piston}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{piston}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Easy your vendor branch management worries}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<cucumber>, [">= 0.1.16"])
      s.add_runtime_dependency(%q<main>, [">= 2.8.3"])
      s.add_runtime_dependency(%q<log4r>, [">= 1.0.5"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.0.0"])
    else
      s.add_dependency(%q<cucumber>, [">= 0.1.16"])
      s.add_dependency(%q<main>, [">= 2.8.3"])
      s.add_dependency(%q<log4r>, [">= 1.0.5"])
      s.add_dependency(%q<activesupport>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<cucumber>, [">= 0.1.16"])
    s.add_dependency(%q<main>, [">= 2.8.3"])
    s.add_dependency(%q<log4r>, [">= 1.0.5"])
    s.add_dependency(%q<activesupport>, [">= 2.0.0"])
  end
end
