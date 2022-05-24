# frozen_string_literal: true

require 'lago/version'
require 'spec_helper'

RSpec.describe Lago do
  it 'has a version number' do
    expect(Lago::VERSION).not_to be nil
  end
end
