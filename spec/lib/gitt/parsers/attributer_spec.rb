# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Parsers::Attributer do
  subject(:parser) { described_class.new keys }

  let(:keys) { %i[header body footer] }

  let :content do
    <<~DATA
      <header>Example</header>
      <body>Test.</body>
      <footer>End</footer>
    DATA
  end

  describe ".with" do
    it "answers instance with custom keys" do
      attributes = described_class.with(%i[one two]).call "<one>1</one><two>2</two>"
      expect(attributes).to eq(one: "1", two: "2")
    end
  end

  describe "#call" do
    it "answers all attributes for content" do
      expect(parser.call(content)).to eq(header: "Example", body: "Test.", footer: "End")
    end

    it "answers partial attributes with incomplete content" do
      expect(parser.call("<body>Test.</body>")).to eq(header: nil, body: "Test.", footer: nil)
    end

    it "replaces invalid attribute encodings with question marks" do
      expect(parser.call("<body>Test \210\221\332\332\337\341\341</body>")).to eq(
        header: nil,
        body: "Test ???????",
        footer: nil
      )
    end

    it "answers nil attributes with nil content" do
      expect(parser.call(nil)).to eq(header: nil, body: nil, footer: nil)
    end

    it "answers nil attributes with empty content" do
      expect(parser.call("")).to eq(header: nil, body: nil, footer: nil)
    end

    it "answers empty hash with no keys" do
      keys.clear
      expect(parser.call(content)).to eq({})
    end

    it "fails with argument error when not an invalid byte sequence" do
      content = instance_double String
      allow(content).to receive(:to_s).and_raise(ArgumentError, "Danger!")
      expectation = proc { parser.call content }

      expect(&expectation).to raise_error(ArgumentError, "Danger!")
    end
  end
end
