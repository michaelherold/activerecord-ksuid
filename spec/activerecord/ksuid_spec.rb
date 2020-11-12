# frozen_string_literal: true

RSpec.describe ActiveRecord::KSUID do
  it 'has a version number' do
    expect(ActiveRecord::KSUID::VERSION).not_to be nil
  end
end
