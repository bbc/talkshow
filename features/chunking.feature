Feature: Chunking
  As a ruby developer testing applications
  I sometimes want to pull back loads of data
  And I need talkshow to chunk the responses and reassemble them

  Background:
    Given I'm running a javascsript application
    And it's instrumented with talkshow

  Scenario: Chunk a response
    Given a talkshow server is running
    When I request to pull back an insanely large object
    Then the talkshow javascript should chunk the response
    And the ruby code should should reassemble it


