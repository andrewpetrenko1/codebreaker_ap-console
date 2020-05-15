class Console
  YES = 'yes'.downcase
  HINT = 'hint'.freeze

  def initialize
    @game = CodebreakerAp::Game.new
    @player = CodebreakerAp::Player.new
    @exit = false
  end

  def start
    loop do
      show_welcome_message
      option = STDIN.gets.chomp.downcase
      check_options(option)
      break if @exit == true
    end
    show_goodbye_message
  end

  private

  def show_welcome_message
    puts I18n.t(:choose_option)
    puts "#{I18n.t(:start_option)}\n#{I18n.t(:rules_option)}"
    puts "#{I18n.t(:stats_option)}\n#{I18n.t(:exit_option)}"
  end

  def show_goodbye_message
    puts I18n.t(:goodbye, name: @player.name) unless @player.name.nil?
    puts I18n.t(:goodbye_unknown) if @player.name.nil?
  end

  def check_options(option)
    case option
    when I18n.t(:start) then start_game
    when I18n.t(:rules) then puts @game.show_rules
    when I18n.t(:stats) then @game.show_stats
    when I18n.t(:exit) then close_game
    else puts I18n.t(:option_error)
    end
  end

  def start_game
    set_player_name
    set_difficulty
    loop do
      game_process
      break if @game.difficulty.attempts.zero? || @game.win? || @exit == true
    end
    save_stat? if @game.win?
    try_again? if @exit != true
  end

  def set_player_name
    loop do
      puts I18n.t(:enter_name)
      player_name = STDIN.gets.chomp.capitalize
      break if (errors = @player.setup_name(player_name)) == player_name

      puts errors
    end
    puts I18n.t(:hello, name: @player.name)
  end

  def set_difficulty
    loop do
      puts I18n.t(:enter_difficulty)
      puts CodebreakerAp::Difficulty::DIFFICULTY.keys
      difficulty_level = STDIN.gets.chomp
      errors = @game.difficulty.initialize_difficulty(difficulty_level)
      break unless @game.difficulty.attempts.nil?

      puts errors
    end
  end

  def game_process
    show_game_options
    enter_game_option
    puts @game.check_answer(@player.answer)
  end

  def show_game_options
    puts I18n.t(:show_hints_and_attempts, hints: @game.difficulty.hints, attempts: @game.difficulty.attempts)
    puts "#{I18n.t(:guess_secret_code)}\n#{I18n.t(:take_hint)}\n#{I18n.t(:exit_option)}"
  end

  def enter_game_option
    loop do
      case answer = STDIN.gets.chomp
      when HINT then puts I18n.t(:hint, hint: @game.take_hint)
      when I18n.t(:exit) then close_game && break
      else
        errors = @player.setup_answer(answer)
        break unless @player.answer.nil?

        puts errors
      end
    end
  end

  def save_stat?
    puts I18n.t(:save_stats)
    choose = STDIN.gets.chomp.downcase
    @game.save_stats(@player.name, @game.difficulty) if choose == YES
  end

  def try_again?
    puts I18n.t(:try_again)
    again = STDIN.gets.chomp.downcase
    close_game unless again == YES
    @game = CodebreakerAp::Game.new
  end

  def close_game
    @exit = true
  end
end
