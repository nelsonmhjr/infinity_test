require 'spec_helper'

module InfinityTest
  describe Rspec do
    
    it "should be possible to sett all rubies" do
      Rspec.new(:rubies => '1.9.1').rubies.should be == '1.9.1'
    end
    
    it "should set the rubies" do
      Rspec.new(:rubies => 'jruby,ree').rubies.should be == 'jruby,ree'
    end
    
    it "should have the pattern for spec directory" do
      Rspec.new.test_directory_pattern.should be == "^spec/(.*)_spec.rb"
    end
    
    describe '#construct_commands' do
      
      it "should return a Hash" do
        Rspec.new.construct_commands.should be_instance_of(Hash)
      end
      
      it "should return one item when not have any rubies" do
        Rspec.new.construct_commands.should have(1).item
      end
      
      it "should return the ruby version as the key" do
        redefine_const(:RUBY_VERSION, '1.9.1') do
          Rspec.new.construct_commands.keys.should be == ['1.9.1']
        end
      end
      
      it "should return the ruby version as the key" do
        redefine_const(:RUBY_VERSION, '1.9.2') do
          Rspec.new.construct_commands.keys.should be == ['1.9.2']
        end
      end
      
      it "should grab the current ruby version of the user" do
        redefine_const(:JRUBY_VERSION, 'jruby') do
          redefine_const(:RUBY_PLATFORM, 'java') do
            Rspec.new.construct_commands.keys.should be == ['jruby']
          end
        end
      end
      
      it "should grab the current ruby and set the ruby bin dir" do
        Rspec.new.construct_commands.values.first.should match /ruby/
      end
      
    end
    
    describe '#rspec_path' do
      
      it "should return the bin path for rspec 1.3.0" do
        Gem.should_receive(:bin_path).with('rspec', 'spec').and_return('bin/spec')
        Rspec.new.rspec_path.should be == 'bin/spec'
      end
      
      it "should return the bin path for rspec 1.2.0" do
        Gem.should_receive(:bin_path).with('rspec', 'spec').and_return('rspec-1.2.0-bin/spec')
        Rspec.new.rspec_path.should be == 'rspec-1.2.0-bin/spec'
      end
      
      it "should return the bin path for rspec 2 if not have the rspec 1.3" do
        Gem.should_receive(:bin_path).with('rspec', 'spec').and_raise(LoadError)
        Gem.should_receive(:bin_path).with('rspec-core', 'rspec').and_return('rspec-core')
        Rspec.new.rspec_path.should be == 'rspec-core'
      end

      it "should return the bin path for rspec 2 if not have the rspec 1.3" do
        Gem.should_receive(:bin_path).with('rspec', 'spec').and_raise(LoadError)
        Gem.should_receive(:bin_path).with('rspec-core', 'rspec').and_return('rspec-beta')
        Rspec.new.rspec_path.should be == 'rspec-beta'
      end
      
    end
    
    def redefine_const(name,value)
      if Object.const_defined?(name)
        old_value = Object.const_get(name)
        Object.send(:remove_const, name)
      else
        old_value = value
      end      
      Object.const_set(name,value)
      yield
    ensure
      Object.send(:remove_const, name)
      Object.const_set(name, old_value)
    end
    
  end
end