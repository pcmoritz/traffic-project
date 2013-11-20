function save_test_outputs(prefix, os)
    user = getenv('USER');
    filename = sprintf('TestOutput-%s-%d', user, datestr(now, 30));
    save(strcat(prefix, filename), os);
end