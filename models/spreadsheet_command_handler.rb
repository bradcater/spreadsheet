$:<< '.'

load 'lib/initializers.rb'

class SpreadsheetCommandHandler

  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
  end
  def spreadsheet ; @spreadsheet ; end

  def handles_command?(cmd)
    %w{GET SET}.include?(cmd[0])
  end

  def handle_command(cmd)
    raise "Invalid command: #{cmd}" unless handles_command?(cmd)
    if cmd[0] == 'GET'
      puts @spreadsheet.get_cell(cmd[1].to_i, cmd[2].to_i)
    elsif cmd[0] == 'SET'
      if cmd[1] =~ /^[A-Z]+[0-9]+$/
        value = cmd[2..-1].join(' ')
        row_idx = cmd[1].match(/([0-9]+$)/)[0].to_i
        col_idx = Formatter.column_label_to_index(cmd[1].match(/(^[A-Z]+)/)[0])
      else
        value = cmd[3..-1].join(' ')
        row_idx, col_idx = if cmd[1] =~ /^[A-Z]+$/
          [cmd[2].to_i, Formatter.column_label_to_index(cmd[1])]
        else
          [cmd[1].to_i, cmd[2].to_i]
        end
      end
      @spreadsheet.set_cell(row_idx, col_idx, value)
    else
      raise "Unhandled cmd: #{cmd}"
    end
  end

end
