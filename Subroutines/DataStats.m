function statst = DataStats(layersh, lnl, Anum, Bnum)
% Purpose: 		Calculates some statistics for the loaded data.
%
% Input:
% layersh 		The distance of the imported layers from the basement membrane (BM).
% lnl 			A cell vector containing the names of the layers.
% Anum 			The number of A-scan values in the grid.
% Bnum 			The number of B-scan values in the grid.
%
% Output:
% statst 		A table of statistics.

% Calculating each statistic per layer:
stats = zeros(11, 5);

for i = 1:10 % 1

layi = layersh{i};
layi2 = layersh{i+1};
layiv = layi(1:(Bnum*Anum));
layiv2 = layi2(1:(Bnum*Anum));

stats(i, 1) = sum(layiv - layiv2)/(Bnum*Anum);
stats(i, 2) = min(layiv);
stats(i, 3) = max(layiv);
stats(i, 4) = sum(layiv)/(Bnum*Anum);
stats(i, 5) = std(layiv);

end % 1

stats = [ stats, stats(:, 4) - 3*stats(:, 5), stats(:, 4) + 3*stats(:, 5) ];

% Turning absolute values into relative values:
relH = stats(1, 4);
stats = round(100*stats/relH);

% Creating the table:
statst = array2table(stats);
statst.Properties.VariableNames = {'Thickness', 'Min', 'Max', 'Ave', 'Std', 'Min3Std', 'Max3Std'};
statst.Properties.RowNames = lnl(1:11, 1)';