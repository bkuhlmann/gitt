# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitt::Directable do
  subject(:directable) { Struct.new(:subject).include(described_class).new }

  it_behaves_like "a directable"
end
