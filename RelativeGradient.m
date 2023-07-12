function [grad] = RelativeGradient(x,y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Error Handling
sizex = max([size(x,2), size(x,1)]);
sizexsmall = min([size(x,2), size(x,1)]);
sizey = max([size(y,2), size(y,1)]);
sizeysmall = min([size(y,2), size(y,1)]);
if(sizex ~= sizey || (size(y,2) ~= size(x,2) && size(y,1) ~= size(x,2)))
    grad = -99;
    disp("Array Sizes are Incompatable for Operation");
    return
elseif(sizexsmall ~= 1)
    disp("Expected a 1D Array for X")
    return
end
if size(x,2) ~= sizex
   x = x';
   y = y';
end

deltax = zeros(1,sizex-1);
deltay = zeros(sizeysmall,sizex-1);
grad = zeros(sizeysmall,sizex-1);
for i = 1:sizex - 1
deltax(i) = x(i+1) - x(i);
deltay(:,i) = y(:,i+1) - y(:,i);
grad(:,i) = deltay(:,i)./deltax(i);
end

return
end

