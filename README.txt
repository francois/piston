Piston is a utility that eases vendor branch management.
This is similar to <tt>svn:externals</tt>, except you have a local copy of
the files, which you can modify at will.  As long as the changes are
mergeable, you should have no problems.

This tool has a similar purpose than svnmerge.py which you can find in the
contrib/client-side folder of the main Subversion repository at
http://svn.collab.net/repos/svn/trunk/contrib/client-side/svnmerge.py.
The main difference is that Piston is designed to work with remote
repositories.  Another tool you might want to look at, SVK, which you can find
at http://svk.elixus.org/.

From Wikipedia's Piston page (http://en.wikipedia.org/wiki/Piston):
  In general, a piston is a sliding plug that fits closely inside the bore
  of a cylinder.

  Its purpose is either to change the volume enclosed by the cylinder, or
  to exert a force on a fluid inside the cylinder.

For this utility, I retain the second meaning, "to exert a force on a fluid
inside the cylinder."  Piston forces the content of a remote repository
location back into our own.


= Notes on 2.0

In the 1.0 era, Piston was exclusively geared towards Subversion repositories.
In early 2008, Git gained a lot of popularity among Ruby and Rails coders.
Piston was rewritten during that period to allow many repositories and working
copies to be used together.

The documentation still refers to Subversion throughout, but 2.0 allows any
repository to be used with any working copy.


= Installation

Nothing could be simpler:

 $ gem install piston


= Usage

First, you need to import the remote repository location:

 $ piston import http://dev.rubyonrails.org/svn/rails/trunk vendor/rails
 Exported r4720 from 'http://dev.rubyonrails.org/svn/rails/trunk' to 'vendor/rails'

 $ svn commit -m "Importing local copy of Rails"

When you want to get the latest changes from the remote repository location:

 $ piston update vendor/rails
 Updated 'vendor/rails' to r4720.

 $ svn commit -m "Updates vendor/rails to the latest revision"

You can prevent a local Piston-managed folder from updating by using the
+lock+ subcommand:

 $ piston lock vendor/rails
 'vendor/rails' locked at r4720.

When you want to update again, you unlock:

 $ piston unlock vendor/rails
 'vendor/rails' unlocked.

If the branch you are following moves, you should use the switch subcommand:

 $ piston import http://dev.rubyonrails.org/svn/rails/branches/1-2-pre-release vendor/rails
 $ svn commit vendor/rails

 # Vendor branch is renamed, let's follow it
 $ piston switch http://dev.rubyonrails.org/svn/rails/branches/1-2-stable vendor/rails


= Contributions

== Bash Shell Completion Script

Michael Schuerig contributed a Bash shell completion script.  You should copy
+contrib/piston+ from your gem repository to the appropriate folder.  Michael
said:

  I've put together a bash completion function for piston. On Debian, I
  just put it in /etc/bash_completion.d, alternatively, the contents can
  be copied to ~/.bash_completion. I don't know how things are organized
  on other Unix/Linux systems.


= Caveats

== Speed

This tool is SLOW.  The update process particularly so.  I use a brute force
approach.  Subversion cannot merge from remote repositories, so instead I
checkout the folder at the initial revision, and then run svn update and
parse the results of that to determine what changes have occured.

If a local copy of a file was changed, it's changes will be merged back in.
If that introduces a conflict, Piston will not detect it.  The commit will be
rejected by Subversion anyway.

== Copies / Renames

Piston *does not* track copies.  Since Subversion does renames in two
phases (copy + delete), that is what Piston does.

== Local Operations Only

Piston only works if you have a working copy.  It also never commits your
working copy directly.  You are responsible for reviewing the changes and
applying any pending fixes.

== Remote Repository UUID

Piston caches the remote repository UUID, allowing it to know if the remote
repos is still the same.  Piston refuses to work against a different
repository than the one we checked out from originally.


= Subversion Properties Used

* <tt>piston:uuid</tt>: The remote repository's UUID, which we always confirm
  before doing any operations.
* <tt>piston:root</tt>: The repository root URL from which this Piston folder
  was exported from.
* <tt>piston:remote-revision</tt>: The <tt>Last Changed Rev</tt> of the remote
  repository.
* <tt>piston:local-revision</tt>: The <tt>Last Changed Rev</tt> of the Piston
  managed folder, to enable us to know if we need to do any merging.
* <tt>piston:locked</tt>: The revision at which this folder is locked.  If
  this property is set and non-blank, Piston will skip the folder with
  an appropriate message.
