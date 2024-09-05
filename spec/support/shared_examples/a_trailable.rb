# frozen_string_literal: true

RSpec.shared_examples "a trailable" do
  describe "#find_trailer" do
    let(:trailers) { [Gitt::Models::Trailer[key: "issue", value: "123"]] }

    it "answers trailer for matching key" do
      expect(trailable.find_trailer("issue")).to eq(Success(trailers.first))
    end

    it "answers failure when key isn't found" do
      expect(trailable.find_trailer("format")).to eq(
        Failure(%(Unable to find trailer for key: "format".))
      )
    end
  end

  describe "#find_trailers" do
    let :trailers do
      [
        Gitt::Models::Trailer[key: "issue", value: "111"],
        Gitt::Models::Trailer[key: "format", value: "asciidoc"],
        Gitt::Models::Trailer[key: "issue", value: "222"]
      ]
    end

    it "answers array for matching key" do
      expect(trailable.find_trailers("issue")).to eq(
        Success(
          [
            Gitt::Models::Trailer[key: "issue", value: "111"],
            Gitt::Models::Trailer[key: "issue", value: "222"]
          ]
        )
      )
    end

    it "answers empty array when key isn't found" do
      expect(trailable.find_trailers("unknown")).to eq(Success([]))
    end
  end

  describe "#trailer_value_for" do
    let(:trailers) { [Gitt::Models::Trailer[key: "issue", value: "123"]] }

    it "answers trailer for matching key" do
      expect(trailable.trailer_value_for("issue")).to eq(Success("123"))
    end

    it "answers failure when key isn't found" do
      expect(trailable.trailer_value_for("format")).to eq(
        Failure(%(Unable to find trailer for key: "format".))
      )
    end
  end

  describe "#trailer_values_for" do
    let :trailers do
      [
        Gitt::Models::Trailer[key: "issue", value: "111"],
        Gitt::Models::Trailer[key: "format", value: "asciidoc"],
        Gitt::Models::Trailer[key: "issue", value: "222"]
      ]
    end

    it "answers array for matching key" do
      expect(trailable.trailer_values_for("issue")).to eq(Success(%w[111 222]))
    end

    it "answers empty array when key isn't found" do
      expect(trailable.trailer_values_for("unknown")).to eq(Success([]))
    end
  end
end
