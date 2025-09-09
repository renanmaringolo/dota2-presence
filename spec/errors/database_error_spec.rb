require 'rails_helper'

RSpec.describe DatabaseError do
  it 'inherits from BaseError' do
    expect(described_class.superclass).to eq(BaseError)
  end

  it 'has correct HTTP status (503)' do
    expect(described_class::HTTP_STATUS).to eq(503)
  end

  it 'has meaningful error message' do
    expect(described_class::MESSAGE).to eq('Database service temporarily unavailable')
  end

  describe 'instance' do
    subject(:error) { described_class.new }

    it 'returns correct http_status' do
      expect(error.http_status).to eq(503)
    end

    it 'uses default message when no message provided' do
      expect(error.message).to eq('Database service temporarily unavailable')
    end
  end
end