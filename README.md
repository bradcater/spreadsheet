spreadsheet
===========

This is a toy spreadsheet written in Ruby. It supports some simple functions:
  * ABS - the absolute value of a given cell
  * AVG (MEAN) - the average of a given cell(s)
  * CONCAT - the concatenation of a given cell(s)
  * DIV - the first given cell divided by the second given cell
  * EXP - the first given cell to the power of the second given cell
  * MAX - the maximum of a given cell(s)
  * MIN - the minimum of a given cell(s)
  * PROD - the product of a given cell(s)
  * REF - the value of a given cell
  * SUB - the first given cell minus the second given cell
  * SUM - the sum of a given cell(s)

It handles dependencies between cells and *should* `raise` if you attempt to create a dependency cycle.

You can run the cli via `bundle exec ruby run.rb`. It supports:
  * GET *row* *column*
  * SET *row* *column* *value*
  * SHOWCLASSES (in case you want to see what class each *value* has been mapped to)
  * QUIT (or EXIT)

You can save the current spreadsheet using `SAVE *filename*`. To load it later, use `LOAD *filename*`.

You can run the tests via `bundle exec ruby test.rb`.
