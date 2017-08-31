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

% This is the function that nowcasts macroecnomic indicator using
% the methodology proposed by Beber, Brandt and Luisi(2015)
%
% Author: Victoria Xie
% Contact: victorai.qt.xie@gmail.com

%% load data downloaded from bloomberg excel plug-in
clear;
clc;
data = xlsread('data_nowcast.xlsx', 'US EMP');

%% conduct Dicky-Fuller test
num_series = (size(data, 2) + 1)/5;
series = NaN(size(data, 1), num_series);

for i = 1 : num_series
    % retrieve the actual release time series
    act_series = data(:, 5*(i-1)+3);
    % retrieve the current value of time series
    lst_series = data(:, 5*(i-1)+4);
    % replace nan actual release series with current value
    act_series(isnan(act_series)) = lst_series(isnan(act_series));
    % run dicky-fuller test
    if adftest(act_series)==0 % for data other than US OUTPUT
    %if i==3 % for US OUTPUT
        % if the series is nonstationary, take the first difference
        fprintf(num2str(i));
        if ~isnan(act_series(1))
            act_series(1) = 0;
        end
        act_series(2:end) = diff(act_series);
    end
    series(:, i) = act_series;
end

%% align data by moving from annoucement time to calendar time
% set time period of the full sample
dates = busdays('1/1/1980', '5/31/2017');
num_dates = size(dates, 1);

% construct real-time data matrix
rt_data = NaN(num_dates, num_series);

for i = 1 : num_series
    % retrieve the reference date of time series and convert into datenum
    ref_dates = x2mdate(data(:, 5*(i-1)+1));
    % retrieve the release date of time series in double format
    rls_dates = data(:, 5*(i-1)+2);
    % convert release date into datenum
    for t = 1 : size(rls_dates, 1)
        if ~isnan(rls_dates(t))
            rls_dates(t) = datenum(num2str(rls_dates(t)), 'yyyymmdd');
        end
    end
    % compute the median time between the reference and release dates
    lag = nanmedian(rls_dates-ref_dates);
    % estimate missing release date of time series
    for t = 1 : size(rls_dates, 1)
        if isnan(rls_dates(t))
            rls_date = ref_dates(t) + lag;
            % ensure release date is a business day
            if isbusday(rls_date)==0
                rls_date = busdate(rls_date);
            end
            rls_dates(t) = rls_date;
        end
    end
    
    % align actual time series data to corresponding calendar date
    for j = 1 : size(rls_dates, 1)
        rt_data(dates==rls_dates(j), i) = series(j, i);
    end
end

% forward-fill the missing data in real-time data matrix
for t = 2 : num_dates
    for n = 1 : num_series
        if isnan(rt_data(t, n))
            rt_data(t, n) = rt_data(t-1, n);
        end
    end
end

%% conduct principle component analysis to construct nowcaster

% set sample to start from Jan 2000
str_idx = find(dates==datenum('1/3/2000'));

% initialise nowcaster vector
nowcaster = NaN(num_dates-str_idx+1, 1);

% assume 21 days per month
d = 21; 

for t = str_idx:num_dates
    % standardise the telescoping time series
    sub_rt_data = compute_zscore(rt_data(1:t, :));
    % forward-fill the missing data in the sub real-time data matrix
    for i = 2 : size(sub_rt_data, 1)
        for n = 1 : size(sub_rt_data, 2)
            if isnan(sub_rt_data(i, n))
                sub_rt_data(i, n) = sub_rt_data(i-1, n);
            end
        end
    end
    % order series with number of non-NaN observations in descending manner
    [~, new_inds] = sort(sum(isnan(sub_rt_data)));
    sub_rt_data = sub_rt_data(:, new_inds);
    
    % calculate the subsample correlation matrices 
    sub_corr = NaN(num_series, num_series, d);
    for i = 0:d-1
        sub_dates = flip(t-i:-d:1);
        if sum(sum(~isnan(sub_rt_data(sub_dates, :))))==0
            % if the whole matrix is nan, set correlation matrix to NaN
            sub_corr(:, :, i+1) = NaN;
        else
            % otherwise calculate correaltion matrix
            sub_corr(:, :, i+1) = estimate_corr(sub_rt_data(sub_dates, :));
        end
    end
    
    % construct correlation matrix through averaging the subsample correlation matrices
    corr = nanmean(sub_corr, 3);
    
    % construct nowcaster through principle compnent analysis
    nnan_idx = ~all(isnan(corr));
    if ~sum(nnan_idx)==0
        % run principle component analysis
        coeff = pcacov(corr(nnan_idx, nnan_idx));
        % get most recent releases
        values = sub_rt_data(t, nnan_idx);
        % construct nowcaster
        nowcaster(t-str_idx+1) = values * coeff(:, 1);
    end
end

%% plot
plot(dates(str_idx:end), nowcaster);
datetick('x');
title('Nowcasters');
ylabel('Index');
xlabel('Year');