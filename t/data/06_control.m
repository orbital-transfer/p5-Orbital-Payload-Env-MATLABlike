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
%==
%-- input
while 0 end
%-- success
% 1
%==
%-- input
if 1 end
%-- success
% 1
%==
%-- input
if 1 disp('test'); end
%-- success
% 1
%== Must have a delimiter after disp()
%-- input
if 1 disp('test') end
%-- success
% 0
%==
%-- input
switch 1 otherwise end
%-- success
% 1
%==
%-- input
switch 1
	case 1
		1
	case 2
		2
	otherwise
		3
end
%-- success
% 1
%==
%-- input
try
catch
end
%-- success
% 1
%-- input
try
	1 + 1
catch ex
	2
end
%-- success
% 1
