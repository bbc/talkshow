Feature: Remote Server
  As a ruby developer testing js apps with talkshow
  I need to be able to invoke remote talkshow instances
  In order to eliminate cross-network security issues

  Background:
    Given I'm running a javascsript application
    And it's instrumented with talkshow

  Scenario: Send a simple js command
    Given a remote talkshow server is running
    When I send a simple command
    Then I should receive a response
    
  Scenario: Capture a js exception
    Given a remote talkshow server is running
    When I send invalid javascript
    Then I should receive an exception

  Scenario: Invoke a multiple-argument function in js
    Given a remote talkshow server is running
    When I invoke a js function with multiple arguments
    Then I should receive the return response
    
  Scenario: Chunk a response
    Given a remote talkshow server is running
    When I request to pull back an insanely large object
    Then the talkshow javascript should chunk the response
    And the ruby code should should reassemble it
