%==
%-- input
1+1
%-- success
% 1
%==
%-- input
1 + 1
%-- success
% 1
%==
%-- input
1 +1
%-- success
% 1
%==
%-- input
1+ 1
%-- success
% 1
%==
%-- input
1+-1
%-- success
% 1
%==
%-- input
1 -- 1
%-- success
% 1
%==
%-- input
1+j
%-- success
% 1
%==
%-- input
1+2j
%-- success
% 1
%==
%-- input
1+-j
%-- success
% 1
%==
%-- input
1-2j
%-- success
% 1
%==
%-- input
1*2
%-- success
% 1
%==
%-- input
1/2
%-- success
% 1
%==
%-- input
1 + 2 * 1/2
%-- success
% 1
%==
%-- input
(1 + 2) * 1/2
%-- success
% 1
%==
%-- input
1 + 2 * (1+2)
%-- success
% 1
%==
%-- input
a + b
%-- success
% 1
%==
%-- input
a - b
%-- success
% 1
%==
%-- input
a * b
%-- success
% 1
%==
%-- input
a / b
%-- success
% 1
%==
%-- input
a \ b
%-- success
% 1
%==
%-- input
b & b && b | b || b
%-- success
% 1
%==
%-- input
b ./ b .* b.' + b' .\ b .^ 2
%-- success
% 1
%==
%-- input
a^2
%-- success
% 1
%==
%-- input
a >= b
%-- success
% 1
%==
%-- input
a == b
%-- success
% 1
%==
%-- comment
% unexpected operator
%-- input
a == >= b
%-- success
% 0
%==
%-- comment
% no such operator
%-- input
a .+ b
%-- success
% 0
