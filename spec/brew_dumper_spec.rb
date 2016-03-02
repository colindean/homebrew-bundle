require "spec_helper"

describe Bundle::BrewDumper do
  context "when no formula is installed" do
    before do
      Bundle::BrewDumper.reset!
    end
    subject { Bundle::BrewDumper }

    it "returns empty list" do
      expect(subject.formulae).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump).to eql("")
    end
  end

  context "when Homebrew returns JSON with a malformed linked_keg" do
    before do
      Bundle::BrewDumper.reset!
      allow(Formula).to receive(:installed).and_return(
        [{
          "name" => "foo",
          "full_name" => "homebrew/tap/foo",
          "desc" => "",
          "homepage" => "",
          "oldname" => nil,
          "aliases" => [],
          "versions" => { "stable" => "1.0", "bottle" => false },
          "revision" => 0,
          "installed" => [{
            "version" => "1.0",
            "used_options" => [],
            "built_as_bottle" => nil,
            "poured_from_bottle" => true,
          }],
          "linked_keg" => "fish",
          "keg_only" => nil,
          "dependencies" => [],
          "conflicts_with" => [],
          "caveats" => nil,
          "requirements" => [],
          "options" => [],
          "bottle" => {},
        }]
      )
    end
    subject { Bundle::BrewDumper }

    it "returns no version" do
      expect(subject.formulae).to contain_exactly *[
        {
          :name => "foo",
          :full_name => "homebrew/tap/foo",
          :aliases => [],
          :args => [],
          :version => nil,
          :dependencies => [],
          :requirements => [],
          :pinned? => false,
          :outdated? => false,
        },
      ]
    end
  end

  context "formulae `foo` and `bar` are installed" do
    before do
      Bundle::BrewDumper.reset!
      allow(Formula).to receive(:installed).and_return([
        {
          "name" => "foo",
          "full_name" => "homebrew/tap/foo",
          "desc" => "",
          "homepage" => "",
          "oldname" => nil,
          "aliases" => [],
          "versions" => { "stable" => "1.0", "bottle" => false },
          "revision" => 0,
          "installed" => [{
            "version" => "1.0",
            "used_options" => [],
            "built_as_bottle" => nil,
            "poured_from_bottle" => true,
          }],
          "linked_keg" => "1.0",
          "keg_only" => nil,
          "dependencies" => [],
          "conflicts_with" => [],
          "caveats" => nil,
          "requirements" => [],
          "options" => [],
          "bottle" => {},
        },
        {
          "name" => "bar",
          "full_name" => "bar",
          "desc" => "",
          "homepage" => "",
          "oldname" => nil,
          "aliases" => [],
          "versions" => { "stable" => "2.1", "bottle" => false },
          "revision" => 0,
          "installed" => [{
            "version" => "2.0",
            "used_options" => ["--with-a", "--with-b"],
            "built_as_bottle" => nil,
            "poured_from_bottle" => true,
          }],
          "linked_keg" => nil,
          "keg_only" => nil,
          "dependencies" => [],
          "conflicts_with" => [],
          "caveats" => nil,
          "requirements" => [],
          "options" => [],
          "bottle" => {},
          "pinned" => true,
          "outdated" => true,
        }])
    end
    subject { Bundle::BrewDumper }

    it "returns foo and bar with their information" do
      expect(subject.formulae).to contain_exactly *[
        {
          :name => "foo",
          :full_name => "homebrew/tap/foo",
          :aliases => [],
          :args => [],
          :version => "1.0",
          :dependencies => [],
          :requirements => [],
          :pinned? => false,
          :outdated? => false,
        },
        {
          :name => "bar",
          :full_name => "bar",
          :aliases => [],
          :args => ["with-a", "with-b"],
          :version => "2.0",
          :dependencies => [],
          :requirements => [],
          :pinned? => true,
          :outdated? => true,
        },
      ]
    end

    it "dumps as foo and bar with args" do
      expect(subject.dump).to eql("brew 'bar', args: ['with-a', 'with-b']\nbrew 'homebrew/tap/foo'")
    end
  end

  context "HEAD and devel formulae are installed" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          :name => "foo",
          :full_name => "foo",
          :aliases => [],
          :args => ["devel"],
          :version => "1.1beta",
          :dependencies => [],
          :requirements => [],
        },
        {
          :name => "bar",
          :full_name => "homebrew/tap/bar",
          :aliases => [],
          :args => ["HEAD"],
          :version => "HEAD",
          :dependencies => [],
          :requirements => [],
        },
      ]
    end
    subject { Bundle::BrewDumper.formulae }

    it "returns with args `devel` and `HEAD`" do
      expect(subject[0][:args]).to include("devel")
      expect(subject[1][:args]).to include("HEAD")
    end
  end

  context "A formula link to the old keg" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          :name => "foo",
          :full_name => "homebrew/tap/foo",
          :aliases => [],
          :args => [],
          :version => "1.0",
          :dependencies => [],
          :requirements => [],
        },
      ]
    end
    subject { Bundle::BrewDumper.formulae }

    it "returns with linked keg" do
      expect(subject[0][:version]).to eql("1.0")
    end
  end

  context "A formula with no linked keg" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          :name => "foo",
          :full_name => "homebrew/tap/foo",
          :aliases => [],
          :args => [],
          :version => "2.0",
          :dependencies => [],
          :requirements => [],
        },
      ]
    end
    subject { Bundle::BrewDumper.formulae }

    it "returns with last one" do
      expect(subject[0][:version]).to eql("2.0")
    end
  end

  context "several formulae with dependant relations" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          :name => "a",
          :full_name => "a",
          :aliases => [],
          :args => [],
          :version => "1.0",
          :dependencies => ["b"],
          :requirements => [],
        },
        {
          :name => "b",
          :full_name => "b",
          :aliases => [],
          :args => [],
          :version => "1.0",
          :dependencies => [],
          :requirements => [{ "name" => "foo", "default_formula" => "c", "cask" => "bar" }],
        },
        {
          :name => "c",
          :full_name => "homebrew/tap/c",
          :aliases => [],
          :args => [],
          :version => "1.0",
          :dependencies => [],
          :requirements => [],
        },
      ]
    end
    subject { Bundle::BrewDumper }

    it "returns formulae with correct order" do
      expect(subject.formulae.map { |f| f[:name] }).to eq %w[c b a]
    end

    it "returns all the cask requirements" do
      expect(subject.cask_requirements).to eq %w[bar]
    end
  end
end
