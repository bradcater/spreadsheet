$:<< '.'

require 'find'

%w{lib models}.each do |folder|
  Find.find(folder) do |file|
    next unless File.extname(file) == '.rb'
    require file
  end
end
