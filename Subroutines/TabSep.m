function S = TabSep(C)

m = size(C, 1);
S = cell(m, 1);

% myf1 = @(s) [ char(string(s)), '\t' ];
myf1 = @(s) sprintf('%s\t', char(string(s)));
myf2 = @(c) [ cellfun(myf1, c(1:end-1), 'UniformOutput', false); c{end} ];
myf3 = @(c) [ c{:} ];
myf = @(c) myf3(myf2(c));

for j = 1:m

c = C(j, :)';

n = length(c);
for i = 1:n
	if ismissing(c{i})
		c{i} = '';
	end

	if isa(c{i}, 'double')
		c{i} = num2str(c{i});
	end
end

S{j} = myf(c);

end

if m == 1;
	S = S{1};
end