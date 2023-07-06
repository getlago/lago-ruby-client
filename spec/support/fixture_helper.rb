# frozen_string_literal: true

module FixtureHelper
  def load_fixture(name)
    File.read("spec/fixtures/api/#{name}.json")
  end
end
