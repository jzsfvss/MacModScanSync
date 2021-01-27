function sel = OptSel2(str, vec, cnt, maxcols, seltxt)
% Purpose:		Prompts a selection from a numerical menu of options.
%
% Input:
% str			Menu title string.
% vec 			A vector of numerical menu items.
% cnt 			Boolean for whether count identical elements (1) or not (0).
% maxcols 		Max. no. of horizontal menu items to display.
% seltxt 		Remark / suggestion to display for selection.
%
% Output:
% sel 			Chosen menu item number.

% Initialization:
% maxcols = 10;
vecu = unique(vec);
nvecu = length(vecu);
MyD = @(x) floor(log10(x)) + 1;

% Finding the max length:
maxd = MyD(vecu(end));
if cnt % 1
	vecuc = zeros(nvecu, 1);
	for i = 1:nvecu % 2
		vecuc(i) = sum(vec == vecu(i));
		dvecuc = MyD(vecuc(i));
		dvecu = MyD(vecu(i));
		maxd = max(maxd, dvecu + dvecuc + 1);
	end % 2
end % 1

disp([ str, ': ' ]);

i = 0;
for l = 1:ceil(nvecu/maxcols) % 1
	for j = 1:maxcols % 2
		i = i+1;
		if (i <= nvecu) % 3
			if (j > 1) % 4
				fprintf(', ');
			end % 4

			% Printing preceding spaces:
			if ~cnt % 8
				di = MyD(vecu(i));
			else % 8
				di = MyD(vecu(i)) + MyD(vecuc(i)) + 1;
			end % 8
			if (di < maxd) % 5
				for k = 1:(maxd-di) % 6
					fprintf(' ');
				end % 6
			end % 5

			% Printing ID and visit count:
			fprintf(num2str(vecu(i)));
			if cnt % 7
				fprintf('-');
				fprintf(num2str(vecuc(i)));
			end % 7
		end % 3
	end % 2
	fprintf('\n');
end	% 1

if (nargin < 5)
	sel = input('Selection = ');
else
	sel = input([ 'Selection (', seltxt, ') = ' ]);
end