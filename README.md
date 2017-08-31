## Synopsis
Macro_Nowcast is a Matlab package that nowcasts macroeconomic indicators in a high frequency based on a set of component macroeconomic time series. It replicates the nowcasting model proposed by Beber, Brandt and Luisi (2015).

## Motivation
The official macroeconomic data such as GDP and inflation in many countries are released one month after the reference period. This delay in data publication makes the official macroeconomic data unusable in practice for investment management analysis because the available official data at any time is outdated. To get real-time macroeconomic data before the official data gets released, we need to use nowcasting methodology to estimate macroeconmoic data.

## Features
* Esimate macroeconomic indicators on daily basis using a large universe of macroeconomic news flow.
* Can handle dataset composed of data released at different frequencies and with missing obervations using forward-filling approach.
* Can handle non-stationary data series.
* Can handle the unbalanced panel issue and persistence issue of the data set using the correlation matrix estimator proposed by Stambaugh (1997) and the Newey-West correlation estimation.
* Use principle component analysis to combine macroeconmoic news flow into a nowcasting index.

## Installation
1. Clone or download it as a zip file.
2. Upzip the file and move the Macro_Nowcast folder under your Matlab project directory.
3. Use addpath('Macro_Nowcast') to add the foler into Matlab search path, and then all functions inside the folder should be accessible. After finishing using the package, you can use rmpath('Macro_Nowcast') to remove the folder from Matlab search path.
4. The main file of the package is nowcast.m. All the other files are functions used by the main file. Try to run the example data set 'data_nowcast.xlsx' as a start. All the data in the example data set are directly downloaded from Bloomberg.

## License
Macro_Nowcast is licensed under GPL v3.

## References
Beber, A., Brandt, M. W. & Luisi, M. (2015), ‘Distilling the macroeconomic news flow’, Journal of Financial Economics 117(3), 489–507.

Stambaugh, R. F. (1997), ‘Analyzing investments whose histories differ in length’, Journal of Financial Economics 45(3), 285–331.
