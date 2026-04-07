%% ME384R - ASBR - THA3
% Written by Clara Summerford and Nathan Lovell
%
% Uses eyeInHandCalib to compare between the cases of clean and noisy
% calibration data.
%
% Outputs:

clear
clc

%%

% Load clean quaternion data for the calibration
[q_robot,q_sensor,t_robot,t_sensor] = data_quaternion();

% Perform calibration
X = eyeInHandCalib(q_robot,q_sensor,t_robot,t_sensor);

% Load noisy quaternion data for the calibration
[q_robot_n,q_sensor_n,t_robot_n,t_sensor_n] = data_quaternion_noisy();

% Perform calibration
X_noisy = eyeInHandCalib(q_robot_n,q_sensor_n,t_robot_n,t_sensor_n);

% Compare output calibration matrices
error1 = X - X_noisy

%%

% Repeat clean calibration, with the first half of the data
q_robot_half = q_robot(1:5,:);
q_sensor_half = q_sensor(1:5,:);
t_robot_half = t_robot(1:5,:);
t_sensor_half = t_sensor(1:5,:);

X_half = eyeInHandCalib(q_robot_half,q_sensor_half,t_robot_half,t_sensor_half);


% Repeat noisy calibration, with the first half of the data
q_robot_n_half = q_robot_n(1:5,:);
q_sensor_n_half = q_sensor_n(1:5,:);
t_robot_n_half = t_robot_n(1:5,:);
t_sensor_n_half = t_sensor_n(1:5,:);

X_n_half = eyeInHandCalib(q_robot_n_half,q_sensor_n_half,t_robot_n_half,t_sensor_n_half);

% Compare results from the two half-sets
error2 = X_half - X_n_half

% Compare full clean data to half noisy
error3 = X - X_n_half

