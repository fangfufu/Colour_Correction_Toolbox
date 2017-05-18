load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/sg140_reflectance.mat');
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/2degXYZCMFs.mat');
small_mat = dir('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/rgb/*.mat');
big_mat = dir('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/*.mat');
casper_wl = 400:4:400+4*75;
location_names = {'DarcyBookshelf','DarcyKitchenCorner','GreyRoomLightOn','LabFloor','LabFloorLightOn'};
for i = 1:numel(small_mat)
    load(['/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/rgb/', small_mat(i).name]);
    load(['/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/', big_mat(i).name], 'wp_radiance');
    illuminant =  (InterpData(wp_radiance, casper_wl, sg140_wl) ./ sg140_whiteTile)';
    illuminant = repmat(illuminant, 140, 1);
    sg140_radiance = sg140_reflectance .* illuminant;
    cmf = InterpData(cmf_xyz, cmf_wl, sg140_wl);
    sg140_xyz = sg140_radiance * cmf;
    xyz = RemoveEdgePatches(sg140_xyz);
    name = strsplit(checker_img_shading_name, '.');
    name = name{1};
    location = location_names{i};
    
    % renaming some variable for export storage.
    illuminant = illuminant(1,:)';
    sampling_wl = sg140_wl;
    save(['/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/export/', name, '_export.mat'], 'xyz', 'rgb_shading', 'rgb_noshading', 'name', 'sampling_wl', 'illuminant', 'location'); 
end
