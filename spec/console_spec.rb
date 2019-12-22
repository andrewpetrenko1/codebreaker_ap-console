I18n.load_path << Dir[File.expand_path('locales') + '/*.yml']
I18n.default_locale = :en
RSpec.describe Console do
  subject(:console_new) { described_class.new }
  subject(:console) { console_new.start }
  subject(:game) { console_new.instance_variable_get(:@game) }

  describe 'run' do
    let(:input_sequence) { %w[exit] }

    include_context 'stub gets'

    context 'wrong option' do
      let(:input_sequence) { %w[aabb exit] }
      it 'show wrong option' do
        expected_output(/You have passed unexpected command. Please choose one from listed commands/)
      end
    end
    context 'show all options' do
      let(:options_message) do
        "Choose option: \n"\
        "start - start the game\n"\
        "rules - show rules\n"\
        "stats - show statistics\n"\
        "exit - exit game\n"\
      end

      it 'shows options' do
        expected_output(/#{options_message}/)
      end
    end

    context 'rules option' do
      let(:input_sequence) { %w[rules exit] }
      it 'shows rules' do
        expected_output(/Game Rules:/)
      end
    end
    context 'save and show stats option' do
      let(:expected_stats) do
        "Player name: Andrew\n"\
        "Difficulty: easy\n"\
        "Total attempts: 15\n"\
        "Total hints: 2\n"\
        "Used attempts: 1\n"\
        'Used hints: 0'
      end
      let(:input_sequence) { ['start', 'Andrew', 'easy', game.secret_code.join, 'yes', 'yes', 'stats', 'exit'] }
      it 'shows stats' do
        expected_output(/#{expected_stats}/)
      end
    end

    context 'start option' do
      let(:input_sequence) { %w[start andrew impossible easy hint 1239 exit] }
      it 'ask name' do
        expected_output(/Enter your name:/)
      end
      it 'prints hello message' do
        expected_output(/Hello, Andrew/)
      end
      it 'ask difficulty' do
        expected_output(/Choose difficulty: /)
      end
      it 'set wrong difficulty' do
        expected_output(/Wrong difficulty error!/)
      end
      it 'sets easy difficulty options' do
        expected_output(/You have: hints - 2, attempts - 15./)
      end
      it 'takes hint' do
        hint = game.instance_variable_get(:@hints_code).dup
        expected_output(/Hint: #{hint.pop}\nYou have: hints - 1, attempts - 15./)
      end
      it 'shows answer error' do
        expected_output(/Numbers must be from 1 to 6!/)
      end
    end

    context 'exit' do
      it 'closes game' do
        expected_output(/Goodbye/)
      end
    end
  end
end

def expected_output(output_regexp)
  expect { console }.to output(output_regexp).to_stdout
end
