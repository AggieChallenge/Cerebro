% THIS FILE IS TO EXTRACT Snowball PSD (the first 30 seconds are removed)

function [PSD] = PSDs(no_channel,record)

% no_channel = 20; % Input the position of channel T7-FT19
data = record(no_channel,:);
PSD = [];
for loop = 1:length(data)/256
    x = data(256*(loop-1)+1:256*loop);

    fs = 256;

    m = 256;%length(x);          % Window length
    n = pow2(nextpow2(m));  % Transform length
    y = fft(x,n);           % DFT, Discrete Fourier Transform
    % f = (0:n-1)*(fs/n);     % Frequency range
    power = y.*conj(y)/n;   % Power of the DFT
    % plot(f,power)
    lowbound = [0 3 6 9 12 15 18 21]; upbound = [3 6 9 12 15 18 21 25]; %8 filters 
    %lowbound = [21 25 28 31 34 37 40 43]; upbound = [25 28 31 34 37 40 43 46]; %8 filters 
    lowboundposition = lowbound./(fs/n)+1; upboundposition = upbound./(fs/n)+1; 
    one_PSD = [];
    for i = 1:length(lowbound)
        one_PSD(i) = sqrt(sum(power(lowboundposition(i):upboundposition(i)).^2)./(upboundposition(i)-lowboundposition(i)+1));

    end
    %end of PSD

    PSD = [PSD;one_PSD];
end
PSD = PSD';        
end
