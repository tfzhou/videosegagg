function clusterProb = calcClusterProb(X, center, histProb, maxValidD)
  
  nx = size(X, 1);
  nc = size(center, 1);
  
  clusterProb = zeros(nx, 1);
  
  batch_size = 2000;
  num_batch = ceil(nx / batch_size);
  for j=1:num_batch
    xIdx = (j-1)*batch_size+1: min(nx, j*batch_size);
    tempX = X(xIdx, :);
    tnx = size(tempX, 1);
    
    [ix, ic] = ndgrid(1:tnx, 1:nc);
    td = reshape(sqrt(sum((tempX(ix,:)-center(ic,:)).^2, 2)), tnx, nc);
    
    prob = exp(-td/maxValidD*2);
    prob(td>maxValidD*1.5) = 0;
    prob = prob./repmat(sum(prob,2)+eps,1,size(prob,2));
    
    tp = sum(prob.*repmat(histProb, tnx, 1),2);
    clusterProb(xIdx) = tp;
  end
