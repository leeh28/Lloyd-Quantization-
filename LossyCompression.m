%start new session
clear

% Store audio file named : 'audioSample.wav'
% Sampling frequency     : fs
% Sampling period        : ts
% Audio file values      : x
% Training set           : train_set
% Training set interval  : [start_sample , end_sample] sec
% # of q levels
% (i.e. resolution level): qlev
[x, fs]         = audioread('audioSample.wav');
ts              = 1/fs;
start_sample    = 0.5;
end_sample      = 2.5;
end_time        = ts*(length(x)-1);
qlev            = 8;

% Convert stereo to mono
% Extract training set from audio file
x           =(x(:,1)+x(:,2))/2;
train_set   = x(start_sample*fs:end_sample*fs);
t           = 0:ts:end_time;

%Lloyd's quantization
[r_lev,q_lev]   = lloyds(train_set,qlev);

% Uniform quantization
max_val         = max(abs(x));
q_uniform       = -max_val:2*max_val/(qlev-1):max_val ;
r_uniform       = zeros(1,length(r_lev));
for jj = 1:length(r_uniform)
    r_uniform(jj) = (q_uniform(jj)+q_uniform(jj+1))/2;
end

%Assign all values of original audio to uniform/optimum quantization levels
optimum                         = x;
uniform                         = x;
optimum(optimum<r_lev(1))       = q_lev(1);
uniform(uniform<r_uniform(1))   = q_uniform(1);
for ii = 1:length(r_lev)-1
    optimum(optimum<r_lev(ii+1)     & optimum>r_lev(ii)    ) = q_lev(ii+1);
    uniform(uniform<r_uniform(ii+1) & optimum>r_uniform(ii)) = q_uniform(ii+1);
end
optimum(optimum>r_lev(end)    ) = q_lev(end);
uniform(uniform>r_uniform(end)) = q_uniform(end);

%Calculate SQNRs for comparison
uSQNR = snr(x,x-uniform);
oSQNR = snr(x,x-optimum);

%Sound output for uniform and optimum compression
% sound(uniform,fs)
% sound(optimum,fs)
audiowrite('audioUniform.wav',uniform,fs)
audiowrite('audioOptimum.wav',optimum,fs)
%-------------------------------endfile-------------------------------%
%Output graph plot:
%Graph1 : Original audio file
%Graph2 : Uniform quantization
%Graph3 : Optimum quantization
figure
plot1 = subplot(3,1,1);
plot(plot1,t,x,'b')
title(plot1,'Original audio file')
xlabel(plot1,3)

plot2 = subplot(3,1,2);
hold on
    for k = 1:length(r_lev)
        plot(plot2,[0 end_time],q_uniform(k)*[1 1],'g--')
        plot(plot2,[0 end_time],r_uniform(k)*[1 1],'g:')
        plot(plot2,[0 end_time],q_uniform(k+1)*[1 1],'g--')
    end
    plot(plot2,t,x,'b');
    plot(t,uniform,'Color',[1 .5 0]);
hold off
title(plot2,'Uniform quantization')
xlabel(plot2,['SQNR: ',num2str(uSQNR)])

plot3 = subplot(3,1,3);
hold on
    for k = 1:length(r_lev)
        plot(plot3,[0 end_time],q_lev(k)*[1 1],'g--')
        plot(plot3,[0 end_time],r_lev(k)*[1 1],'g:')
        plot(plot3,[0 end_time],q_lev(k+1)*[1 1],'g--')
    end
    plot(plot3,t,x,'b');
    plot(t,optimum,'Color',[1 .5 0])
hold off
title(plot3,'Optimum quantization')
xlabel(plot3,['SQNR: ',num2str(oSQNR)])
%-------------------------------endfile-------------------------------%

figure %Graph 2 closer look
hold on
    for k = 1:length(r_lev)
        plot([0 end_time],q_uniform(k)*[1 1],'g--')
        plot([0 end_time],r_uniform(k)*[1 1],'g:')
        plot([0 end_time],q_uniform(k+1)*[1 1],'g--')
    end
    plot(t,x,'b');
    plot(t,uniform,'Color',[1 .5 0]);
hold off
title('Uniform quantization')
xlabel(['SQNR: ',num2str(uSQNR)])

figure %Graph 3 closer look
hold on
    for k = 1:length(r_lev)
        plot([0 end_time],q_lev(k)*[1 1],'g--')
        plot([0 end_time],r_lev(k)*[1 1],'g:')
        plot([0 end_time],q_lev(k+1)*[1 1],'g--')
    end
    plot(t,x,'b');
    plot(t,optimum,'Color',[1 .5 0])
hold off
title('Optimum quantization')
xlabel(['SQNR: ',num2str(oSQNR)])
