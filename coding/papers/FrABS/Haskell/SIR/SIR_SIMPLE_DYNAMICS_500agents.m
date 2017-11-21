dynamics = [
499.000,1.000,0.000;
499.000,1.000,0.000;
499.000,1.000,0.000;
498.000,2.000,0.000;
497.000,2.000,1.000;
497.000,2.000,1.000;
497.000,2.000,1.000;
495.000,4.000,1.000;
495.000,4.000,1.000;
494.000,4.000,2.000;
494.000,4.000,2.000;
493.000,5.000,2.000;
493.000,5.000,2.000;
492.000,5.000,3.000;
491.000,5.000,4.000;
489.000,7.000,4.000;
488.000,8.000,4.000;
486.000,10.000,4.000;
485.000,10.000,5.000;
483.000,10.000,7.000;
476.000,17.000,7.000;
474.000,16.000,10.000;
472.000,16.000,12.000;
470.000,17.000,13.000;
470.000,16.000,14.000;
466.000,19.000,15.000;
458.000,27.000,15.000;
453.000,29.000,18.000;
446.000,33.000,21.000;
437.000,42.000,21.000;
429.000,45.000,26.000;
419.000,50.000,31.000;
413.000,52.000,35.000;
407.000,56.000,37.000;
396.000,65.000,39.000;
390.000,68.000,42.000;
382.000,72.000,46.000;
371.000,76.000,53.000;
352.000,90.000,58.000;
336.000,100.000,64.000;
320.000,110.000,70.000;
300.000,123.000,77.000;
282.000,137.000,81.000;
270.000,141.000,89.000;
247.000,155.000,98.000;
232.000,155.000,113.000;
222.000,158.000,120.000;
205.000,160.000,135.000;
190.000,166.000,144.000;
173.000,174.000,153.000;
157.000,184.000,159.000;
148.000,184.000,168.000;
130.000,191.000,179.000;
123.000,186.000,191.000;
114.000,181.000,205.000;
108.000,179.000,213.000;
102.000,176.000,222.000;
93.000,176.000,231.000;
84.000,174.000,242.000;
81.000,165.000,254.000;
75.000,165.000,260.000;
70.000,160.000,270.000;
68.000,159.000,273.000;
63.000,150.000,287.000;
58.000,147.000,295.000;
52.000,146.000,302.000;
49.000,143.000,308.000;
44.000,139.000,317.000;
42.000,129.000,329.000;
40.000,120.000,340.000;
36.000,117.000,347.000;
33.000,113.000,354.000;
31.000,113.000,356.000;
28.000,106.000,366.000;
27.000,102.000,371.000;
26.000,100.000,374.000;
24.000,96.000,380.000;
20.000,92.000,388.000;
20.000,91.000,389.000;
19.000,87.000,394.000;
18.000,85.000,397.000;
16.000,78.000,406.000;
16.000,73.000,411.000;
16.000,66.000,418.000;
16.000,62.000,422.000;
15.000,57.000,428.000;
14.000,56.000,430.000;
14.000,55.000,431.000;
14.000,51.000,435.000;
14.000,49.000,437.000;
14.000,47.000,439.000;
13.000,42.000,445.000;
12.000,40.000,448.000;
11.000,37.000,452.000;
11.000,33.000,456.000;
11.000,31.000,458.000;
11.000,30.000,459.000;
11.000,27.000,462.000;
11.000,25.000,464.000;
11.000,22.000,467.000;
11.000,22.000,467.000;
11.000,22.000,467.000;
11.000,20.000,469.000;
11.000,20.000,469.000;
11.000,18.000,471.000;
11.000,14.000,475.000;
11.000,14.000,475.000;
11.000,13.000,476.000;
10.000,14.000,476.000;
10.000,14.000,476.000;
10.000,13.000,477.000;
10.000,13.000,477.000;
10.000,13.000,477.000;
10.000,13.000,477.000;
10.000,10.000,480.000;
10.000,9.000,481.000;
10.000,9.000,481.000;
10.000,8.000,482.000;
10.000,7.000,483.000;
10.000,7.000,483.000;
10.000,7.000,483.000;
10.000,5.000,485.000;
10.000,5.000,485.000;
10.000,5.000,485.000;
10.000,5.000,485.000;
10.000,4.000,486.000;
10.000,3.000,487.000;
10.000,3.000,487.000;
10.000,3.000,487.000;
10.000,2.000,488.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,1.000,489.000;
10.000,0.000,490.000;
];
susceptible = dynamics (:, 1);
infected = dynamics (:, 2);
recovered = dynamics (:, 3);
totalPopulation = susceptible(1) + infected(1) + recovered(1);
susceptibleRatio = susceptible ./ totalPopulation;
infectedRatio = infected ./ totalPopulation;
recoveredRatio = recovered ./ totalPopulation;
steps = length (susceptible);
indices = 0 : steps - 1;
figure
plot (indices, susceptibleRatio.', 'color', 'blue', 'linewidth', 2);
hold on
plot (indices, infectedRatio.', 'color', 'red', 'linewidth', 2);
hold on
plot (indices, recoveredRatio.', 'color', 'green', 'linewidth', 2);
set(gca,'YTick',0:0.05:1.0);
xlabel ('Time');
ylabel ('Population Ratio');
legend('Susceptible','Infected', 'Recovered');
