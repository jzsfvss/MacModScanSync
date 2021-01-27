function opt = OptSel(opts, vh, mxlst, menutxt)
% Purpose:		Prompts a selection from a text menu of options.
%
% Input:
% opts 			The menu items, a cell vector of strings.
% vh 			Vertical (1) / horizontal (2) menu.
% mxlst 		Max. no. of horizontal menu items to display.
% menutxt 		Remark / suggestion to display for selection.
%
% Output:
% opt 			Chosen menu item number.

if (nargin < 2) vh = 1; end

if (nargin < 3) mxlst = 5; end % Max. no. of options listed horizontally.

if (nargin < 4)
	menutxt = '';
else
	menutxt = [ '(', menutxt, ') ' ];
end

nopt = max(size(opts))-1;
dl = 1;

if ((nopt <= mxlst) && (vh ~= 1)) % 1
	sopt = [ opts{1, 1}, ': (1) ', opts{1, 2} ];
	for k = 3:(nopt+1) % 2
		sopt = [ sopt, ', (', num2str(k-1), ') ', opts{1, k} ];
	end % 2
	sopt = [ sopt ];
end % 1

while (dl) % 1

if ((nopt <= mxlst) && (vh ~= 1)) % 2

disp(sopt);

else % 2

if (vh == 1) % 7

disp([ opts{1, 1}, ':' ]);

for k = 2:(nopt+1) % 3
	if ((nopt >= 10) && (k-1 < 10)) % 4
		sp = ' ';
	else % 4
		sp = '';
	end % 4
	disp([ sp, num2str(k-1), '. ', opts{1, k} ]);
end % 3

else % 7

disp([ opts{1, 1}, ':' ]);

k = 1;
while (k < nopt+1) % 8
	k = k+1;
	if ((nopt >= 10) && (k-1 < 10)) % 11
		sp = ' ';
	else % 11
		sp = '';
	end % 11
	sopt = [ sp, '(', num2str(k-1), ') ', opts{1, k} ];
	for j = 2:mxlst % 9
		k = k+1;
		if (k <= nopt+1) % 10
			if ((nopt >= 10) && (k-1 < 10)) % 12
				sp = ' ';
			else % 12
				sp = '';
			end % 12
			sopt = [ sopt, ', ', sp, '(', num2str(k-1), ') ', opts{1, k} ];
		end % 10
	end % 9
	disp(sopt);
end % 8

end % 7

end % 2

% Option selection:
opt = input([ 'Selection ', menutxt, '= ' ]);
notopt = 0;
i = 0;
while ((~notopt) && (i < length(opt))) % 13
	i = i+1;
	notopt = (sum(opt(i) == (1:nopt)) == 0);
end % 13
if (notopt) % 5
	disp('Invalid selection! Please try again.');
	%if (nopt > mxlst) % 6
	disp(' ');
	%end % 6
else % 5
	dl = 0;
end % 5

end % 1