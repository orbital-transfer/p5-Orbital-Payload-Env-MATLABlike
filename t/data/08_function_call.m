%== Tilde output discards output
%-- input
[~] = f
%-- success
% 1
%== Tilde output must be in [ ] delimiters
%-- input
~ = f
%-- success
% 0
%== Assign to single variable
%-- input
x = f
%-- success
% 1
%==
%-- input
x = f(a,b,c)
%-- success
% 1
%==
%-- input
[x] = f(a,b,c)
%-- success
% 1
%==
%-- input
[x,y] = f(a,b,c)
%-- success
% 1
%==
%-- input
[x,~] = f(a,b,c)
%-- success
% 1
%==
%-- input
[] = f(a,b,c)
%-- success
% 0
%==
%-- input
x = f(a,~,c)
%-- success
% 0
%==
%-- input
x, y = f(a,c)
%-- success
% 1
%== Must be in [ ]
%-- input
x y = f(a,c)
%-- success
% 0
%==
%-- input
[x y] = f(a,c)
%-- success
% 1
%==
%-- input
[x y, z] = f(a,c)
%-- success
% 1
%==
%-- input
[x y, z] = f(a c)
%-- success
% 0
