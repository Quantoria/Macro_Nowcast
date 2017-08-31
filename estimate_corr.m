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

% This is the function that that estimates correlation matrix of 
% unbalanced and persistent panel data based on methodology proposed by
% Stambaugh (1997) and Newey-West(1987)
%
% Author: Victoria Xie
% Contact: victorai.qt.xie@gmail.com

function [ result ] = estimate_corr( input )
% initialise the covariance matrix
v = NaN(size(input, 2));

% get number of non-nan observations of the first asset
t = sum(~isnan(input(:, 1)));
% get number of non-nan assets
n = sum(sum(~isnan(input))>0);
% transform input
input = input(end-t+1:end, 1:n);

%% calculate maximum likelihood estimators of covariance matrix V
% get the assets with number of non-nan observations equal to t
y = input(:, sum(~isnan(input))==t);
% calculate Newey-West covariance matrix of first block of series
i = size(y, 2);
v(1:i, 1:i) = covnw(y, 4);

while i<n
    % number of non-nan observations of the block
    s = sum(~isnan(input(:, i+1)));
    % get the assets with number of non-nan observations equal to s
    y = input(:, sum(~isnan(input))==s);
    % compute regression coefficients using the most recent s observations
    ylag = input(end-s+1:end, 1:i);
    x = [ones(s, 1), ylag];
    y = y(end-s+1:end, :);
    coeff = (x'*x)\x'*y;
    beta = coeff(2:end, :)';
    % compute Newey-West disturbance covariance matrix estimated
    % using the fitted residuals
    dcov = covnw(y-x*coeff, 4, 0);
    % compute covariance
    vlag = v(1:i, 1:i);
    i = i + size(y, 2);
    v(1:i, 1:i) = [vlag, vlag*beta'; beta*vlag, dcov + beta*vlag*beta'];
end

%% return correlation matrix
% standard deviations
sd = sqrt(diag(v));
% convert covariance matrix into correlation matrix
result = v./(sd*sd');

end
