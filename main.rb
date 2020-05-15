require_relative 'autoload.rb'

I18n.load_path << Dir[File.expand_path('locales') + '/*.yml']

loop do
  puts "Choose language. \nType `en` to select English, `ru` to select Russian."
  language = STDIN.gets
  case language
  when "ru\n"
    I18n.default_locale = :ru
    break
  when "en\n"
    I18n.default_locale = :en
    break
  else
    puts 'Wrong locale!'
  end
end

Console.new.start
