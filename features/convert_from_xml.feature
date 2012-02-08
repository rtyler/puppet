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
        <classes>
          <class name="testclass">
            <resources>
              <package name="git">
                <ensure>present</ensure>
              </package>
            </resources>
          </class>
        </classes>
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
        <classes>
          <class name="testclass">
            <includes>
              <include>anotherclass</include>
            </includes>
          </class>
        </classes>
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
        <classes>
          <class name="users">
            <resources>
              <user name="vagrant">
                <requires>
                  <require>Group["vagrant"]</require>
                </requires>
                <ensure>present</ensure>
                <shell>/bin/bash</shell>
              </user>
            </resources>
          </class>
        </classes>
      </puppet>
    """
    When I generate Puppet
    Then I should have the string:
    """
        class users {
          user {
            "vagrant" :
              require => [Group["vagrant"]],
              ensure => present,
              shell => "/bin/bash";
          }
        }
    """
