%==
%-- input
a = 1
%-- success
% 1
%==
%-- input
b = 1
%-- success
% 1
%==
%-- comment
% can't have underscore
%-- input
_b = 1
%-- success
% 0
%==
%-- input
b = 1, 1
%-- success
% 1
%==
%-- input
b = 1; 1
%-- success
% 1
%==
%-- input
b = 1; a = 2;
%-- success
% 1
