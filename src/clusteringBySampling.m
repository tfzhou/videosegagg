function center = clusteringBySampling(X, center, maxDist)
  
  k = 100;
  
  newCenter = center;
  while 1
    if isempty(X)
      break;
    end
    
    if ~isempty(newCenter)
      dist = calcPairDist(X, newCenter);
      minD = min(dist, [], 2);
      X(minD <= maxDist, :) = [];
    end
    
    n = size(X,1);
    if n<1
      break;
    end
    
    tk = randperm(n);
    tk = tk(1:min(k, n));
    
    newCenter = X(tk, :);
    dist = calcPairDist(newCenter, newCenter);
    nc = size(dist, 1);
    [tii, tjj] = ndgrid(1:nc, 1:nc);
    idx = find(tii < tjj);
    tii = tii(idx);
    tjj = tjj(idx);
    idx = tii + (tjj-1)*nc;
    mask = false(nc, 1);
    mask(tjj(dist(idx) <= 2*maxDist)) = 1;
    newCenter(mask, :) = [];
    
    center = [center; newCenter];
  end
  
