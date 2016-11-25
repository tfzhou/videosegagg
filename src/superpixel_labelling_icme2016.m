function results = superpixel_labelling_icme2016(frames, initialSegMask, superpixels, flows, regProbMaps, params)

if ~exist('params', 'var')
    params.aggWeight    = 10;
    params.unaryWeight     = 4;
    params.spatialWeight   = 4;
    params.temporalWeight  = 4;
    params.aggNorm         = 0.8;
    params.appearanceNorm  = 0.7;
    params.fade_out = 0.0001;
    params.fg_mix = 5;
    params.bg_mix = 8;
end

nframe = numel(frames);

[ superpixelsIU, nodeFrameId, bounds, nnodes ] = makeSuperpixelIndexUnique( superpixels );
[ colours, centres, ~ ] = getSuperpixelStats( frames, superpixelsIU, nnodes );

% Aggregation Prior
output = cell(nframe, 1);
for i = 1 : nframe
    output{i} = superpixelInRatio( uint16(superpixels{i}), logical(initialSegMask{i}) );
end

locationMasks = cell2mat(output);
aggUnaries = 0.5 * ones(nnodes, 2, 'single');
aggUnaries( 1: length( locationMasks ), 1 ) = ...
    locationMasks / (params.aggNorm * max(locationMasks));
aggUnaries( aggUnaries > 0.95 ) = 0.999;

for i = 1 : nframe
    start = bounds(i);
    stop = bounds(i+1)-1;
    
    frameMasks = aggUnaries(start:stop, 1);
    overThr = sum(frameMasks > 0.6) / single(stop - start);
    if overThr < 0.05
        E = 0.005;
    else
        E = 0.000;
    end
    
    aggUnaries(start:stop, 1) = max(aggUnaries(start:stop, 1), E);
end
aggUnaries(:, 2) = 1 - aggUnaries(:, 1);

% Appearance Model with spatial prior
accumProbMaps = cell(nframe, 1);
for i = 1 : nframe
    map = regProbMaps{i};
    map(map < 0) = 0;
    accumProbMaps{i} = map;
end

output = cell(nframe, 1);
for i = 1 : nframe
    output{i} = superpixelInForeGround( uint16(superpixels{i}), double(accumProbMaps{i}) );
end

appearanceMasks = cell2mat(output);
appearanceUnaries = 0.5 * ones(nnodes, 2, 'single');
appearanceUnaries( 1 : length(appearanceMasks), 1) = ...
    appearanceMasks / (params.appearanceNorm * max(appearanceMasks));
appearanceUnaries( appearanceUnaries > 0.95 ) = 0.999;

for i = 1 : nframe
    start = bounds(i);
    stop = bounds(i+1)-1;
    
    frameMasks = appearanceUnaries(start:stop, 1);
    overThr = sum(frameMasks > 0.6) / single(stop - start);
    if overThr < 0.05
        E = 0.005;
    else
        E = 0.000;
    end
    
    appearanceUnaries(start:stop, 1) = max(appearanceUnaries(start:stop, 1), E);
end
appearanceUnaries( :, 2 ) = 1 - appearanceUnaries( :, 1 );

unaryPotentials = -params.aggWeight * log(aggUnaries) - log(appearanceUnaries);


% Spatial Pairwise Potential
[sSource, sDestination] = getSpatialConnections( superpixelsIU, nnodes );
sSqrColourDistance = sum( ( colours( sSource + 1, : ) - colours( sDestination + 1, : ) ) .^ 2, 2 ) ;

sCentreDistance = sqrt( sum( ( centres( sSource + 1, : ) - centres( sDestination + 1, : ) ) .^ 2, 2 ) );
sBeta = 0.1 / mean( sSqrColourDistance ./ sCentreDistance );
sWeights = exp( -sBeta * sSqrColourDistance ) ./ sCentreDistance;

% Temporal Pairwise Potential
if ~isa(flows{1}, 'int16')
    flows = cellfun(@(x) int16(x), flows, 'UniformOutput', false);
end

if numel(flows) == numel(superpixels)
    flows = flows(1:end-1);
end
[ tSource, tDestination, tConnections ] = getTemporalConnections( flows, superpixelsIU, nnodes );
tSqrColourDistance = sum( ( colours( tSource + 1, : ) - colours( tDestination + 1, : ) ) .^ 2, 2 );
tBeta = 0.1 / mean( tSqrColourDistance .* tConnections );
tWeights = tConnections .* exp( -tBeta * tSqrColourDistance );

%
pairwisePotentials.source = [ sSource; tSource ];
pairwisePotentials.destination = [ sDestination; tDestination ];
pairwisePotentials.value = [ params.spatialWeight * sWeights; params.temporalWeight * tWeights ];

[ ~, GC_labels ] = maxflow_mex_optimisedWrapper( pairwisePotentials, single( 1500 * unaryPotentials ) );
results = superpixelToPixel( GC_labels, superpixelsIU );

% remove outliers
for i = 1 : numel(results)
    se = strel('disk', 1);
    tmpRes = imdilate(results{i}, se);
    
    CC = bwconncomp(tmpRes);
    numPixels = cellfun(@numel, CC.PixelIdxList);
    
    [~, idx] = max(numPixels);
    
    tmpRes = false(size(results{i}));
    tmpRes(CC.PixelIdxList{idx}) = true;
    
    results{i} = tmpRes & results{i};
    results{i} = imfill(results{i}, 'holes');
end
