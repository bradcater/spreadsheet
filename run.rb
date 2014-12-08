$:<< '.'

require 'fileutils'
require 'readline'
require 'trollop'

load 'lib/initializers.rb'

$opts = Trollop::options do
  opt :columns, 'Columns', :default => 5
  opt :rows, 'Rows', :default => 5
end
Trollop::die 'must be > 0' unless $opts[:columns] > 0
Trollop::die 'must be > 0' unless $opts[:rows] > 0

s = Spreadsheet.new(
  :rows    => $opts[:rows],
  :columns => $opts[:columns]
)
spreadsheet_command_handler = SpreadsheetCommandHandler.new(s)
playback_logger = PlaybackLogger.new

while true
  puts spreadsheet_command_handler.spreadsheet
  r = Readline.readline('> ', true)
  cmd = r.strip.split(/\s+/)
  playback_logger << cmd.join(' ')
  if %w{EXIT QUIT}.include?(cmd[0])
    break
  elsif spreadsheet_command_handler.handles_command?(cmd)
    s = spreadsheet_command_handler.handle_command(cmd)
  elsif cmd[0] == 'LOAD'
    filename = cmd[1]
    unless filename =~ /\.spr$/
      filename = "#{filename}.spr"
    end
    s, commands = playback_logger.load(File.join(Dir.pwd, 'saved', filename))
    spreadsheet_command_handler = SpreadsheetCommandHandler.new(s)
    commands.each do |cmd|
      spreadsheet_command_handler.handle_command(cmd.strip.split(/\s+/))
    end
  elsif cmd[0] == 'SAVE'
    filename = cmd[1]
    unless filename =~ /\.spr$/
      filename = "#{filename}.spr"
    end
    unless Dir.exists?(File.join(Dir.pwd, 'saved'))
      FileUtils.mkdir(File.join(Dir.pwd, 'saved'))
    end
    playback_logger.persist!(
      spreadsheet_command_handler.spreadsheet.get_row_count,
      spreadsheet_command_handler.spreadsheet.get_column_count,
      File.join(Dir.pwd, 'saved', filename)
    )
  elsif cmd[0] == 'SHOWCLASSES'
    puts spreadsheet_command_handler.spreadsheet.to_class_s
    puts
  end
end
