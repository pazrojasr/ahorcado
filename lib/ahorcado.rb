require 'yaml'

# Clase para representar el juego del ahorcado
class HangmanGame
  attr_accessor :max_guesses, :words, :secret_word, :guessed_letters, :correct_letters

  def initialize
    @max_guesses = 6
    @words = []
    @secret_word = ''
    @guessed_letters = []
    @correct_letters = []
  end

  def load_words
    File.open('google-10000-english-no-swears.txt', 'r') do |file|
      file.each_line do |word|
        word = word.strip
        @words << word if word.length.between?(5, 12)
      end
    end
  end

  def select_secret_word
    @secret_word = @words.sample
  end

  def display_word
    displayed_word = ''
    @secret_word.each_char do |letter|
      if @correct_letters.include?(letter.downcase)
        displayed_word += letter + ' '
      else
        displayed_word += '_ '
      end
    end
    displayed_word
  end

  def display_status
    puts '===================================='
    puts '¡Ahorcado!'
    puts 'Palabra: ' + display_word
    puts 'Letras incorrectas: ' + @guessed_letters.join(' ')
    puts 'Intentos restantes: ' + (@max_guesses - @guessed_letters.length).to_s
    puts '===================================='
  end

  def save_game
    File.open('hangman_save.yaml', 'w') do |file|
      file.write(self.to_yaml)
    end
  end

  def self.load_game
    YAML.load_file('hangman_save.yaml')
  end

  def play
    load_words
    select_secret_word

    loop do
      display_status

      if @max_guesses - @guessed_letters.length <= 0
        puts '¡Has perdido! La palabra secreta era: ' + @secret_word
        break
      end

      if @secret_word.chars.all? { |letter| @correct_letters.include?(letter.downcase) }
        puts '¡Felicidades! ¡Has ganado!'
        break
      end

      print "Adivina una letra o ingresa 'save' para guardar el juego: "
      user_input = gets.chomp.downcase

      if user_input == 'save'
        save_game
        puts 'Juego guardado.'
        break
      end

      if user_input.length != 1 || !user_input.match?(/[a-z]/)
        puts 'Ingresa una única letra válida.'
        next
      end

      if @guessed_letters.include?(user_input) || @correct_letters.include?(user_input)
        puts 'Ya has adivinado esa letra.'
        next
      end

      if @secret_word.downcase.include?(user_input)
        @correct_letters << user_input
      else
        @guessed_letters << user_input
      end
    end
  end
end

# Función principal para iniciar el juego
def main
  puts '¡Bienvenido al juego del ahorcado!'
  print "Ingresa 'new' para comenzar un nuevo juego o 'load' para cargar uno existente: "
  user_input = gets.chomp.downcase

  if user_input == 'new'
    game = HangmanGame.new
    game.play
  elsif user_input == 'load'
    begin
      game = HangmanGame.load_game
      game.play
    rescue Errno::ENOENT
      puts 'No se encontró ningún juego guardado.'
    end
  else
    puts 'Comando inválido. Inténtalo nuevamente.'
  end
end

main if __FILE__ == $PROGRAM_NAME
