Feature: JS to Ruby Mappings
  As a ruby developer testing js apps
  I need js objects to translate to ruby equivalents
  So that I don't have to do any additional casting

  Background:
    Given I'm running a javascsript application
    And it's instrumented with talkshow

  Scenario: Return a boolean
    Given a talkshow server is running
    When a boolean is sent from the javascript side
    Then a TrueClass or FalseClass is received on the ruby side

  Scenario: Return an number
    Given a talkshow server is running
    When a number is sent from the javascript side
    Then a Numeric should be received on the ruby side


