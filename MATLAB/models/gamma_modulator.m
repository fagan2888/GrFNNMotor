% implementation of the Runge Kutta method

clear all;close all;clc;

% parameters of the gamma oscillator
z01 = 0;
alpha1 = -10;
beta1 = 0;
beta2 = 0;
epsilon1 = 20;
f1 = 80;

% parameters of the modulating oscillator
z02 = 0.0001;
alpha2 = -100;
beta12 = 0;
beta22 = 0;
epsilon2 = 1;
f2 = 0.5;

% parameters for time
fs = 1000;
dur = 10; % in seconds
T = 1/fs;
time = 0:T:dur;

ntime = length(time);

% initialize empty arrays
t_out = zeros(size(time));
z_out_1 = zeros(size(time));
z_out_2 = zeros(size(time));

t_out(1) = time(1);
z_out_1(1) = z01;
z_out_2(1) = z02;

% coupling parameter
c12 = 200;

% add an input
input = zeros(size(time));
ntaps = 4;
for i=1:ntaps
    input(fs*2*i) = 1;%hann(100+1);
end

for i=1:ntime-1
    
    %%% first layer %%%
    
    k1 = z_out_1(i)*(alpha1 + 1i*2*pi*f1 + beta1*abs(z_out_1(i))^2 + ...
        ((epsilon1*beta2*abs(z_out_1(i)))^4)/(1-epsilon1*abs(z_out_1(i))^2)) + input(i);
    
    z1 = z_out_1(i)+(T/2)*k1;
    
    k2 = z1*(alpha1 + 1i*2*pi*f1 + beta1*abs(z1)^2 + ...
        ((epsilon1*beta2*abs(z1))^4)/(1-epsilon1*abs(z1)^2)) + (input(i) + input(i+1))/2;
    
    z2 = z_out_1(i)+(T/2)*k2;
    
    k3 = z2*(alpha1 + 1i*2*pi*f1 + beta1*abs(z2)^2 + ...
        ((epsilon1*beta2*abs(z2))^4)/(1-epsilon1*abs(z2)^2)) + (input(i) + input(i+1))/2;
    
    z3 = z_out_1(i)+T*k3;
    
    k4 = z3*(alpha1 + 1i*2*pi*f1 + beta1*abs(z3)^2 + ...
        ((epsilon1*beta2*abs(z3))^4)/(1-epsilon1*abs(z3)^2)) + (input(i));
    
    z_out_1(i+1) = z_out_1(i) + (1/6)*T*(k1+(2*k2)+(2*k3)+k4);
    
    %%% second layer %%%
    
    k1 = z_out_2(i)*(alpha2 + 1i*2*pi*f2 + beta12*abs(z_out_2(i))^2 + ...
        ((epsilon2*beta22*abs(z_out_2(i)))^4)/(1-epsilon2*abs(z_out_2(i))^2)) + c12*(z_out_1(i));
    
    z1 = z_out_2(i)+(T/2)*k1;
    
    k2 = z1*(alpha2 + 1i*2*pi*f2 + beta12*abs(z1)^2 + ...
        ((epsilon2*beta22*abs(z1))^4)/(1-epsilon2*abs(z1)^2)) + c12*(z_out_1(i) + z_out_1(i+1))/2;
    
    z2 = z_out_2(i)+(T/2)*k2;
    
    k3 = z2*(alpha2 + 1i*2*pi*f2 + beta12*abs(z2)^2 + ...
        ((epsilon2*beta22*abs(z2))^4)/(1-epsilon2*abs(z2)^2)) + c12*(z_out_1(i) + z_out_1(i+1))/2;
    
    z3 = z_out_2(i)+T*k3;
    
    k4 = z3*(alpha2 + 1i*2*pi*f2 + beta12*abs(z3)^2 + ...
        ((epsilon2*beta22*abs(z3))^4)/(1-epsilon2*abs(z3)^2)) + c12*(z_out_1(i));
    
    z_out_2(i+1) = z_out_2(i) + (1/6)*T*(k1+(2*k2)+(2*k3)+k4);            
    
    t_out(i+1) = t_out(i) + T;
    
end

figure(1)
axis square
subplot(1,2,1)
plot((z_out_1));
title('Oscillator 1')
grid on
subplot(1,2,2)
plot((z_out_2));
grid on
title('Oscillator 2')

figure(2)
subplot(3,1,1)
plot(time,abs(z_out_1))
grid on
title('Magnitude')
subplot(3,1,2)
plot(time,input)
grid on
title('Input')
subplot(3,1,3)
spectrogram(z_out_1,kaiser(256,5),220,20000,fs,'yaxis')
title('Spectrum')
ylim([0 100])
xlabel('time(s)')

figure(3)
subplot(3,1,1)
% plot3(time,real(z_out_2),imag(z_out_2))
plot(abs(z_out_2))
axis tight
grid on
title('Magnitude')
subplot(3,1,2)
plot(time,real(z_out_1))
grid on
title('Input')
subplot(3,1,3)
spectrogram(z_out_2,kaiser(256,5),220,20000,fs,'yaxis')
title('Spectrum')
ylim([0 100])
xlabel('time(s)')