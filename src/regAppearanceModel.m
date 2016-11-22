function appear_masks = regAppearanceModel( frames, coarse_masks )

appear_masks = cell(numel(frames), 1);
[h, w, c] = size(frames{1});
sz = h*w;

seMask  = strel('disk', 10);
seCover = strel('disk', 30);
seFull  = strel('disk', 50);

for i = 1 : numel(coarse_masks)
  segMask{i} = imerode(coarse_masks{i}, seMask);
  segMaskCover{i}= imdilate(coarse_masks{i}, seCover);
  segMaskFull{i}= imdilate(coarse_masks{i}, seFull);
end

centers = doCodebook(frames, segMaskCover);
histProb = doLinearReg(frames, coarse_masks, segMask, segMaskCover, centers);

cmap = uint8( 255 * jet(size(centers, 1)) );

% use matlabpool
if matlabpool('size') == 0
    matlabpool local 6
end

parfor it_f = 1 : numel(frames)
  %progress('Calculate Appearance: ', it_f, numel(frames));
  idx = find(segMaskFull{it_f});
  %     if isempty(idx); idx = 1 : sz; end
  
%   idx = 1 : sz; % compute foreground probability for the whole image
  
  rgbData = [];
  rgbData(:,1) = frames{it_f}(idx);
  rgbData(:,2) = frames{it_f}(idx + sz);
  rgbData(:,3) = frames{it_f}(idx + sz*2);
  
  cp = calcClusterProb( rgbData, centers, histProb, 10);
  
  mask = zeros(h, w);
  mask(idx) = cp;
  
  cp = uint8(cp*255);
  tim1 = frames{it_f};
  tim1(idx) = cp;
  tim1(idx + sz) = cp;
  tim1(idx + sz*2) = cp;
  
  appear_masks{it_f} = mask;
end

if matlabpool('size') > 0
    matlabpool close
end

end

function centers = doCodebook(ims, segMaskCover)

[h, w, ~] = size(segMaskCover{1});
aSize = h * w;

centers = [];
for iFrm = 1 : numel(ims)
  
  if isempty(segMaskCover{iFrm}); continue; end
  
  idx = find(segMaskCover{iFrm});
  
  im = ims{iFrm};
  
  data = [];
  data(:, 1) = im(idx);
  data(:, 2) = im(idx + aSize);
  data(:, 3) = im(idx + aSize*2);
  
  centers = clusteringBySampling(data, centers, 10);
end

cc = centers - repmat(mean(centers), size(centers, 1), 1);
[u, s, v] = svd(cc);
[~, idx] = sort(u(:,1));
centers = centers(idx, :);
end

function histProb = doLinearReg(frames, segmentation, segMask, segMaskCover, centers)


numCenter = size(centers, 1);

totalHist = zeros(1, numCenter);
totalCov = zeros(numCenter, numCenter);

totalNum = 0;

[h, w, c] = size(frames{1});
aSize = h * w;

% use matlabpool
if matlabpool('size') == 0
    matlabpool local 6
end

parfor iFrm = 1 : numel(frames)  
  
  if isempty(segmentation{iFrm}); continue; end
  
  idx = find(segmentation{iFrm});
  
  im = frames{iFrm};
  
  data = [];
  data(:,1) = im(idx);
  data(:,2) = im(idx + aSize);
  data(:,3) = im(idx + aSize*2);
  
  [localCov, localHist, m] = regClusterHist(data, centers, 10);
  
  totalHist = totalHist + localHist;
  totalCov = totalCov + localCov;
  totalNum = totalNum + m;
  
  %%
  idx = find(segMaskCover{iFrm} - segMask{iFrm});
  data = [];
  
  data(:,1) = im(idx);
  data(:,2) = im(idx + aSize);
  data(:,3) = im(idx + aSize*2);
  
  [localCov, localHist, m] = regClusterHist(data, centers, 10);
  
  totalHist = totalHist + localHist*0;
  totalCov = totalCov + localCov;
  totalNum = totalNum + m;
  
end

if matlabpool('size') > 0
    matlabpool close
end

totalHist = totalHist / totalNum * 10;
totalCov = totalCov / totalNum * 10;

[u, d, v] = svd(totalCov);
md = max(d(:));

th = md*1e-6;

d(d<th) = 0;
idx = find(d>=th);

d(idx) = 1./d(idx);

invCov = v*d*(u');

histProb = invCov * totalHist(:);

histProb = histProb';
end

function [clusterCov, clusterHist, m] = regClusterHist(X, center, maxValidD)

nx = size(X, 1);
nc = size(center, 1);

clusterHist = zeros(1, nc);
clusterCov = zeros(nc, nc);
m = 0;

batch_size = 2000;
num_batch = ceil(nx / batch_size);
for j = 1 : num_batch
  xIdx = (j-1)*batch_size+1: min(nx, j*batch_size);
  tempX = X(xIdx, :);
  tnx = size(tempX, 1);
  
  [ix, ic] = ndgrid(1:tnx, 1:nc);
  td = reshape(sqrt(sum((tempX(ix,:)-center(ic,:)).^2, 2)), tnx, nc);
  
  minD = min(td, [], 2);
  td = td(minD<=maxValidD, :);
  
  prob = exp(-td/maxValidD*2);
  prob(td>maxValidD*1.5) = 0;
  prob = prob./repmat(sum(prob,2)+eps,1,size(prob,2));
  
  clusterCov = clusterCov + prob'*prob;
  clusterHist = clusterHist + sum(prob);
  m = m + size(td, 1);
end
end