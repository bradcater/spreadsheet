$:<< '.'

load 'lib/initializers.rb'

require 'find'

Find.find('tests') do |file|
  next unless File.extname(file) == '.rb'
  require file
end
