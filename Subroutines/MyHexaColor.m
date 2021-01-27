function [ col, coltxt ] = MyHexaColor(hexacode)
% Purpose:		Converts hexagesimal color code to MATLAB convention.
%
% Input:
% hexacode 		6-digit hexagesimal color code.
%
% Output:
% col 			3-element MATLAB color vector.
% coltxt 		The vector col in string format.

col = sscanf(hexacode, '%2x%2x%2x', [ 1, 3 ])/255;
coltxt = [ '[ ', num2str(col(1)), ', ', num2str(col(2)), ', ', num2str(col(3)), ' ]' ];