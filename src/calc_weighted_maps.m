function maps = calc_weighted_maps(segments, W)

% average voting
n_segment = numel(segments);
n_frame = max(cell2mat(cellfun(@numel, segments, 'Un', false)));

if ~exist('W', 'var')
    W = ones(n_segment, 1) / n_segment;
end

[h, w] = size(segments{1}{1});

maps = cell(n_frame, 1);

for it_f = 1 : n_frame
    masks = zeros(h,w);
    for it_s = 1 : n_segment
        if any(segments{it_s}{it_f}(:))
            masks = masks + W(it_s) * segments{it_s}{it_f};
        end
    end
    maps{it_f} = (masks - min(masks(:))) / (max(masks(:)) - min(masks(:)));
end