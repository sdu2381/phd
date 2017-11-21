dynamics = [
99.000,1.000,0.000;
99.000,1.000,0.000;
98.000,2.000,0.000;
96.000,4.000,0.000;
96.000,3.000,1.000;
95.000,4.000,1.000;
93.000,6.000,1.000;
91.000,8.000,1.000;
89.000,7.000,4.000;
88.000,7.000,5.000;
88.000,7.000,5.000;
86.000,8.000,6.000;
80.000,14.000,6.000;
78.000,16.000,6.000;
75.000,18.000,7.000;
75.000,14.000,11.000;
75.000,13.000,12.000;
72.000,16.000,12.000;
70.000,17.000,13.000;
66.000,20.000,14.000;
66.000,18.000,16.000;
63.000,19.000,18.000;
58.000,22.000,20.000;
57.000,21.000,22.000;
53.000,23.000,24.000;
52.000,23.000,25.000;
49.000,25.000,26.000;
48.000,23.000,29.000;
44.000,26.000,30.000;
42.000,27.000,31.000;
40.000,27.000,33.000;
40.000,26.000,34.000;
39.000,25.000,36.000;
38.000,25.000,37.000;
33.000,28.000,39.000;
31.000,27.000,42.000;
27.000,31.000,42.000;
27.000,29.000,44.000;
26.000,29.000,45.000;
25.000,28.000,47.000;
24.000,27.000,49.000;
23.000,27.000,50.000;
21.000,27.000,52.000;
20.000,28.000,52.000;
19.000,28.000,53.000;
17.000,29.000,54.000;
17.000,23.000,60.000;
16.000,24.000,60.000;
16.000,22.000,62.000;
16.000,22.000,62.000;
15.000,23.000,62.000;
13.000,24.000,63.000;
12.000,23.000,65.000;
12.000,22.000,66.000;
9.000,23.000,68.000;
9.000,21.000,70.000;
9.000,20.000,71.000;
9.000,19.000,72.000;
9.000,19.000,72.000;
9.000,17.000,74.000;
9.000,17.000,74.000;
9.000,15.000,76.000;
9.000,13.000,78.000;
9.000,12.000,79.000;
9.000,12.000,79.000;
9.000,10.000,81.000;
8.000,9.000,83.000;
8.000,9.000,83.000;
8.000,9.000,83.000;
8.000,9.000,83.000;
8.000,9.000,83.000;
8.000,9.000,83.000;
8.000,9.000,83.000;
7.000,9.000,84.000;
7.000,8.000,85.000;
7.000,7.000,86.000;
7.000,7.000,86.000;
7.000,7.000,86.000;
7.000,7.000,86.000;
7.000,4.000,89.000;
7.000,4.000,89.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,3.000,90.000;
7.000,2.000,91.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,1.000,92.000;
7.000,0.000,93.000;
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
