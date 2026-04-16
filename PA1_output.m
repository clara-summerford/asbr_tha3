%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Iterates through all trial files and combines all calculations for PA1 
% and outputs formatted text file containing pivot calibration values and 
% expected C coordinates for each frame. 
%
% Outputs:"NAME-OUTPUT-2.TXT" – output file for problem 1 generated using 
% our functions


addpath('HW3-PA1');
calbody_files = dir(fullfile('HW3-PA1', '*calbody.txt'));
calreadings_files = dir(fullfile('HW3-PA1', '*calreadings.txt'));
empivot_files = dir(fullfile('HW3-PA1', '*empivot.txt'));
optpivot_files = dir(fullfile('HW3-PA1', '*optpivot.txt'));


body_files = {calbody_files.name};
readings_files = {calreadings_files.name};
EM_pivot_files = {empivot_files.name};
opt_pivot_files = {optpivot_files.name};

for i = 1:length(body_files)
  
    % include pivot calibrations in output file
    [~, EM_post] = EM_pivot_cal(EM_pivot_files{i});
    [~, opt_post] = opt_pivot_cal(opt_pivot_files{i}, body_files{i});

    % calculated expected C coordinates on calibration object
    Cexp = C_expected(body_files{i}, readings_files{i});

    filename = split(body_files{i}, "-");
    filename(end) = {'output2.txt'};
    output_name = join(filename, "-");
    output_name = output_name{1};

    % writing values from current file to combined file
    combined_mat = [EM_post'; opt_post'; Cexp];

    fileID = fopen(fullfile('HW3-PA1', output_name),'w');
    fprintf(fileID,'%6s %6s %6s\n','27','8',output_name);
    fprintf(fileID,'%.2f %.2f %.2f\n',combined_mat');
    fclose(fileID);
    
end




