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
    puts I18n.t(:goodbye, name: @player.name)
  end

  private

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

  def game_process
    show_game_options
    puts @game.secret_code.join
    enter_game_option
    puts @game.check_answer(@player.answer) if @player.validated
  end

  def enter_game_option
    @player.validated = false
    answer = STDIN.gets.chomp
    case answer
    when HINT then puts I18n.t(:hint, hint: @game.take_hint)
    when I18n.t(:exit) then close_game
    else @player.setup_answer(answer)
    end
  end

  def show_welcome_message
    puts I18n.t(:choose_option)
    puts I18n.t(:start_option)
    puts I18n.t(:rules_option)
    puts I18n.t(:stats_option)
    puts I18n.t(:exit_option)
  end

  def show_game_options
    puts I18n.t(:show_hints_and_attempts, hints: @game.difficulty.hints, attempts: @game.difficulty.attempts)
    puts "#{I18n.t(:guess_secret_code)}\n#{I18n.t(:take_hint)}\n#{I18n.t(:exit_option)}"
  end

  def check_options(option)
    case option
    when I18n.t(:start) then start_game
    when I18n.t(:rules) then @game.show_rules
    when I18n.t(:stats) then @game.show_stats
    when I18n.t(:exit) then close_game
    else
      puts I18n.t(:option_error)
    end
  end

  def set_player_name
    loop do
      puts I18n.t(:enter_name)
      player_name = STDIN.gets.chomp.capitalize
      @player.setup_name(player_name)
      break if @player.validated
    end
    puts I18n.t(:hello, name: @player.name)
  end

  def set_difficulty
    loop do
      puts I18n.t(:enter_difficulty)
      puts CodebreakerAp::Difficulty::DIFFICULTY.keys
      difficulty_level = STDIN.gets.chomp
      @game.difficulty.initialize_difficulty(difficulty_level)
      break if @game.difficulty.validated

      puts @game.difficulty.errors
    end
  end

  def close_game
    @exit = true
  end
end
