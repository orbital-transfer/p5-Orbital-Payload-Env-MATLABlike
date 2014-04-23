%==
%-- input
if a == 1
	a = 2
end
%-- success
% 1
%==
%-- input
if a == 1
	a = 2
else
	a = 3
end
%-- success
% 1
%==
%-- input
if a == 1
	a = 2
	a = 4
elseif a == 0
	a = 3
	a = 6
end
%-- success
% 1
%==
%-- input
while a == 1
	a = 2
end
%-- success
% 1
