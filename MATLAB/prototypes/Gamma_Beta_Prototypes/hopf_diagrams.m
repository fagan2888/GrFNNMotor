%% Walk through a digitized difference equation:
% using the Runge Kutte method

% http://www.physics.utah.edu/~detar/phys6720/handouts/ode/ode/node1.html

clear all
close all
clc

F = @(t,r,alpha,beta1,beta2,epsilon) r*alpha + beta1*r^3 + (epsilon*beta2*r^5)/(1-epsilon*r^2);
r0 = 0.5;
% % critical hopf regime
% alpha = 0;
% beta1 = 1;
% beta2 = 0;
% epsilon = 0.001; % not actually used
% % supercritical hopf regime
% alpha = 10;
% beta1 = -1;
% beta2 = 0;
% epsilon = 0.001;
% supercritical double limit cycle
alpha = -1;
beta1 = 0.03;
beta2 = -50;
epsilon = 1;

fs = 100;
dur = 100; % in seconds
T = 1/fs;
time = 0:T:dur;

r = ode4(F,time,r0,alpha,beta1,beta2,epsilon);

plot(time,r)
ylabel('$A.U.$','Interpreter','Latex')
xlabel('$time(s)$','Interpreter','Latex')
grid on
figure(2);
drdt = diff(r);
plot((r(1:end-1)),drdt)
xlabel('$r$','Interpreter','Latex')
ylabel('$\frac{dr}{dt}$','Interpreter','Latex')
grid on
hold on
% 
% for i=1:length(drdt)
%    plot(r(i),drdt(i),'o')
%    hold on
%    pause
% end



