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
  

    % calculated expected C coordinates on calibration object
    Cexp = C_expected(body_files{i}, readings_files{i});

    filename = split(body_files{i}, "-");
    input_file = filename(1) + "-" + filename(2) + "-" + filename(3) + "-output-test.txt";
    test_file = filename(1) + "-" + filename(2) + "-" + filename(3) + "-output1.txt";

    C_exp = readmatrix(input_file, NumHeaderLines=0);
    C_real = readmatrix(test_file, NumHeaderLines=1);
    C_real = C_real(3:end,:);

    % disp(size(C_exp))
    % disp(size(C_real))
    % disp(C_exp(1:4,:))
    % disp(C_real(1:4,:))

    % Compare calculated post position to ground truth

    tol = 1.0; % Output file is rounded to this value

    if all(abs(C_exp - C_real) < tol)
        test = true;
        disp('Test PASSED')
    else
        test = false;
        disp(filename(3))
        % fprintf('Failed test: %s', filename(3))
        
    end

    assert(all(abs(C_exp - C_real) < tol, 'all'), "ERROR: Calculated post position does not match output file.");


    
    

end




