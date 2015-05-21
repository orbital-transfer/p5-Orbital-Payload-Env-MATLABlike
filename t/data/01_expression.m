%== String followed by transpose
%-- input
''''.'
%-- success
% 1
%== 2 followed by $N transpose operators
%-- input
2'''''''''''''''''''''''''
%-- success
% 1
%==
%-- input
2.'
%-- success
% 1
%==
%-- input
2 .'
%-- success
% 1
%== Can not have a space between the two
%-- input
2 '
%-- success
% 0
%==
%-- input
2'
%-- success
% 1
