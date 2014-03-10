%==
%-- input
1 + 1 ; 1 + 1
%-- success
% 1
%==
%-- input
1 + 1 ; 1 + 1 ;
%-- success
% 1
%==
%-- input
1 + 1; 1 + 1;
%-- success
% 1
%==
%-- input
1 + 1;
1 + 1;
%-- success
% 1
%==
%-- input
1 + 1;

1 + 1;
%-- success
% 1
%==
%-- input
1 + 1;

1 + 1
%-- success
% 1
%==
%-- input
1 + 1
1 + 2
%-- success
% 1
%==
%-- comment
% can't have expressions on same line
%-- input
1 + 1 1 + 1
%-- success
% 0
%==
%-- input
1 , 1,
1;
%-- success
% 1
%==
%-- input
1 , 1;
%-- success
% 1
%==
%-- input
1 ; 1;
%-- success
% 1
