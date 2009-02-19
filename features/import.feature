Feature: Import remote repository
  In order to speed up deployments and to only deploy code that's been tested tested
  A developer
  Wants to import remote repositories
  So that he is protected from inadvertent updates

  Scenario: Importing from a Subversion repository
    Given a newly created Subversion project
    And a remote Subversion project named libcalc
    And a file named libcalc.rb with content "a\nb\nc" in remote libcalc project
    When I import libcalc
    Then I should see "Imported revision \d+ from .*/libcalc"
    Then I should find a libcalc folder
    Then I should find a libcalc/libcalc.rb file
    Then I should find a libcalc/.piston.yml file
