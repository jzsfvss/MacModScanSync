function s = MyMins(n)

ni = floor(n);
nd = n - ni;

if (ni >= 10)
	si = num2str(ni);
else
	si = [ '0', num2str(ni) ];
end

nd60 = round(60*nd);
if (nd60 >= 10)
	sd = num2str(nd60);
else
	sd = [ '0', num2str(nd60) ];
end

s = [ si, ':', sd ];