function [numsamples] = save_test_outputs(prefix, os, numsamples)
    % numsamples = 1;
    for o = os
        user = getenv('USER');
        filename = sprintf('TestOutput-%s-%s-%d', user, datestr(now, 30), numsamples);
        save(strcat(prefix, filename), 'o');
        numsamples = numsamples + 1;
    end
end