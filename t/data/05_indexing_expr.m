%==
%-- input
a(:) * 2
%-- success
% 1
%==
%-- input
a(:, 4) + 1
%-- success
% 1
%==
%-- input
b = a(:, 4) + 1
%-- success
% 1
%==
%-- input
a(:, b) / 1
%-- success
% 1
