%==
%-- input
function a
end
%-- success
% 1
%==
%-- input
function a()
end
%-- success
% 1
%==
%-- input
function = a
end
%-- success
% 0
%==
%-- input
function x = a
end
%-- success
% 1
%==
%-- input
function [x] = a
end
%-- success
% 1
%==
%-- input
function [x,y] = a
end
%-- success
% 1
%==
%-- input
function [x,y,z] = a
end
%-- success
% 1
%== Can't have a tilde on output args
%-- input
function [x,~,z] = a
end
%-- success
% 0
%==
%-- input
function x = a(b)
end
%-- success
% 1
%==
%-- input
function x = a(b , c)
end
%-- success
% 1
%==
%-- input
function x = a(b , c)
end
%-- success
% 1
