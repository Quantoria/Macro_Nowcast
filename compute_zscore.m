%{
    This file is part of Macro_Nowcast.

    Macro_Nowcast is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Macro_Nowcast is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
%}

% This is the function that scale given time series into zscore
%
% Author: Victoria Xie
% Contact: victorai.qt.xie@gmail.com

function [ result ] = compute_zscore( input )

n = size(input, 1);
mean_input = repmat(nanmean(input), n, 1);
std_input = repmat(nanstd(input), n, 1);

result = (input - mean_input)./std_input;

end

