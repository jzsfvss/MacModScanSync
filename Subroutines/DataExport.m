function res = DataExport(inctable, fnmind, dataloc, T, layersm2)
% Purpose: 		Exports the transformed layers in the original and matrix format.
%
% Input:
% inctable 		A table containing the filenames and grid dimensions.
% fnmind 		The index of the file imported in inctable.
% dataloc 		Directory path containing the xls directory with the raw scan files.
% T 			The imported raw data table (for later format reference).
% layersm2 		The transformed layers over the standard grid.
%
% Output:
% res 			Boolean for whether the export was successful.

% Initialization:
Bnum = inctable{fnmind, 8};
fnm0 = inctable{fnmind, 1};
fnm = [ fnm0{1}, '.xls' ];
res = 1;

% T2 = T;
T2 = cell(size(T, 1), 1);
Tc = readcell([ dataloc, '/csv/', fnm0{1}, '.csv' ]);
Tc = Tc(2:end, :);
Tc{1, 3} = datetime(Tc{1, 3}, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Format', 'M/dd/yyyy');
Tc{1, 7} = datetime(Tc{1, 7}, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Format', 'M/dd/yyyy');

ln1 = TabSep(Tc(1, :));
for i = 1:23:(1 + (Bnum-1)*23)
	T2{i} = ln1;
end

k = 0;
for i = 1:2:21 % 1: layers
	k = k+1;
	layeri = layersm2{k};
	si = cell(Bnum, 1);
	
	for j = 1:Bnum  % 2: scan slice
		mij = layeri(j, :);
		sij = sprintf('%.0f\t' , mij);
		% sij = sij(1:(end-1)); % Remove final tab.
		si{j, 1} = sij;
	end % 2

	indsi = (2 + i):23:(2 + i + (Bnum-1)*23);
	T2(indsi - 1) = TabSep(Tc(indsi - 1, :)); % labels
	T2(indsi) = si; % values
end % 1

% Export all layers as one file in the original format:
% writetable(T2, [ dataloc, '/xls_p/', fnm ]);
fileID = fopen([ dataloc, '/xls_p/', fnm(1:(end-4)), '_p.xls' ], 'w');

% s0 = 'Lastname\tFirstname\tDOB\tPatientID\tEye\tImageID\tExamDate\tExamTime\tAQMVersion\tQuality\tARTMean\t';
s0 = {'Lastname', 'Firstname', 'DOB', 'PatientID', 'Eye', 'ImageID', 'ExamDate', 'ExamTime', 'AQMVersion', 'Quality', 'ARTMean'};
ls0 = length(s0);
for i = 1:ls0
	fprintf(fileID, '%s\t', s0{i});
end
fprintf(fileID, '\t\n');

ln = T2{1, 1};
% ln = ln{1};
ln = strsplit(ln, '\t');
ln = ln{1}; % Lastname.
lnl = length(ln);
nr = size(T2, 1);

for i = 1:nr % 1
	si = T2{i, 1};
	% si = si{1};
	fprintf(fileID, '%s\n', si);

	if ~isempty(si) % 4
	if strcmp(si(1:lnl), ln) % 2
		j = 0;
	else % 2
		j = j+1;
	end % 2
	end % 4

	if ((mod(j, 2) == 0) && (j ~= 0)) % 3
		fprintf(fileID, '\t\n');
	end % 3
end % 1

fclose(fileID);

% Export each layer as a separate file in comma-separated (csv) format:
for i = 1:11 % 1

if (i < 10) % 2
	sp = '0';
else % 2
	sp = '';
end % 2

% writematrix(layersm2{i}, [ dataloc, '/csv_p/', fnm(1:(end-4)), '_', sp, num2str(i), '.csv' ]);
dlmwrite([ dataloc, '/csv_p/', fnm(1:(end-4)), '_p_L', sp, num2str(i), '.csv' ], layersm2{i}, 'delimiter', ',', 'precision', '%.0f');

end % 1

res = 1;