function histogram_generator
    
top5 = csvread('top_5.csv', 1, 4);
top10 = csvread('top_10.csv', 1, 4);
top15 = csvread('top_15.csv', 1, 4);

bins = 0:.0005:.01;
M = [bins; hist(top5, bins); hist(top10, bins); hist(top15, bins)]'

csvwrite('differences.csv', M)

end