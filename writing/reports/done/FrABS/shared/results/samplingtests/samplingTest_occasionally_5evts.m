dtAvgs = [
5.000,200.000;
2.000,499.990;
1.000,993.250;
0.500,1832.400;
0.200,3160.900;
0.100,3940.460;
0.050,4422.280;
0.020,4747.010;
0.010,4870.890;
];
ecsTheory = 5000.0;
dt = dtAvgs (:, 1);
avg = dtAvgs (:, 2);
minDt = min(dt);
maxDt = max(dt);
n = length (dt);
ecsTheoryLinePoints = n + 1;
ecsTheoryLineX = [0; dt];
ecsTheoryLineY = ones(ecsTheoryLinePoints, 1) * ecsTheory;
figure;
semilogx (dt, avg, 'color', 'blue', 'linewidth', 2);
hold on
plot (ecsTheoryLineX, ecsTheoryLineY, 'color', 'red', 'linewidth', 2);
yTickUpperLimit = ecsTheory * 1.1;
axis ([0 maxDt 0 yTickUpperLimit]);
axis ('auto x');
xLabels = cellstr(num2str(dt));
set(gca,'YTick', 0:500:yTickUpperLimit);
set(gca,'YTick', avg);
set(gca,'XTick', dt);
set(gca, 'xticklabel', xLabels);
xlabel ('Time-Deltas');
ylabel ('Average Events');
legend ('Average Events per Time-Deltas', 'Theoretical Maximum');
title ('Sampling occasionally with 5.0 events per time-unit');
