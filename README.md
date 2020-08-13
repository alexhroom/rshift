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
  Result produced: a 2-column dataframe, with columns time (the time unit from the dataset for each regime shift) and ``RSI``, the regime shift index for each shift.  
  NB: col and time must both be in quotes.    
  
  ---
  
**``RSI_graph()``: Creates a pair of graphs from a dataset, one of a variable against time, and one of the RSI against time. Good for visualisation of regime shifts analysis. Takes 4 mandatory arguments:**

``data`` - the dataframe that will be used.  
 ``col`` - the column we are measuring change on - variable 'X' in STARS.  
 ``time`` - the column containing time units (e.g. age of a subsample)  
 ``rsi`` - the column containing RSI values - for best visualisation (i.e. both graphs on a 1:1 scale), ensure RSI values of 0 are 0's, rather than NA (for example, using the merge functionality of ``RSI()``.  
 Result produced: 2 graphs, one on top of the other, depicting as mentioned above.  
 NB: while ``RSI()`` requires quotes around col and time, this function DOES NOT WORK if the arguments are in quotes. I will fix this.
