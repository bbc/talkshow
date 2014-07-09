Feature: Communication
  As a ruby developer testing js apps
  I need a ruby javascript communication bridge
  In order to automate javascript in a browser

  Background:
    Given I'm running a javascsript application
    And it's instrumented with talkshow

  Scenario: Send a simple js command
    Given a talkshow server is running
    When I send a simple command
    Then I should receive a response

  Scenario: Capture a js exception
    Given a talkshow server is running
    When I send invalid javascript
    Then I should receive an exception
    
  Scenario: Execute a simple js file
    Given a talkshow server is running
    When I execute a js file
    Then I should receive the return response

  Scenario: Execute a multiline js file
    Given a talkshow server is running
    When I execute a multiline js file
    Then I should receive the return response

