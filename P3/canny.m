im = imread('blox.gif');
h = fspecial('gaussian');
im = imfilter(im, h, 'circular');
im = im2double(im);
h = fspecial('sobel');
gx = imfilter(im, h, 'replicate');
gy = imfilter(im, h', 'replicate');

gxy = sqrt(gx.^2 + gy.^2);
dgxy = round((180/pi) * atan(gy./gx));
d = [0 45 90 135];
dim = size(dgxy);
drgxy = zeros(dim);
for i = 1:dim(1)
    for j = 1:dim(2)
        [~, orden] = sort(abs(dgxy(i, j) - d));
        drgxy(i, j) = d(orden(1));
    end
end

imf = double(zeros(dim));
for i = 1:dim(1)
    for j = 1:dim(2)
        if drgxy(i, j) == 0
            max_g = max([gxy(max([i-1, 1]), j), gxy(i, j), gxy(min([i+1, dim(1)]),j)]);
        elseif drgxy(i, j) == 45
            max_g = max([gxy(max([i-1, 1]), max([j-1, 1])), gxy(i, j), gxy(min([i+1, dim(1)]), min([j+1, dim(2)]))]);
        elseif drgxy(i, j) == 90
            max_g = max([gxy(i, max([j-1, 1])), gxy(i, j), gxy(i, min([j+1, dim(2)]))]);
        elseif drgxy(i, j) == 135
            max_g = max([gxy(min([i+1, dim(1)]), max([j-1, 1])), gxy(i, j), gxy(max([i-1, 1]), min([j+1, dim(2)]))]);
        end
        if max_g == gxy(i,j)
            imf(i, j) = gxy(i, j);
        else
            imf(i, j) = 0;
        end
    end
end
imf = imf > 0.088923;
imshow(imf);

