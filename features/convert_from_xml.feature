Feature: Convert XML to Puppet DSL
  In order to acheive maximum synergy
  As a complete wanker
  I want to write XML and have it turned into Puppet

  Scenario: An empty XML tree
    Given the XML:
    """
      <puppet>
      </puppet>
    """
    When I generate Puppet
    Then I should have an empty string

  Scenario: Basic Class definition
    Given the XML:
    """
      <puppet>
          <class name="testclass">
            <package name="git">
              <ensure>present</ensure>
            </package>
          </class>
      </puppet>
    """
    When I generate Puppet
    Then I should have the string:
    """
      class testclass {
        package {
          "git" :
            ensure => present;
        }
      }
    """

  Scenario: class definition with includes
    Given the XML:
    """
      <puppet>
        <class name="testclass">
          <include>anotherclass</include>
        </class>
      </puppet>
    """
    When I generate Puppet
    Then I should have the string:
    """
      class testclass {
        include anotherclass
      }
    """

  Scenario: specifying requires
    Given the XML:
    """
      <puppet>
        <class name="users">
            <user name="vagrant">
              <require>Group["vagrant"]</require>
              <ensure>present</ensure>
              <shell>/bin/bash</shell>
            </user>
        </class>
      </puppet>
    """
    When I generate Puppet
    Then I should have the string:
    """
        class users {
          user {
            "vagrant" :
              require => Group["vagrant"],
              ensure => present,
              shell => "/bin/bash";
          }
        }
    """
