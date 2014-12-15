$:<< '.'

load 'lib/initializers.rb'

class SpreadsheetCommandHandler

  def initialize(spreadsheet)
    @spreadsheet = spreadsheet
  end
  def spreadsheet ; @spreadsheet ; end

  VALID_COMMANDS = Set.new(%w{ADDCOLUMN ADDROW GET REMOVECOLUMN REMOVEROW SET})
  def handles_command?(cmd)
    VALID_COMMANDS.include?(cmd[0])
  end

  def handle_command(cmd)
    raise "Invalid command: #{cmd}" unless handles_command?(cmd)
    if cmd[0] == 'ADDCOLUMN'
      @spreadsheet.add_column
    elsif cmd[0] == 'ADDROW'
      @spreadsheet.add_row
    elsif %w{REMOVECOLUMN REMOVEROW}.include?(cmd[0])
      specified_index = if cmd[0] == 'REMOVEROW' || cmd[0] =~ /^\d+$/
        cmd[1].to_i
      else
        Formatter.column_label_to_index(cmd[1].upcase)
      end
      if cmd[0] == 'REMOVECOLUMN'
        if @spreadsheet.can_remove_column?(specified_index)
          @spreadsheet.remove_column(specified_index)
        else
          puts "Cannot remove column #{cmd[1]} (#{specified_index})."
        end
      elsif cmd[0] == 'REMOVEROW'
        if @spreadsheet.can_remove_row?(specified_index)
          @spreadsheet.remove_row(specified_index)
        else
          puts "Cannot remove row #{cmd[1]} (#{specified_index})."
        end
      else
        puts "Unexpected cmd[0]: #{cmd[0]}"
      end
    elsif %{GET SET}.include?(cmd[0])
      if cmd[1] =~ /^[A-Z]+[0-9]+$/
        value = cmd[2..-1].join(' ') if cmd[0] == 'SET'
        row_idx = cmd[1].match(/([0-9]+$)/)[0].to_i
        col_idx = Formatter.column_label_to_index(cmd[1].match(/(^[A-Z]+)/)[0])
      else
        value = cmd[3..-1].join(' ') if cmd[0] == 'SET'
        [cmd[1].to_i, cmd[2].to_i]
      end
      if row_idx.nil? || col_idx.nil?
        puts "Invalid cell reference: #{cmd[1]}"
      elsif cmd[0] == 'GET'
        puts @spreadsheet.get_cell(row_idx, col_idx)
      elsif cmd[0] == 'SET'
        @spreadsheet.set_cell(row_idx, col_idx, value)
      else
        raise "Unexpected cmd[0]: #{cmd[0]}"
      end
    else
      raise "Unhandled cmd: #{cmd}"
    end
  end

end
