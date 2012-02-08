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


  Scenario: Simple node declaration
    Given the XML:
    """
      <puppet>
        <nodes>
          <node name="default">
          </node>
        </nodes>
      </puppet>
    """
    When I generate Puppet
    Then I should have the string:
    """
      node default { }
    """

  Scenario: Node with a resource
    Given the XML:
    """
      <puppet>
        <nodes>
          <node name="default">
            <resources>
              <user name="tyler">
                <ensure>present</ensure>
              </user>
            </resources>
          </node>
        </nodes>
      </puppet>
    """
    When I generate Puppet
    Then I should have the string:
    """
      node default {
        user {
          "tyler" :
            ensure => present;
        }
      }
    """

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

  Scenario: node definition with includs
    Given the XML:
    """
      <puppet>
        <nodes>
          <node name="default">
            <includes>
              <include>testclass</include>
            </includes>
          </node>
        </nodes>
      </puppet>
    """
    When I generate Puppet
    Then I should have the string:
    """
      node default {
        include testclass
      }
    """
