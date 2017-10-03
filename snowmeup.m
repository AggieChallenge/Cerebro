function [snowball, Hist, LastT, Diff] = snowmeup(Feature1,Hist,LastT);
        %NOTE: With this function, we wont need to discard any annotation
        %NOTE: Before running this, you must initialize:
            %Hist = zeros(8,30); and LastT = zeros(8,1);
        
        diff1 = Feature1(:,1:30) - Hist; %First 30 points - points 30 sec in past
        diff2 = Feature1(:,31:end) - Feature1(:,1:end-30); %Points 31:end - historical points in our data set
        Diff = [diff1,diff2]; %Combined together, we have original length of Feature1
        
        T(:,1) = LastT; %This will make our starting point wherever we left off in previous loop run
        for n=1:length(Diff)
            T(:,n+1) = Diff(:,n) + T(:,n); %Diff now - Previous Loop Run Total = New Run Total
        end
        
        snowball = T(:,2:n+1); %First Total is what our previous run gave so discard it
        Hist = Feature1(:,end-29:end); %Save these features for next run to use
        LastT = snowball(:,end);%Save this run's Last Total so next run can use it in calculation
    end
