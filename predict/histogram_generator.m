function histogram_generator

top5 = csvread('top_5.csv', 1, 4);
top10 = csvread('top_10.csv', 1, 4);
top15 = csvread('top_15.csv', 1, 4);

bins = 0:.0005:.01+0.0005;

top5_h = histc(top5, bins);
top10_h = histc(top10, bins);
top15_h = histc(top15, bins);

M = horzcat(bins', top5_h, top5_h / sum(top5_h), top10_h, top10_h / sum(top10_h), top15_h, top15_h / sum(top15_h))

csvwrite('differences.csv', M)

end
