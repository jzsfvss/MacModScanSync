function [ layers, fnm, fnmind, inctable2, impsucc ] = DataImport(datalocxls, vh, inctable)
% Purpose: 		Imports raw / processed data files.
%
% Input:
% datalocxls 	Directory path containing the raw scan files in xls format.
% vh 			Vertical (1) / horizontal (2) menu.
% inctable 		Either empty, or a table containing the filenames and grid dimensions.
%
% Output:
% layers 		A cell vector of matrices containing each layer of the imported scan.
% fnm 			Name of the file imported.
% fnmind 		The index of the file imported in inctable.
% inctable2 	The updated / new table of filenames and grid dimensions.
% impsucc 		Boolean for whether the import was successful, meaning file found.

% Initialization:
isproc = (datalocxls(end) == 'p');
eit = isempty(inctable);

if (~isproc)
	dataloccsv = [ datalocxls(1:(end-3)), 'csv' ];
else
	dataloccsv = [ datalocxls(1:(end-5)), 'csv_p' ];
end

D = dir(datalocxls);
n = size(D, 1);
files = {};

% Creating the increments table:
if (eit) % 0

% Finding all .csv file names:
for i = 1:n % 1
	nm = D(i).name;
	if ((sum(strfind(nm, '.xls')) > 0) && nm(1) ~= '.') % 2
		files{end+1, 1} = nm;
	end % 2
end % 1
nf = size(files, 1);

disp([ 'Creating <scans.xlsx>...' ]);
tic;

Filename = {};
ID = [];
Visit = [];
Eye = [];
Ainc = zeros(nf, 1);
Binc = Ainc;
Anum = Ainc;
Bnum = Ainc;

for i = 1:nf % 3

fni = files{i};
fni2 = strsplit(fni, '.');
fnip = strsplit(fni2{1}, '_');

Filename{end+1, 1} = fni2{1};
ID(end+1) = str2num(fnip{1});
Visit(end+1) = str2num(fnip{2});
if strcmp(fnip{3}, 'od') % 4
	Eye = [ Eye, 'R' ];
else % 4
	Eye = [ Eye, 'L' ];
end % 4

end % 3

ID = ID';
Visit = Visit';
Eye = Eye';

inctable = table(Filename, ID, Visit, Eye, Ainc, Binc, Anum, Bnum);
inctable = sortrows(inctable, [ 2, 3, 4 ]);

cd('./Data');
writetable(inctable, 'scans.xlsx');
cd('..');

rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);

end % 0

% Selecting which file to import:
if isproc
	ginds = find(inctable{:, 5} ~= 0);
	inctable = inctable(ginds, :);
end

if (size(inctable, 1) > 1)
	if (eit) disp(' '); end
	idsel = OptSel2('Patient IDs-scans', inctable{:, 2}, 1, 10, 'ID; recommended: 15, 109, 255, 354');
	idrows = find(inctable{:, 2} == idsel);
else
	idrows = 1;
	idsel = inctable{1, 2};
end

if (length(idrows) > 1) % 1

files2 = inctable{idrows, 1};
nf2 = size(files2, 1);
filemenu = [ {'Patient files'}, reshape(files2, [ 1, nf2 ]) ];
disp(' ');
i = OptSel(filemenu, vh, 6);
fnmind = min(idrows) - 1 + i;

if ~isproc % 2
	fnm = [ files2{i}, '.xls' ];
else % 2
	fnm = [ files2{i}, '_p.xls' ];
end % 2

else % 1

sc = inctable{idrows, 1};
fnmind = idrows;

if ~isproc % 3
	fnm = [ sc{1}, '.xls' ];
else % 3
	fnm = [ sc{1}, '_p.xls' ];
end % 3

end % 1

% Set the increments if available:
Ainc = inctable{fnmind, 5};
Binc = inctable{fnmind, 6};
if (Ainc ==  0)
	Anum = 512;
	Bnum = 25;
else
	Anum = inctable{fnmind, 7};
	Bnum = inctable{fnmind, 8};
end

% if ~exist('./Data/csv') mkdir('./Data/csv'); end

if ~exist([ datalocxls, '\', fnm ]) % 1

layers = {};
inctable2 = inctable;
impsucc = 0;

disp(' ');
disp([ 'Cannot find <', fnm, '> under:' ]);
disp(datalocxls);

return

else % 1

fnm2 = [ fnm(1:(end-4)), '.csv' ];
if ~exist([ dataloccsv, '\', fnm2 ]) % 2
	pwd0 = pwd;
	cd(datalocxls);
	copyfile(fnm, [ dataloccsv, '\', fnm2 ]);
	cd(pwd0);
end % 2

end % 1

% Importing selected data:
layers = {};

disp(' ');
disp([ 'Importing <', fnm, '>...' ]);
tic;

T = readtable([ dataloccsv, '\', fnm2 ]);
Tc = table2cell(T);
mfun = @(c) MyStr2Num(c);

if size(T, 2) > 1 % 0

for i = 1:2:21 % 1: layers
	si = Tc((2 + i):23:(2 + i + (Bnum-1)*23), :);
	layers{end+1} = cell2mat(cellfun(mfun, si, 'UniformOutput', false));
end % 1

else % 0

for i = 1:2:21 % 1: layers
	si = T{(2 + i):23:(2 + i + (Bnum-1)*23), 1};
	layeri = [];
	for j = 1:Bnum % 2: scan slice
		sij = strsplit(si{j});
		mij = cellfun(mfun, sij(1:end));
		layeri = [ layeri; mij ];
	end % 2
	layers{end+1} = layeri;
end % 1

end % 0

inctable2 = inctable;

rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);

impsucc = 1;