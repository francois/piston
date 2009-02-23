Feature: Updating from a remote Subversion repository
  In order to be on the cutting edge and benefit from bug fixes
  A developer
  Wants to update his pistonised repositories
  So that he keeps abreast of upstream changes

  Scenario: Updating from a Subversion repository when there are no changes
    Given a newly created Git project
    And a remote Subversion project named libcalc
    And I imported libcalc
    And I committed
    When I update libcalc
    Then I should see "Upstream .*/libcalc was unchanged from revision \d+"
    
  Scenario: Updating from a Subversion repository when a file was added
    Given a newly created Git project
    And a remote Subversion project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcomplex.rb with content "b" in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to revision \d+"
    And I should find a libcalc/libcomplex.rb file

  Scenario: Updating from a Subversion repository when a file was removed
    Given a newly created Git project
    And a remote Subversion project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcalc.rb was deleted in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to revision \d+"
    And I should not find a libcalc/libcalc.rb file

  Scenario: Updating from a Subversion repository when a file was updated
    Given a newly created Git project
    And a remote Subversion project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcalc.rb was updated with "a\nb\nc" in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to revision \d+"
    And I should find a libcalc/libcalc.rb file
    And I should find "a\nb\nc" in libcalc/libcalc.rb

  Scenario: Updating from a Subversion repository when a file was moved
    Given a newly created Git project
    And a remote Subversion project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcalc.rb was renamed to libcomplex.rb in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to revision \d+"
    And I should not find a libcalc/libcalc.rb file
    And I should find a libcalc/libcomplex.rb file

  Scenario: Updating from a Git repository when there are no changes
    Given a newly created Git project
    And a remote Git project named libcalc
    And I imported libcalc
    And I committed
    When I update libcalc
    Then I should see "Upstream .*/libcalc.git was unchanged from commit [a-fA-F0-9]+"
    
  Scenario: Updating from a Subversion repository when a file was added
    Given a newly created Git project
    And a remote Git project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcomplex.rb with content "b" in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to commit [a-fA-F0-9]+"
    And I should find a libcalc/libcomplex.rb file

  Scenario: Updating from a Git repository when a file was removed
    Given a newly created Git project
    And a remote Git project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcalc.rb was deleted in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to commit [a-fA-F0-9]+"
    And I should not find a libcalc/libcalc.rb file

  Scenario: Updating from a Git repository when a file was updated
    Given a newly created Git project
    And a remote Git project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcalc.rb was updated with "a\nb\nc" in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to commit [a-fA-F0-9]+"
    And I should find a libcalc/libcalc.rb file
    And I should find "a\nb\nc" in libcalc/libcalc.rb

  Scenario: Updating from a Git repository when a file was moved
    Given a newly created Git project
    And a remote Git project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcalc.rb was renamed to libcomplex.rb in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to commit [a-fA-F0-9]+"
    And I should not find a libcalc/libcalc.rb file
    And I should find a libcalc/libcomplex.rb file
