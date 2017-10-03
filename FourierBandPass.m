function [FilteredData] = FourierBandPass(InData,FreqSamp,LowPassFreq,HighPassFreq)
%Band-pass filter using cutoff of fourier transformation
% Input is the data, sampling frequency, low pass frequency and high pass
% frequency

FFTFilter = fft(InData);
HighOffPoint =  ceil((HighPassFreq*length(FFTFilter))/FreqSamp);
LowOffPoint = ceil((LowPassFreq*length(FFTFilter))/FreqSamp);
 %set 0 for all fft value in [CutOffPoint length-CutOffPoint] high cut off
 %point
FFTFilter(HighOffPoint:length(FFTFilter)-HighOffPoint) = 0;
% Set 0 from 1: LowOffPoint and the symatric part
FFTFilter(1:LowOffPoint)= 0;
FFTFilter(length(FFTFilter)-LowOffPoint:length(FFTFilter)) = 0;

FilteredData = real(ifft(FFTFilter));

end

