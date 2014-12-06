$:<< '.'

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

while true
  puts s
  r = Readline.readline('> ', true)
  cmd = r.strip.split(/\s+/)
  if %w{EXIT QUIT}.include?(cmd[0])
    break
  elsif cmd[0] == 'GET'
    puts s.get_cell(cmd[1].to_i, cmd[2].to_i)
  elsif cmd[0] == 'SET'
    value = if cmd[3] =~ /^[-\d\.]$/
      cmd[3]
    else
      cmd[3..-1].join(' ')
    end
    s.set_cell(cmd[1].to_i, cmd[2].to_i, value)
  elsif cmd[0] == 'SHOWCLASSES'
    puts s.to_class_s
    puts
  end
end
