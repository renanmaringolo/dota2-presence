require 'rails_helper'

RSpec.describe ApplicationController do
  subject(:controller) { described_class.new }

  let(:operation_class) { class_double('TestOperation', call: operation_result) }
  let(:operation_result) { { data: { user_id: 123 }, meta: { success: true } } }
  let(:operation_params) { { user_id: 123, category: 'test' } }

  describe '#call_operation' do
    context 'when operation succeeds' do
      before do
        allow(operation_class).to receive(:call).and_return(operation_result)
      end

      it 'calls operation with provided parameters' do
        controller.send(:call_operation, operation_class, **operation_params)

        expect(operation_class).to have_received(:call).with(operation_params)
      end

      it 'returns operation result when no block given' do
        result = controller.send(:call_operation, operation_class, **operation_params)

        expect(result).to eq(operation_result)
      end

      it 'yields result to block when block is provided' do
        yielded_result = nil

        controller.send(:call_operation, operation_class, **operation_params) do |result|
          yielded_result = result
        end

        expect(yielded_result).to eq(operation_result)
      end

      it 'does not return result when block is provided' do
        result = controller.send(:call_operation, operation_class, **operation_params) { |_r| 'block_executed' }

        expect(result).to eq('block_executed')
      end
    end

    context 'with different parameter combinations' do
      before do
        allow(operation_class).to receive(:call).and_return(operation_result)
      end

      it 'handles empty parameters' do
        controller.send(:call_operation, operation_class)

        expect(operation_class).to have_received(:call).with(no_args)
      end

      it 'handles single parameter' do
        controller.send(:call_operation, operation_class, user_id: 'single')

        expect(operation_class).to have_received(:call).with(user_id: 'single')
      end

      it 'handles multiple parameters' do
        params = { user_id: 123, email: 'test@test.com', active: true }
        controller.send(:call_operation, operation_class, **params)

        expect(operation_class).to have_received(:call).with(params)
      end
    end

    context 'with edge cases' do
      it 'handles operation returning nil' do
        allow(operation_class).to receive(:call).and_return(nil)

        result = controller.send(:call_operation, operation_class, **operation_params)

        expect(result).to be_nil
      end

      it 'handles operation returning false' do
        allow(operation_class).to receive(:call).and_return(false)

        result = controller.send(:call_operation, operation_class, **operation_params)

        expect(result).to be false
      end

      it 'handles operation returning complex data structures' do
        complex_result = { users: [{ id: 1 }, { id: 2 }], metadata: { count: 2 } }
        allow(operation_class).to receive(:call).and_return(complex_result)

        result = controller.send(:call_operation, operation_class, **operation_params)

        expect(result).to eq(complex_result)
      end
    end
  end
end
