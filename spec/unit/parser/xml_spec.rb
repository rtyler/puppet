#!/usr/bin/env rspec
require 'spec_helper'
require 'ruby-debug'

describe Puppet::Parser::Xml do
  describe '#to_catalog' do
    context 'with an empty document' do
      let(:doc) { '<puppet></puppet>' }

      it 'should create a catalog' do
        catalog = Puppet::Parser::Xml.to_catalog(doc)
        catalog.should_not be nil
        catalog.resources.should be_empty
        catalog.classes.should be_empty
      end
    end

    context 'with a single node' do
      let(:doc) { '<puppet><node name="vagrant"></node></puppet>' }

      before :each do
        @catalog = Puppet::Parser::Xml.to_catalog(doc)
      end

      it 'should create a catalog with a node resource' do
        pending  'Until I LRN 2 AST'
        @catalog.resources.should be_empty
        @catalog.classes.should_not be_empty
      end
    end

    context 'with a simple defined class' do
      let(:doc) { '''
          <puppet>
            <class name="synergy">
              <group name="puppet">
                <ensure>present</ensure>
              </group>
            </class>
          </puppet>''' }
      before :each do
        @catalog = Puppet::Parser::Xml.to_catalog(doc)
      end

      it 'should have a synergy class in the resources' do
        @catalog.resources.should_not be_empty
        @catalog.resources.size.should be 2
        @catalog.resources.each do |resource|
          next if resource.type != 'Class'
          dependents = @catalog.dependents(resource)
          dependents.size.should be 1
          dependents.first.title.should == 'puppet'
        end
      end
    end

  end
end
