Feature: Method Invocation
  As a ruby developer testing js apps
  I need to be able to remotely invoke js methods
  In order to automate javascript in a browser

  Background:
    Given I'm running a javascsript application
    And it's instrumented with talkshow

  Scenario: Invoke a zero-argument function in js
    Given a talkshow server is running
    When I invoke a js function with no arguments
    Then I should receive the return response

  Scenario: Invoke a single-argument function in js
    Given a talkshow server is running
    When I invoke a js function with one argument
    Then I should receive the return response

  Scenario: Invoke a multiple-argument function in js
    Given a talkshow server is running
    When I invoke a js function with multiple arguments
    Then I should receive the return response
