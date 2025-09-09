require 'rails_helper'

RSpec.describe BaseError do
  it 'has default HTTP_STATUS constant' do
    expect(BaseError::HTTP_STATUS).to eq(500)
  end

  it 'has default MESSAGE constant' do
    expect(BaseError::MESSAGE).to eq('Internal Server Error')
  end

  describe 'instance methods' do
    subject(:error) { described_class.new }

    it 'returns correct http_status' do
      expect(error.http_status).to eq(500)
    end

    it 'returns correct default_message' do
      expect(error.default_message).to eq('Internal Server Error')
    end

    it 'uses default message when initialized without arguments' do
      expect(error.message).to eq('Internal Server Error')
    end

    it 'uses custom message when provided' do
      custom_error = described_class.new('Custom error message')
      expect(custom_error.message).to eq('Custom error message')
    end
  end

  describe 'class methods' do
    it 'responds to http_status' do
      expect(described_class.http_status).to eq(500)
    end

    it 'responds to default_message' do
      expect(described_class.default_message).to eq('Internal Server Error')
    end
  end
end