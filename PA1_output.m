%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Combines all calculations for PA1 and outputs formatted text file.
%
% Inputs: maybe no inputs, just call function
%
% Outputs:"NAME-OUTPUT-1.TXT" – output file for problem 1

% inputs must be nx3 array of points, where each row corresponds to a point
% at the columns correspond to the xyz values

% maybe just leave as a script
% function PA1_output()
    
% maybe add HW3-PA1 folder to path here to make program more robust     


calbody_files = dir(fullfile('HW3-PA1', '*calbody.txt'));
calreadings_files = dir(fullfile('HW3-PA1', '*calreadings.txt'));

body_files = {calbody_files.name};
readings_files = {calreadings_files.name};

for i = 1:length(body_files)

    % INSERT PIVOT CALIBRATION FUNCTIONS HERE !!


    % calculated expected C coordinates on calibration object
    Cexp = C_expected(body_files{i}, readings_files{i});

    filename = split(body_files{i}, "-");
    output_name = filename(1) + "-" + filename(2) + "-" + filename(3) + "-output-test.txt";

    % writing values from current file to combined file

    fileID = fopen(fullfile('HW3-PA1', output_name),'w');
    fprintf(fileID,'%6s %12s\n','x','exp(x)');% fix header
    fprintf(fileID,'%6.2f %12.8f\n',Cexp);
    fclose(fileID);
    

end




