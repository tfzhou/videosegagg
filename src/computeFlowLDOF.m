function [fflows, bflows] = computeFlowLDOF(imnames,flow_dir,ext)
 
generate_ppm(imnames,ext);
video_dir=[fileparts(imnames(1).name) '/'];

fflows = cell(length(imnames)-1, 1);
bflows = cell(length(imnames)-1, 1);
 
% if matlabpool('size') <= 0
%     matlabpool open 6
% end

for t=1:length(imnames)-1
    fprintf('computing optical flow for frame #%d\n', t);
    imfile1_ppm=[video_dir get_image_name(imnames(t).name) '.ppm'];
    imfile2_ppm=[video_dir get_image_name(imnames(t+1).name) '.ppm'];
   
    if ~exist([flow_dir 'ForwardFlow'  int2str2(t-1, 3) '.flo'], 'file')
        system(['./ldof ' imfile1_ppm ' ' imfile2_ppm]);
        movefile([video_dir get_image_name(imnames(t).name) 'LDOF.flo'],...
            [flow_dir 'ForwardFlow'  int2str2(t-1, 3) '.flo']);
        
        movefile([video_dir get_image_name(imnames(t).name) 'LDOF.ppm'],...
            [flow_dir 'ForwardFlow' int2str2(t-1, 3) '.ppm']);
    end
    if   (~exist([flow_dir 'BackwardFlow'...
            int2str2(t-1, 3) '.flo'],'file'))
        system(['./ldof ' imfile2_ppm ' ' imfile1_ppm]);
        movefile([video_dir get_image_name(imnames(t+1).name) 'LDOF.flo'],...
            [flow_dir 'BackwardFlow' int2str2(t-1, 3) '.flo']);
        
        movefile([video_dir get_image_name(imnames(t+1).name) 'LDOF.ppm'],...
            [flow_dir 'BackwardFlow' int2str2(t-1, 3) '.ppm']);
    end
    
    fflows{t} = readFlowFile([flow_dir 'ForwardFlow'  int2str2(t-1, 3) '.flo']);
    bflows{t} = readFlowFile([flow_dir 'BackwardFlow'  int2str2(t-1, 3) '.flo']);
end

% if matlabpool('size') <= 0
%     matlabpool close
% end

% delete_ppm(imnames,ext);



    function generate_ppm(imnames,ext)
        
        if ~strcmp(ext,'ppm')
            for id = 1: length(imnames)
                imname = imnames(id).name;
                [video_dir, imstem]=fileparts(imname);
                img=imread(imname);
                imwrite(img,[video_dir '/' imstem '.ppm'],'ppm');
            end
        end
    end
 
    function delete_ppm(imnames,ext)
        if ~strcmp(ext,'ppm')
            for id = 1: length(imnames)
                imname = imnames(id).name;
                [video_dir, imstem]=fileparts(imname);
                if exist([video_dir '/' imstem '.ppm'],'file')
                    delete([video_dir '/' imstem '.ppm']);
                end
            end
        end
    end
end

