function res = MyStr2Num(s)
% Purpose: 		The built-in str2num generalized to "n/a" values.
%
% Input:
% s 			A string containing either a number or an 'n/a'.
%
% Output:
% res 			Either the number in the string or 0 for 'n/a'.

if ~ischar(s)
	res = s;
else
	if strcmp(s, 'n/a')
		res = 0;
	else
		res = str2num(s);
	end
end