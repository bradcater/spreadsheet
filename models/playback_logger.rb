require 'fileutils'
require 'forwardable'
require 'tempfile'

class PlaybackLogger

  def initialize
    @log = []
  end

  extend Forwardable
  def_delegator :@log, :<<
  alias_method :append, :<<

  def load(filename)
    unless File.exists?(filename)
      raise "Invalid filename #{filename} does not exist."
    end
    @log = []
    s = nil
    File.open(filename, 'rb') do |f|
      rows = f.gets.strip.to_i
      columns = f.gets.strip.to_i
      s = Spreadsheet.new(
        :rows    => rows,
        :columns => columns
      )
      while (line = f.gets)
        @log << line.strip
      end
    end
    [s, @log.dup]
  end

  def persist!(row_count, column_count, filename)
    file = Tempfile.new(filename.split(/\//).last)
    file.write("#{row_count}\n")
    file.write("#{column_count}\n")
    @log.each do |cmd|
      next if cmd =~ /^SAVE /
      file.write("#{cmd}\n")
    end
    file.close
    FileUtils.mv(file.path, filename)
  end

end
