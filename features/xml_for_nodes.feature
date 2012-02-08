Feature: Convert XML for nodes to Puppet DSL
  In order to acheive maximum synergy
  As a complete wanker
  I want to write XML and have it turned into Puppet

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

  Scenario: Multiple nodes declared
    Given the XML:
    """
      <puppet>
        <nodes>
          <node name="default"/>
          <node name="/^lucid32$/"/>
        </nodes>
      </puppet>
    """
    When I generate Puppet
    Then I should have the string:
    """
      node default { }
      node /^lucid32$/ { }
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

  Scenario: node definition with includes
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
