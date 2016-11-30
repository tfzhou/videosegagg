% function data = prepare_data(seq, datainfo, params)

%% load frames
file_list = get_file_list([img_path seq], ext);
ts        = cell2struct(num2cell([1:length(file_list)]),'t',1);
file_list = cell2struct([struct2cell(file_list); struct2cell(ts')],...
    [fieldnames(file_list); fieldnames(ts)], 1);

frames = cell(numel(file_list), 1);
for i = 1 : numel(file_list)
    F = imread(file_list(i).name);
    frames{i} = F;
end

%% load segments
n_segmentor = length(segmentor_set);
segments = cell(n_segmentor, 1);
for it_seg = 1 : n_segmentor
    load([seg_path, segmentor_set{it_seg} '/res_' seq '.mat']);
    segments{it_seg} = segmentation;
end

nFrame          = min(cell2mat(cellfun(@numel, segments, 'Un', false)));

file_list  = file_list(1:nFrame);
frames     = frames(1:nFrame);
segments   = cellfun(@(x) x(1:nFrame), segments, 'Un', false);

%% load superpixels
sp_version = 'slic';
sp_dir = setdir(['data/', sp_version, '/']);
sp_file = [sp_dir seq, '.mat'];
if ~exist(sp_file, 'file')
    Es = cell(nFrame, 1);
    spmaps = cell(nFrame, 1);
    for it_f = 1 : nFrame
        if strcmpi(sp_version, 'slic')
            [sp, ~] = slicmex(frames{it_f}, 4000, 20);
            spmaps{it_f} = sp + 1;
        end
    end
    
    save(sp_file, 'spmaps');
else
    load(sp_file);
end

superpixels = spmaps;

%% load optical flows
flow_version = 'ldof';
flow_dir = setdir(['data/flow/' flow_version '/' seq 'Results/']);
if strcmpi(flow_version, 'ldof')
    [fflows, bflows] = computeFlowLDOF(file_list, flow_dir, ext);
end
