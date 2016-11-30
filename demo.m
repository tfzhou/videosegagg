clc;
close all;

addpath('src');

%% sequence
seq = 'birdfall';
ext = 'png';
img_path = 'data/';
seg_path = 'data/segments/';
gt_path = 'data/groundtruth/';

segmentor_set = {'CVPR13_DAGSeg', 'CVPR14_SeamSeg', 'CVPR15_JOTSeg', 'ICCV11_KeySeg', 'ICCV13_FastSeg'};

%% prepare data
script_prepare_data

%% aggregation
average_mask = calc_weighted_maps( segments );
average_mask = cellfun(@(x) x > 0.5, average_mask, 'Un', false);

reg_dir = setdir(['data/reg/']);
reg_file = [reg_dir seq '.mat'];
if ~exist(reg_file, 'file')
    regProbMaps = regAppearanceModel( frames, average_mask );
    save(reg_file, 'regProbMaps');
else
    load(reg_file)
end

results = superpixel_labelling_icme2016(frames, average_mask, superpixels, fflows, regProbMaps);

for i = 1 : length(results)
    imshow(label2color(frames{i}, results{i}))
    title(['frame #' int2str(i)])
    pause(1)
end