# rshift
An R library for paleoecology and regime shift analysis.  
These functions assume your data is in tidy format.

A detailed explanation of Rodionov's STARS algorithm, and how to use it for regime shift analysis in R, is [available here](https://github.com/alexhroom/rshift/blob/master/rshift%20STARS%20manual.pdf)

# Current commands:
**``Rodionov()``: performs STARS analysis (Rodionov, 2004) on a dataset. Takes 7 arguments (4 mandatory):**

  ``data`` - the dataframe that will be used.  
  ``col`` - the column we are measuring change on - variable 'X' in STARS.  
  ``time`` - the column containing time units (e.g. age of a subsample)  
  ``l`` - the cut-off length of a regime; affects sensitivity (see Rodionov, 2004)  
  ``prob`` - the p-value for significance of a regime shift. Defaults to p = 0.05  
  ``startrow`` - the row from which the algorithm starts - use if you want to ignore some rows. Defaults to 1  
  ``merge`` - changes the result to be either a regime-shift only table (if FALSE), or an addition to the original table (if TRUE); see below:
  Result produced: if merge = FALSE (default), produces a 2-column table of time (the time value for each regime shift) and RSI (the RSI for each regime shift). If merge = TRUE, returns the original dataset with an extra RSI column, giving the RSI for each time unit - 0 for non-shift years. 
  
  ---
  
**``RSI_graph()``: Creates a pair of graphs from a dataset, one of a variable against time, and one of the RSI against time. Good for visualisation of regime shifts analysis. Takes 4 mandatory arguments:**

``data`` - the dataframe that will be used.  
 ``col`` - the column we are measuring change on - variable 'X' in STARS.  
 ``time`` - the column containing time units (e.g. age of a subsample)  
 ``rsi`` - the column containing RSI values - for best visualisation (i.e. both graphs on a 1:1 scale), ensure RSI values of 0 are 0's, rather than NA (for example, using the merge functionality of ``Rodionov()``).  
 Result produced: 2 graphs, one on top of the other, depicting as mentioned above.  

  ---
**``Lanzante()``: Performs a L-test (Lanzante, 1996) to find regime shifts. Takes 5 arguments (3 mandatory):**

``data`` - the dataframe that will be used.   
``col`` - the column we are measuring change on - variable 'X' in STARS.  
``time`` - the column containing time units (e.g. age of a subsample)  
``p`` - the largest p-value you want to check regime shifts for. Defaults to p = 0.05.  
``merge`` - changes the result to be either a regime-shift only table (if FALSE), or an addition to the original table (if TRUE); see below:
Result produced: if merge = FALSE (default), produces a 2-column table of time (the time value for each regime shift) and p (the p-value for each regime shift). If merge = TRUE, returns the original dataset with an extra p-value column, giving the p-value for each time unit - 0 for non-shift years. 

NOTE: it may be useful to visualise this data - you can do so using RSI_graph as seen above, but use the p-value column for the RSI column.

  ---
  
 **``Hellinger_trans()``: Hellinger transforms data (*Nunerical Ecology*, Legendre and Legendre). Mutates the original dataset with a column containing Hellinger transformed values. Takes 3 mandatory arguments:**
 
 ``data`` - the dataframe that will be used.  
 ``col`` - the column we are measuring change on.  
 ``site`` - the column containing the site of each sample.
 Result produced: the original dataset, with an added column ``hellinger_trans_vals``, containing hellinger transformed values for each data point.
 
 ---
 
  **``absolute_to_percentage()``: Converts absolute abundance data for each site into percentage of total abundance per site. Takes 3 mandatory arguments:**
 
 ``data`` - the dataframe that will be used.  
 ``col`` - the column we are measuring change on.  
 ``site`` - the column containing the site of each sample.
 Result produced: the original dataset, with an added column ``percentage``, containing percentage abundance values for each data point.

---

**``rolling_autoc()``: Finds rolling autocorrelation over an interval. (Used experimentally for early warning signs: see Liu, Gao & Wang, 2018). Takes 3 mandatory arguments:**

``data`` - the dataframe that will be used.
``col`` - the column we are measuring change on.
``l`` - the time interval (no. of columns) used in the autocorrelation.
Result produced: a table of rolling lag-1 autocorrelation values.

