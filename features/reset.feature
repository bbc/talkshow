Feature: Reset
  As a ruby developer testing applications
  I sometimes issue destructive commands
  And need talkshow to deal with those

  Background:
    Given I'm running a javascsript application
    And it's instrumented with talkshow

  Scenario: Trigger a reload
    Given a talkshow server is running
    When I send a window reload instruction
    Then talkshow should continue when the window reloads

