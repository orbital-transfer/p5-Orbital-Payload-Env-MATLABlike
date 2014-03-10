%==
%-- input
a(2)
%-- success
% 1
%==
%-- input
a(2, 4)
%-- success
% 1
%==
%-- input
a(:, 4)
%-- success
% 1
%==
%-- comment
% can't have an empty index
%-- input
a(, 4)
%-- success
% 0
