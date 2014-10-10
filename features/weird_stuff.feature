Feature: Weird Stuff
  As a ruby developer testing js apps
  I need a place to capture weird bugs
  So those TITAN guys don't screw up

  Background:
    Given I'm running a javascsript application
    And it's instrumented with talkshow

  Scenario: Empty string response
    Given a talkshow server is running
    When an empty string is returned by the js
    Then I should receive ruby empty string

  Scenario: Forward slash in response
    Given a talkshow server is running
    When a forward slash is returned in a string
    Then it should appear in the ruby string
