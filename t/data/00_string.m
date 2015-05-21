%==
%-- input
'test'
%-- success
% 1
%==
%-- input
'\'
%-- success
% 1
%==
%-- input
''''
%-- success
% 1
%== Not an even number of quotes (should not be parsed as a string + ctranspose)
%-- input
'''''
%-- success
% 0
