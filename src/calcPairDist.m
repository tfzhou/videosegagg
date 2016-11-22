function dist = calcPairDist(X, Y)
nx = size(X, 1);
ny = size(Y, 1);

dist = zeros(nx, ny);

batch_size = 2000;
num_batch = ceil(nx / batch_size);
for j=1:num_batch
    tempX = X((j-1)*batch_size+1: min(nx, j*batch_size), :);
    tnx = size(tempX, 1);
    
    [ix, iy] = ndgrid(1:tnx, 1:ny);
    td = sqrt(sum((tempX(ix,:)-Y(iy,:)).^2, 2));
    dist((j-1)*batch_size+1: min(nx, j*batch_size), :) = reshape(td, tnx, ny);
end
