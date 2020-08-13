# rshift
An R library for paleoecology and regime shift analysis.

# Current commands:
**``RSI()``: performs STARS analysis (Rodionov, 2004) on a dataset. Takes 6 arguments (4 mandatory):**

  ``data`` - the dataframe that will be used.  
  ``col`` - the column we are measuring change on - variable 'X' in STARS.
  ``time`` - the column containing time units (e.g. age of a subsample)
  ``l`` - the cut-off length of a regime; affects sensitivity (see Rodionov, 2004)  
  ``prob`` - the p-value for significance of a regime shift. Defaults to p = 0.05  
  ``startrow`` - the row from which the algorithm starts - use if you want to ignore some rows. Defaults to 1  
  Result produced: a 2-column dataframe, with columns ``age`` (the time unit for each regime shift) and ``RSI``, the regime shift index for each shift.
