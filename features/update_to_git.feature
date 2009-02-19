Feature: Updating from a remote Subversion repository
  In order to be on the cutting edge and benefit from bug fixes
  A developer
  Wants to update his pistonised repositories
  So that he keeps abreast of upstream changes

  Scenario: Updating a remote repository when there are no changes
    Given a newly created Git project
    And a remote Subversion project named libcalc
    And I imported libcalc
    And I committed
    When I update libcalc
    Then I should see "Upstream .*/libcalc was unchanged from revision \d+" debug
    
  Scenario: Updating a remote repository when a file was added
    Given a newly created Git project
    And a remote Subversion project named libcalc
    And a file named libcalc.rb with content "a" in remote libcalc project
    And I imported libcalc
    And I committed
    And a file named libcomplex.rb with content "b" in remote libcalc project
    When I update libcalc
    Then I should see "Updated .*/libcalc to revision \d+"
    And I should find a libcalc/libcomplex.rb file
