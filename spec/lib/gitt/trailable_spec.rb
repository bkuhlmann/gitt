# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Trailable do
  subject(:trailable) { Struct.new(:trailers).include(described_class).new trailers: }

  it_behaves_like "a trailable"
end
