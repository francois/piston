Feature: Import remote repository
  In order to speed up deployments and to only deploy code that's been tested tested
  A developer
  Wants to import remote repositories
  So that he is protected from inadvertent updates

  Scenario: Importing from a Subversion repository
    Given a newly created Subversion project
    And a remote Subversion project named libcalc
    When I run "piston import libcalc"
    Then I should see "Piston imported revision \d+ from .*/libcalc/trunk"
    Then I should find a trunk folder
