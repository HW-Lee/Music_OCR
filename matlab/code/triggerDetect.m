function [ regions ] = triggerDetect( sig, windowLength, overlapRate, threshVar, threshDC )
%TRIGGERDETECT Summary of this function goes here
%   Detailed explanation goes here

    N = floor( (length(sig)-windowLength)/(1-overlapRate)/windowLength );
    regions = [];
    for ii = 1:100*N
        startIdx = round(windowLength*(1-overlapRate))*(ii-1)+1;
        if startIdx+windowLength-1 > length(sig)
            break;
        end
        sig_win = sig(startIdx:startIdx+windowLength-1);
        if var(sig_win) < threshVar && mean(sig_win) < threshDC
            regions = [regions; startIdx startIdx+windowLength-1];
        end
    end

end

