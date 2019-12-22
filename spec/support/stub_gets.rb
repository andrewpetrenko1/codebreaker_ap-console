RSpec.shared_context 'stub gets' do
  before do
    allow(STDIN).to receive(:gets).and_return(*input_sequence)
  end
end
