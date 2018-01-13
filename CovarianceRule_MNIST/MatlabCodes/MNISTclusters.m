function MNISTclusters(layerset, dataSize)
            
            firstparam = linspace(0,1,5);    %list of places to search for first parameter
            secondparam = linspace(0,1,5);    %list of places to search for second parameter
            [F,S] = ndgrid(firstparam, secondparam);
            fitresult = arrayfun(@(p1,p2) trainModel_yas(layerset,datasize,p1,p2), F, S); %run a fitting on every pair fittingfunction(F(J,K), S(J,K))
            [minval, minidx] = min(fitresult);
            bestFirst = F(minidx);
            bestSecond = S(minidx);
            obj.n = bestFirst;
            obj.o = bestSecond;
            
end