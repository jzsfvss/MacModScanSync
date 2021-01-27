function [ img, fnm ] = ImgImport(dataloc, vh, itype)
% Purpose: 		Imports a cross-section image file from Imgs.
%
% Input:
% dataloc 		Directory containing the cross-section files in itype format.
% vh 			Vertical (1) / horizontal (2) menu.
% itype 		File extension to be sought for importing.
%
% Output:
% img 			The selected image imported as a matrix.
% fnm 			The filename of the selected image.

% Initialization:
D = dir(dataloc);
n = size(D, 1);
files = {};

% Finding all file names with the extension itype:
for i = 1:n % 1
	nm = D(i).name;
	if ((sum(strfind(nm, [ '.', itype ])) > 0) && nm(1) ~= '.') % 2
		files{end+1, 1} = nm;
	end % 2
end % 1
nf = size(files, 1);

% Selecting which file to import:
if (nf == 1)
	i = 1;
else
	filemenu = [ {'Import'}, reshape(files, [ 1, nf ]) ];
	disp(' ');
	i = OptSel(filemenu, vh);
end
fnm = files{i};

% Importing the selected image:
disp(' ');
disp([ 'Importing <', fnm, '>...' ]);
tic;

img = imread(fnm, itype);

rt = toc;
fprintf([ '\bdone in ', num2str(rt, '%.2f'), ' secs.\n' ]);