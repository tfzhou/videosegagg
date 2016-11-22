function im = label2color(im, m, color)

if ~exist('color', 'var')
    color = [255 0 0];
end

im = uint8(0.2*255*cat(3,m*color(1),m*color(2),m*color(3))+0.8*double(im));