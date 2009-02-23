
Feature: Import remote repository into a Git repository
  In order to speed up deployments and to only deploy code that's been tested tested
  A developer
  Wants to import remote repositories
  So that he is protected from inadvertent updates

  Scenario: Importing from a Git repository
    Given a newly created Git project
    And a remote Git project named libcalc
    And a file named libcalc.rb with content "a\nb\nc" in remote libcalc project
    When I import libcalc
    Then I should see a successful import message from Piston
    And I should find a libcalc folder
    And I should find a libcalc/libcalc.rb file
    And I should find a libcalc/.piston.yml file

  Scenario: Importing from a Git repository to a named folder
    Given a newly created Git project
    And a remote Git project named libcalc
    And a file named libcalc.rb with content "a\nb\nc" in remote libcalc project
    And an existing vendor folder
    When I import libcalc into vendor/libcalc
    Then I should see a successful import message from Piston
    And I should find a vendor/libcalc folder
    And I should find a vendor/libcalc/libcalc.rb file
    And I should find a vendor/libcalc/.piston.yml file

  Scenario: Importing from a Subversion repository
    Given a newly created Git project
    And a remote Subversion project named libcalc
    And a file named libcalc.rb with content "a\nb\nc" in remote libcalc project
    When I import libcalc
    Then I should see a successful import message from Piston
    And I should find a libcalc folder
    And I should find a libcalc/libcalc.rb file
    And I should find a libcalc/.piston.yml file

  Scenario: Importing from a classic Subversion project layout automatically uses project's name and not trunk for the local folder name
    Given a newly created Git project
    And a remote Subversion project named libcalc using the classic layout
    And a file named libcalc.rb with content "a\nb\nc" in remote libcalc project
    When I import libcalc/trunk
    Then I should see a successful import message from Piston
    And I should find a libcalc folder
    And I should find a libcalc/libcalc.rb file
    And I should find a libcalc/.piston.yml file

  Scenario: Importing into a specific folder when the parent folders doesn't exist succeeds
    Given a newly created Git project
    And a remote Subversion project named libcalc using the classic layout
    And a file named libcalc.rb with content "a\nb\nc" in remote libcalc project
    When I import libcalc/trunk into vendor/libcalc
    And I should see a successful import message from Piston
    And I should find a vendor/libcalc folder
    And I should find a vendor/libcalc/libcalc.rb file
