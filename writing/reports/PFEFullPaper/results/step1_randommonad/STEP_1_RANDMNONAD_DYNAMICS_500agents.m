dynamics = [
499.0,1.0,0.0;
498.0,2.0,0.0;
498.0,2.0,0.0;
498.0,2.0,0.0;
497.0,2.0,1.0;
497.0,2.0,1.0;
496.0,3.0,1.0;
495.0,4.0,1.0;
494.0,5.0,1.0;
491.0,8.0,1.0;
489.0,10.0,1.0;
487.0,11.0,2.0;
485.0,12.0,3.0;
483.0,13.0,4.0;
480.0,15.0,5.0;
477.0,18.0,5.0;
471.0,21.0,8.0;
465.0,26.0,9.0;
460.0,30.0,10.0;
454.0,36.0,10.0;
443.0,45.0,12.0;
430.0,57.0,13.0;
420.0,60.0,20.0;
403.0,71.0,26.0;
385.0,84.0,31.0;
373.0,93.0,34.0;
353.0,109.0,38.0;
336.0,120.0,44.0;
324.0,126.0,50.0;
305.0,137.0,58.0;
289.0,145.0,66.0;
276.0,149.0,75.0;
256.0,161.0,83.0;
235.0,175.0,90.0;
216.0,183.0,101.0;
199.0,189.0,112.0;
183.0,194.0,123.0;
167.0,198.0,135.0;
151.0,199.0,150.0;
136.0,198.0,166.0;
133.0,193.0,174.0;
122.0,190.0,188.0;
115.0,191.0,194.0;
100.0,192.0,208.0;
90.0,187.0,223.0;
84.0,178.0,238.0;
74.0,176.0,250.0;
69.0,172.0,259.0;
64.0,168.0,268.0;
57.0,167.0,276.0;
53.0,161.0,286.0;
45.0,161.0,294.0;
43.0,153.0,304.0;
41.0,141.0,318.0;
40.0,134.0,326.0;
37.0,130.0,333.0;
35.0,128.0,337.0;
33.0,122.0,345.0;
30.0,118.0,352.0;
25.0,112.0,363.0;
23.0,105.0,372.0;
21.0,99.0,380.0;
21.0,90.0,389.0;
17.0,88.0,395.0;
17.0,85.0,398.0;
15.0,84.0,401.0;
14.0,80.0,406.0;
13.0,72.0,415.0;
12.0,66.0,422.0;
12.0,63.0,425.0;
11.0,61.0,428.0;
11.0,59.0,430.0;
11.0,54.0,435.0;
11.0,50.0,439.0;
11.0,46.0,443.0;
11.0,43.0,446.0;
11.0,40.0,449.0;
10.0,37.0,453.0;
10.0,37.0,453.0;
10.0,35.0,455.0;
10.0,34.0,456.0;
10.0,33.0,457.0;
9.0,31.0,460.0;
9.0,29.0,462.0;
9.0,27.0,464.0;
8.0,27.0,465.0;
8.0,25.0,467.0;
8.0,22.0,470.0;
7.0,23.0,470.0;
7.0,23.0,470.0;
7.0,21.0,472.0;
7.0,21.0,472.0;
7.0,17.0,476.0;
7.0,16.0,477.0;
6.0,16.0,478.0;
6.0,15.0,479.0;
6.0,14.0,480.0;
6.0,14.0,480.0;
6.0,12.0,482.0;
6.0,11.0,483.0;
6.0,10.0,484.0;
6.0,9.0,485.0;
6.0,8.0,486.0;
6.0,7.0,487.0;
6.0,7.0,487.0;
6.0,7.0,487.0;
5.0,7.0,488.0;
5.0,7.0,488.0;
5.0,6.0,489.0;
5.0,4.0,491.0;
5.0,4.0,491.0;
5.0,4.0,491.0;
5.0,4.0,491.0;
5.0,4.0,491.0;
5.0,4.0,491.0;
5.0,4.0,491.0;
5.0,4.0,491.0;
5.0,3.0,492.0;
5.0,3.0,492.0;
5.0,3.0,492.0;
5.0,3.0,492.0;
5.0,3.0,492.0;
5.0,3.0,492.0;
5.0,3.0,492.0;
5.0,2.0,493.0;
5.0,2.0,493.0;
5.0,2.0,493.0;
5.0,2.0,493.0;
5.0,2.0,493.0;
5.0,2.0,493.0;
5.0,2.0,493.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,1.0,494.0;
5.0,0.0,495.0;
5.0,0.0,495.0;
5.0,0.0,495.0;
5.0,0.0,495.0;
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
time = 0 : (1) : steps - 1;
replications = 10;
figure
plot (indices, susceptibleRatio.', 'color', 'blue', 'linewidth', 2);
hold on
plot (indices, infectedRatio.', 'color', 'red', 'linewidth', 2);
hold on
plot (indices, recoveredRatio.', 'color', 'green', 'linewidth', 2);
set(gca,'YTick',0:0.05:1.0);
set(gca,'XTick', indices(1:10:end), 'xticklabel', time(1:10:end));
xlabel ('Time');
ylabel ('Population Ratio');
legend('Susceptible','Infected', 'Recovered');
grid on