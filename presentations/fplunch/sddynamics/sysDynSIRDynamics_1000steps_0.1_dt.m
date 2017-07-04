steps = 1000;
dt = 0.1;
replications = 0;
dynamics = [
999.000,1.000,0.000;
999.000,1.000,0.000;
999.000,1.000,0.000;
999.000,1.000,0.000;
998.975,1.018,0.007;
998.950,1.037,0.013;
998.925,1.055,0.020;
998.900,1.074,0.027;
998.874,1.093,0.034;
998.847,1.112,0.041;
998.821,1.132,0.048;
998.793,1.152,0.055;
998.766,1.172,0.063;
998.737,1.193,0.070;
998.709,1.214,0.078;
998.679,1.235,0.086;
998.650,1.257,0.094;
998.619,1.279,0.102;
998.588,1.302,0.110;
998.557,1.325,0.118;
998.525,1.348,0.127;
998.493,1.372,0.135;
998.459,1.396,0.144;
998.426,1.421,0.153;
998.392,1.446,0.162;
998.357,1.472,0.172;
998.321,1.498,0.181;
998.285,1.524,0.191;
998.248,1.551,0.201;
998.211,1.578,0.211;
998.173,1.606,0.221;
998.134,1.635,0.231;
998.095,1.663,0.242;
998.055,1.693,0.252;
998.014,1.723,0.263;
997.973,1.753,0.274;
997.930,1.784,0.286;
997.887,1.815,0.297;
997.844,1.848,0.309;
997.799,1.880,0.321;
997.754,1.913,0.333;
997.708,1.947,0.345;
997.661,1.981,0.358;
997.613,2.016,0.370;
997.565,2.052,0.383;
997.515,2.088,0.397;
997.465,2.125,0.410;
997.414,2.163,0.424;
997.362,2.201,0.438;
997.309,2.240,0.452;
997.255,2.279,0.466;
997.200,2.319,0.481;
997.144,2.360,0.496;
997.087,2.402,0.511;
997.029,2.444,0.527;
996.970,2.487,0.542;
996.911,2.531,0.558;
996.850,2.576,0.575;
996.788,2.621,0.591;
996.725,2.667,0.608;
996.660,2.714,0.625;
996.595,2.762,0.643;
996.529,2.811,0.660;
996.461,2.860,0.679;
996.392,2.911,0.697;
996.322,2.962,0.716;
996.251,3.014,0.735;
996.178,3.067,0.754;
996.105,3.121,0.774;
996.030,3.176,0.794;
995.953,3.232,0.814;
995.875,3.289,0.835;
995.796,3.347,0.856;
995.716,3.406,0.878;
995.634,3.466,0.900;
995.551,3.527,0.922;
995.466,3.589,0.945;
995.380,3.652,0.968;
995.292,3.717,0.992;
995.202,3.782,1.015;
995.112,3.849,1.040;
995.019,3.916,1.065;
994.925,3.985,1.090;
994.829,4.055,1.115;
994.732,4.127,1.142;
994.633,4.199,1.168;
994.532,4.273,1.195;
994.429,4.348,1.223;
994.325,4.425,1.251;
994.219,4.502,1.279;
994.110,4.581,1.308;
994.000,4.662,1.338;
993.889,4.744,1.368;
993.775,4.827,1.398;
993.659,4.912,1.429;
993.541,4.998,1.461;
993.421,5.086,1.493;
993.299,5.175,1.526;
993.175,5.266,1.559;
993.049,5.358,1.593;
992.920,5.452,1.628;
992.789,5.548,1.663;
992.656,5.645,1.698;
992.521,5.744,1.735;
992.383,5.845,1.772;
992.243,5.947,1.809;
992.101,6.052,1.848;
991.956,6.158,1.887;
991.808,6.266,1.926;
991.658,6.375,1.967;
991.505,6.487,2.008;
991.350,6.601,2.049;
991.192,6.716,2.092;
991.031,6.834,2.135;
990.867,6.953,2.179;
990.701,7.075,2.224;
990.532,7.199,2.270;
990.359,7.325,2.316;
990.184,7.453,2.363;
990.006,7.583,2.411;
989.825,7.715,2.460;
989.640,7.850,2.510;
989.452,7.987,2.560;
989.262,8.127,2.612;
989.067,8.269,2.664;
988.870,8.413,2.717;
988.669,8.560,2.771;
988.464,8.709,2.826;
988.256,8.861,2.883;
988.045,9.016,2.940;
987.829,9.173,2.998;
987.611,9.333,3.057;
987.388,9.495,3.117;
987.161,9.661,3.178;
986.931,9.829,3.240;
986.696,10.000,3.304;
986.458,10.174,3.368;
986.216,10.351,3.433;
985.969,10.531,3.500;
985.718,10.714,3.568;
985.463,10.900,3.637;
985.203,11.090,3.707;
984.939,11.282,3.779;
984.671,11.478,3.851;
984.397,11.677,3.925;
984.120,11.880,4.000;
983.837,12.086,4.077;
983.550,12.295,4.155;
983.257,12.509,4.234;
982.960,12.725,4.315;
982.658,12.946,4.397;
982.350,13.170,4.480;
982.038,13.398,4.565;
981.720,13.629,4.651;
981.396,13.865,4.739;
981.067,14.105,4.828;
980.733,14.348,4.919;
980.393,14.596,5.011;
980.047,14.848,5.105;
979.695,15.104,5.201;
979.337,15.364,5.298;
978.973,15.629,5.397;
978.603,15.898,5.498;
978.227,16.172,5.601;
977.845,16.450,5.705;
977.456,16.733,5.811;
977.060,17.021,5.919;
976.658,17.314,6.028;
976.249,17.611,6.140;
975.833,17.913,6.253;
975.411,18.221,6.369;
974.981,18.533,6.486;
974.544,18.851,6.606;
974.100,19.173,6.727;
973.648,19.502,6.851;
973.189,19.835,6.976;
972.722,20.174,7.104;
972.247,20.519,7.234;
971.764,20.869,7.366;
971.274,21.225,7.501;
970.775,21.587,7.638;
970.268,21.955,7.777;
969.753,22.329,7.918;
969.229,22.709,8.062;
968.696,23.095,8.208;
968.155,23.488,8.357;
967.605,23.887,8.509;
967.045,24.292,8.663;
966.477,24.704,8.819;
965.899,25.122,8.979;
965.312,25.548,9.140;
964.715,25.980,9.305;
964.108,26.419,9.473;
963.492,26.865,9.643;
962.865,27.319,9.816;
962.228,27.779,9.992;
961.581,28.247,10.171;
960.924,28.723,10.354;
960.255,29.206,10.539;
959.576,29.697,10.727;
958.886,30.195,10.919;
958.185,30.702,11.113;
957.473,31.216,11.311;
956.749,31.739,11.513;
956.013,32.269,11.717;
955.266,32.809,11.925;
954.507,33.356,12.137;
953.736,33.912,12.352;
952.952,34.477,12.571;
952.156,35.051,12.793;
951.348,35.633,13.019;
950.526,36.225,13.249;
949.692,36.825,13.483;
948.844,37.435,13.720;
947.984,38.055,13.962;
947.109,38.683,14.207;
946.221,39.322,14.457;
945.319,39.970,14.711;
944.404,40.628,14.968;
943.473,41.296,15.231;
942.529,41.974,15.497;
941.570,42.663,15.768;
940.595,43.361,16.043;
939.606,44.071,16.323;
938.602,44.790,16.607;
937.583,45.521,16.897;
936.547,46.262,17.190;
935.496,47.015,17.489;
934.429,47.778,17.792;
933.346,48.553,18.101;
932.247,49.339,18.414;
931.130,50.137,18.733;
929.998,50.946,19.056;
928.848,51.767,19.385;
927.681,52.600,19.720;
926.496,53.445,20.059;
925.294,54.302,20.404;
924.074,55.171,20.755;
922.836,56.052,21.111;
921.580,56.947,21.473;
920.306,57.853,21.841;
919.012,58.773,22.215;
917.700,59.705,22.594;
916.369,60.651,22.980;
915.019,61.609,23.372;
913.649,62.581,23.770;
912.260,63.566,24.174;
910.850,64.565,24.585;
909.421,65.577,25.002;
907.971,66.603,25.426;
906.501,67.643,25.857;
905.010,68.696,26.294;
903.498,69.764,26.738;
901.965,70.846,27.189;
900.411,71.942,27.647;
898.835,73.053,28.112;
897.238,74.178,28.584;
895.618,75.318,29.064;
893.977,76.473,29.551;
892.313,77.642,30.045;
890.626,78.826,30.547;
888.917,80.026,31.057;
887.185,81.240,31.575;
885.430,82.470,32.100;
883.652,83.715,32.634;
881.850,84.975,33.175;
880.024,86.251,33.725;
878.175,87.542,34.283;
876.302,88.849,34.850;
874.404,90.171,35.425;
872.482,91.510,36.008;
870.536,92.864,36.601;
868.564,94.234,37.202;
866.568,95.620,37.812;
864.547,97.022,38.431;
862.501,98.440,39.059;
860.430,99.874,39.697;
858.333,101.324,40.343;
856.210,102.790,41.000;
854.062,104.273,41.666;
851.888,105.771,42.341;
849.687,107.286,43.026;
847.461,108.818,43.721;
845.208,110.365,44.427;
842.929,111.929,45.142;
840.624,113.509,45.867;
838.292,115.105,46.603;
835.933,116.718,47.349;
833.548,118.346,48.106;
831.135,119.991,48.873;
828.696,121.652,49.651;
826.230,123.330,50.440;
823.737,125.023,51.240;
821.216,126.732,52.051;
818.669,128.457,52.874;
816.094,130.199,53.707;
813.492,131.956,54.552;
810.863,133.728,55.408;
808.207,135.517,56.276;
805.523,137.321,57.156;
802.812,139.140,58.048;
800.074,140.975,58.951;
797.309,142.825,59.867;
794.516,144.690,60.794;
791.697,146.570,61.734;
788.850,148.464,62.686;
785.976,150.374,63.651;
783.075,152.297,64.628;
780.147,154.236,65.618;
777.192,156.188,66.620;
774.211,158.154,67.635;
771.202,160.134,68.664;
768.168,162.127,69.705;
765.107,164.134,70.759;
762.019,166.154,71.827;
758.906,168.187,72.908;
755.766,170.232,74.002;
752.601,172.290,75.110;
749.410,174.359,76.231;
746.194,176.441,77.366;
742.952,178.534,78.514;
739.685,180.638,79.677;
736.394,182.753,80.853;
733.078,184.879,82.043;
729.737,187.015,83.247;
726.373,189.161,84.466;
722.985,191.317,85.698;
719.573,193.482,86.945;
716.138,195.656,88.206;
712.680,197.839,89.482;
709.199,200.029,90.771;
705.696,202.228,92.076;
702.171,204.434,93.395;
698.625,206.647,94.728;
695.057,208.866,96.077;
691.468,211.092,97.439;
687.859,213.324,98.817;
684.230,215.561,100.209;
680.581,217.803,101.617;
676.912,220.049,103.039;
673.225,222.299,104.476;
669.519,224.553,105.928;
665.795,226.810,107.395;
662.054,229.069,108.877;
658.295,231.331,110.374;
654.520,233.594,111.886;
650.729,235.858,113.413;
646.922,238.123,114.955;
643.099,240.388,116.513;
639.262,242.653,118.085;
635.411,244.916,119.673;
631.546,247.179,121.275;
627.668,249.439,122.893;
623.778,251.697,124.526;
619.875,253.951,126.173;
615.961,256.203,127.836;
612.036,258.450,129.514;
608.101,260.692,131.207;
604.155,262.929,132.915;
600.201,265.161,134.638;
596.238,267.386,136.376;
592.266,269.604,138.129;
588.288,271.815,139.897;
584.302,274.019,141.680;
580.310,276.213,143.477;
576.312,278.399,145.289;
572.310,280.575,147.116;
568.302,282.740,148.957;
564.291,284.896,150.813;
560.277,287.039,152.684;
556.260,289.172,154.569;
552.241,291.291,156.468;
548.220,293.398,158.382;
544.199,295.492,160.309;
540.177,297.571,162.251;
536.156,299.637,164.207;
532.136,301.687,166.177;
528.117,303.722,168.161;
524.101,305.740,170.159;
520.088,307.743,172.170;
516.078,309.728,174.195;
512.072,311.695,176.233;
508.070,313.645,178.285;
504.074,315.576,180.349;
500.084,317.489,182.427;
496.100,319.382,184.518;
492.123,321.255,186.622;
488.154,323.107,188.739;
484.193,324.939,190.868;
480.240,326.750,193.010;
476.297,328.539,195.164;
472.364,330.306,197.330;
468.441,332.051,199.508;
464.529,333.772,201.699;
460.628,335.471,203.901;
456.740,337.146,206.114;
452.864,338.797,208.339;
449.000,340.424,210.576;
445.151,342.026,212.824;
441.315,343.603,215.082;
437.494,345.155,217.352;
433.687,346.681,219.632;
429.896,348.181,221.923;
426.121,349.655,224.224;
422.363,351.103,226.535;
418.621,352.524,228.856;
414.896,353.917,231.187;
411.188,355.284,233.528;
407.499,356.623,235.878;
403.828,357.935,238.237;
400.176,359.218,240.606;
396.543,360.474,242.983;
392.929,361.701,245.370;
389.335,362.900,247.764;
385.762,364.071,250.168;
382.209,365.212,252.579;
378.676,366.325,254.998;
375.165,367.409,257.425;
371.676,368.464,259.860;
368.208,369.490,262.302;
364.762,370.487,264.752;
361.338,371.454,267.208;
357.937,372.392,269.671;
354.558,373.300,272.141;
351.203,374.180,274.618;
347.870,375.029,277.100;
344.561,375.850,279.589;
341.276,376.640,282.083;
338.015,377.402,284.584;
334.777,378.134,287.089;
331.564,378.836,289.600;
328.374,379.509,292.116;
325.210,380.153,294.637;
322.069,380.768,297.163;
318.954,381.353,299.693;
315.863,381.910,302.227;
312.797,382.437,304.766;
309.756,382.936,307.308;
306.741,383.405,309.854;
303.750,383.846,312.404;
300.785,384.259,314.957;
297.844,384.643,317.513;
294.930,384.999,320.072;
292.040,385.327,322.633;
289.176,385.626,325.198;
286.337,385.898,327.764;
283.524,386.143,330.333;
280.736,386.360,332.904;
277.974,386.550,335.477;
275.237,386.712,338.051;
272.525,386.848,340.627;
269.839,386.958,343.204;
267.178,387.040,345.782;
264.542,387.097,348.361;
261.932,387.128,350.940;
259.347,387.133,353.521;
256.787,387.112,356.101;
254.252,387.066,358.682;
251.742,386.995,361.263;
249.256,386.900,363.844;
246.796,386.780,366.424;
244.361,386.635,369.004;
241.950,386.467,371.583;
239.563,386.275,374.162;
237.201,386.059,376.740;
234.864,385.820,379.316;
232.550,385.559,381.891;
230.261,385.274,384.465;
227.995,384.967,387.037;
225.754,384.639,389.607;
223.536,384.288,392.176;
221.342,383.916,394.742;
219.171,383.522,397.307;
217.023,383.108,399.869;
214.899,382.673,402.428;
212.798,382.218,404.985;
210.719,381.742,407.539;
208.663,381.247,410.090;
206.630,380.732,412.638;
204.619,380.198,415.183;
202.630,379.645,417.725;
200.663,379.074,420.263;
198.718,378.484,422.798;
196.795,377.876,425.329;
194.893,377.251,427.856;
193.013,376.608,430.379;
191.154,375.948,432.898;
189.316,375.271,435.413;
187.499,374.577,437.924;
185.702,373.868,440.430;
183.926,373.142,442.932;
182.170,372.401,445.429;
180.434,371.644,447.922;
178.719,370.872,450.409;
177.023,370.085,452.892;
175.346,369.284,455.370;
173.689,368.469,457.842;
172.051,367.639,460.309;
170.433,366.796,462.771;
168.833,365.940,465.228;
167.251,365.070,467.679;
165.688,364.188,470.124;
164.144,363.293,472.563;
162.617,362.385,474.997;
161.109,361.466,477.425;
159.618,360.535,479.847;
158.145,359.592,482.263;
156.689,358.638,484.673;
155.250,357.673,487.076;
153.828,356.698,489.474;
152.424,355.712,491.865;
151.035,354.716,494.249;
149.664,353.709,496.627;
148.308,352.693,498.998;
146.969,351.668,501.363;
145.645,350.633,503.721;
144.338,349.590,506.073;
143.046,348.537,508.417;
141.769,347.477,510.755;
140.507,346.407,513.085;
139.261,345.330,515.409;
138.029,344.245,517.725;
136.813,343.153,520.035;
135.610,342.053,522.337;
134.422,340.946,524.632;
133.249,339.832,526.920;
132.089,338.711,529.200;
130.943,337.584,531.473;
129.811,336.450,533.738;
128.693,335.311,535.996;
127.588,334.165,538.247;
126.496,333.014,540.490;
125.417,331.858,542.725;
124.351,330.696,544.953;
123.298,329.529,547.173;
122.257,328.357,549.386;
121.229,327.180,551.590;
120.214,325.999,553.787;
119.210,324.814,555.976;
118.218,323.624,558.157;
117.239,322.431,560.331;
116.271,321.233,562.496;
115.314,320.032,564.654;
114.369,318.828,566.803;
113.435,317.620,568.945;
112.513,316.409,571.078;
111.601,315.195,573.204;
110.701,313.978,575.321;
109.811,312.759,577.431;
108.931,311.537,579.532;
108.062,310.313,581.625;
107.204,309.086,583.710;
106.355,307.858,585.787;
105.517,306.627,587.856;
104.688,305.395,589.916;
103.870,304.161,591.969;
103.061,302.926,594.013;
102.262,301.689,596.049;
101.472,300.451,598.077;
100.691,299.212,600.096;
99.920,297.972,602.107;
99.158,296.732,604.111;
98.405,295.490,606.105;
97.660,294.248,608.092;
96.925,293.005,610.070;
96.198,291.762,612.040;
95.479,290.519,614.002;
94.770,289.276,615.955;
94.068,288.032,617.900;
93.374,286.789,619.837;
92.689,285.546,621.765;
92.012,284.303,623.685;
91.342,283.060,625.597;
90.681,281.818,627.501;
90.027,280.577,629.396;
89.380,279.336,631.283;
88.741,278.096,633.162;
88.110,276.857,635.033;
87.486,275.619,636.895;
86.869,274.382,638.749;
86.259,273.147,640.595;
85.656,271.912,642.432;
85.060,270.679,644.261;
84.471,269.447,646.082;
83.889,268.216,647.895;
83.313,266.987,649.700;
82.744,265.760,651.496;
82.182,264.534,653.284;
81.626,263.310,655.064;
81.076,262.088,656.836;
80.532,260.868,658.599;
79.995,259.650,660.355;
79.464,258.434,662.102;
78.939,257.220,663.841;
78.419,256.009,665.572;
77.906,254.799,667.295;
77.398,253.592,669.010;
76.896,252.387,670.716;
76.400,251.185,672.415;
75.909,249.985,674.106;
75.424,248.787,675.788;
74.944,247.593,677.463;
74.470,246.400,679.129;
74.001,245.211,680.788;
73.537,244.024,682.439;
73.078,242.840,684.081;
72.625,241.659,685.716;
72.176,240.481,687.343;
71.732,239.306,688.962;
71.294,238.133,690.573;
70.860,236.964,692.176;
70.431,235.798,693.771;
70.006,234.635,695.359;
69.586,233.475,696.939;
69.171,232.318,698.511;
68.761,231.164,700.075;
68.354,230.014,701.632;
67.953,228.867,703.180;
67.555,227.723,704.721;
67.162,226.583,706.255;
66.773,225.446,707.781;
66.389,224.312,709.299;
66.008,223.182,710.809;
65.632,222.056,712.312;
65.260,220.933,713.808;
64.891,219.813,715.296;
64.527,218.697,716.776;
64.167,217.585,718.249;
63.810,216.476,719.714;
63.457,215.371,721.172;
63.108,214.269,722.623;
62.763,213.171,724.066;
62.421,212.077,725.502;
62.083,210.987,726.930;
61.749,209.900,728.351;
61.418,208.817,729.765;
61.090,207.738,731.172;
60.766,206.663,732.571;
60.446,205.591,733.963;
60.128,204.524,735.348;
59.814,203.460,736.726;
59.504,202.400,738.097;
59.196,201.344,739.460;
58.892,200.292,740.816;
58.591,199.243,742.166;
58.293,198.199,743.508;
57.998,197.159,744.843;
57.706,196.122,746.172;
57.417,195.090,747.493;
57.131,194.061,748.807;
56.849,193.037,750.115;
56.568,192.016,751.415;
56.291,191.000,752.709;
56.017,189.987,753.996;
55.745,188.978,755.276;
55.477,187.974,756.549;
55.211,186.973,757.816;
54.947,185.977,759.076;
54.686,184.984,760.329;
54.428,183.996,761.576;
54.173,183.012,762.815;
53.920,182.031,764.049;
53.670,181.055,765.275;
53.422,180.083,766.495;
53.176,179.115,767.709;
52.934,178.151,768.916;
52.693,177.190,770.117;
52.455,176.235,771.311;
52.219,175.283,772.498;
51.986,174.335,773.680;
51.755,173.391,774.854;
51.526,172.451,776.023;
51.299,171.516,777.185;
51.075,170.584,778.341;
50.853,169.656,779.491;
50.633,168.733,780.634;
50.415,167.814,781.771;
50.199,166.898,782.903;
49.986,165.987,784.027;
49.774,165.080,785.146;
49.565,164.176,786.259;
49.357,163.277,787.365;
49.152,162.382,788.466;
48.948,161.491,789.560;
48.747,160.604,790.649;
48.547,159.721,791.732;
48.350,158.842,792.808;
48.154,157.967,793.879;
47.960,157.096,794.944;
47.768,156.229,796.003;
47.578,155.366,797.056;
47.390,154.507,798.103;
47.203,153.652,799.145;
47.018,152.801,800.180;
46.835,151.954,801.210;
46.654,151.111,802.235;
46.474,150.272,803.253;
46.296,149.437,804.266;
46.120,148.606,805.274;
45.946,147.779,806.276;
45.773,146.956,807.272;
45.601,146.136,808.263;
45.432,145.321,809.248;
45.263,144.509,810.227;
45.097,143.702,811.202;
44.932,142.898,812.171;
44.768,142.098,813.134;
44.606,141.302,814.092;
44.446,140.510,815.045;
44.287,139.721,815.992;
44.129,138.937,816.934;
43.973,138.156,817.871;
43.818,137.380,818.802;
43.665,136.607,819.728;
43.513,135.838,820.649;
43.363,135.072,821.565;
43.213,134.311,822.476;
43.066,133.553,823.382;
42.919,132.799,824.282;
42.774,132.048,825.177;
42.630,131.302,826.068;
42.488,130.559,826.953;
42.347,129.820,827.833;
42.207,129.084,828.709;
42.068,128.353,829.579;
41.931,127.625,830.445;
41.794,126.900,831.305;
41.659,126.180,832.161;
41.526,125.463,833.012;
41.393,124.749,833.858;
41.262,124.039,834.699;
41.131,123.333,835.535;
41.002,122.631,836.367;
40.874,121.932,837.194;
40.748,121.236,838.016;
40.622,120.544,838.834;
40.497,119.856,839.647;
40.374,119.171,840.455;
40.251,118.490,841.258;
40.130,117.813,842.057;
40.010,117.138,842.852;
39.890,116.468,843.642;
39.772,115.800,844.427;
39.655,115.137,845.208;
39.539,114.476,845.985;
39.424,113.820,846.757;
39.310,113.166,847.524;
39.196,112.516,848.287;
39.084,111.869,849.046;
38.973,111.226,849.801;
38.863,110.586,850.551;
38.754,109.950,851.297;
38.645,109.317,852.038;
38.538,108.687,852.775;
38.431,108.060,853.508;
38.326,107.437,854.237;
38.221,106.817,854.962;
38.117,106.201,855.682;
38.014,105.588,856.398;
37.912,104.977,857.110;
37.811,104.371,857.818;
37.710,103.767,858.522;
37.611,103.167,859.222;
37.512,102.570,859.918;
37.414,101.976,860.610;
37.317,101.385,861.298;
37.221,100.797,861.981;
37.126,100.213,862.661;
37.031,99.632,863.337;
36.938,99.053,864.009;
36.845,98.478,864.677;
36.752,97.906,865.341;
36.661,97.337,866.002;
36.570,96.772,866.658;
36.480,96.209,867.311;
36.391,95.649,867.960;
36.302,95.092,868.605;
36.215,94.539,869.246;
36.128,93.988,869.884;
36.041,93.441,870.518;
35.956,92.896,871.148;
35.871,92.354,871.775;
35.787,91.815,872.398;
35.703,91.280,873.017;
35.620,90.747,873.633;
35.538,90.217,874.245;
35.457,89.690,874.853;
35.376,89.166,875.458;
35.296,88.644,876.060;
35.216,88.126,876.658;
35.137,87.610,877.252;
35.059,87.098,877.843;
34.982,86.588,878.431;
34.905,86.080,879.015;
34.828,85.576,879.595;
34.753,85.075,880.173;
34.678,84.576,880.747;
34.603,84.080,881.317;
34.529,83.587,881.884;
34.456,83.096,882.448;
34.383,82.608,883.009;
34.311,82.123,883.566;
34.239,81.641,884.120;
34.168,81.161,884.671;
34.098,80.684,885.218;
34.028,80.210,885.762;
33.959,79.738,886.303;
33.890,79.269,886.841;
33.822,78.802,887.376;
33.754,78.338,887.908;
33.687,77.877,888.436;
33.620,77.418,888.961;
33.554,76.962,889.484;
33.488,76.509,890.003;
33.423,76.058,890.519;
33.359,75.609,891.032;
33.295,75.163,891.542;
33.231,74.720,892.049;
33.168,74.279,892.553;
33.106,73.840,893.054;
33.044,73.404,893.552;
32.982,72.970,894.048;
32.921,72.539,894.540;
32.860,72.111,895.029;
32.800,71.684,895.516;
32.740,71.260,895.999;
32.681,70.839,896.480;
32.622,70.420,896.958;
32.564,70.003,897.433;
32.506,69.589,897.905;
32.449,69.177,898.375;
32.392,68.767,898.841;
32.335,68.360,899.305;
32.279,67.954,899.767;
32.223,67.552,900.225;
32.168,67.151,900.681;
32.113,66.753,901.134;
32.059,66.357,901.584;
32.005,65.963,902.032;
31.951,65.572,902.477;
31.898,65.183,902.919;
31.845,64.796,903.359;
31.793,64.411,903.796;
31.741,64.028,904.231;
31.689,63.648,904.663;
31.638,63.270,905.092;
31.587,62.894,905.519;
31.537,62.520,905.943;
31.487,62.148,906.365;
31.437,61.779,906.784;
31.388,61.411,907.201;
31.339,61.046,907.615;
31.290,60.682,908.027;
31.242,60.321,908.437;
31.194,59.962,908.844;
31.147,59.605,909.248;
31.100,59.250,909.650;
31.053,58.897,910.050;
31.007,58.546,910.447;
30.961,58.197,910.842;
30.915,57.850,911.235;
30.869,57.505,911.625;
30.824,57.162,912.013;
30.780,56.821,912.399;
30.735,56.482,912.782;
30.691,56.145,913.163;
30.648,55.810,913.542;
30.604,55.477,913.919;
30.561,55.146,914.293;
30.518,54.816,914.665;
30.476,54.489,915.035;
30.434,54.164,915.403;
30.392,53.840,915.768;
30.350,53.518,916.131;
30.309,53.198,916.492;
30.268,52.880,916.851;
30.228,52.564,917.208;
30.187,52.250,917.563;
30.147,51.937,917.915;
30.108,51.627,918.266;
30.068,51.318,918.614;
30.029,51.011,918.960;
29.990,50.705,919.305;
29.952,50.402,919.647;
29.913,50.100,919.987;
29.875,49.800,920.325;
29.838,49.502,920.661;
29.800,49.205,920.995;
29.763,48.910,921.327;
29.726,48.617,921.657;
29.689,48.326,921.985;
29.653,48.036,922.311;
29.617,47.748,922.635;
29.581,47.462,922.957;
29.545,47.177,923.277;
29.510,46.894,923.596;
29.475,46.613,923.912;
29.440,46.333,924.227;
29.405,46.055,924.539;
29.371,45.779,924.850;
29.337,45.504,925.159;
29.303,45.231,925.466;
29.269,44.959,925.771;
29.236,44.689,926.075;
29.203,44.421,926.376;
29.170,44.154,926.676;
29.137,43.889,926.974;
29.105,43.625,927.270;
29.073,43.363,927.564;
29.041,43.102,927.857;
29.009,42.843,928.148;
28.978,42.586,928.437;
28.946,42.330,928.724;
28.915,42.075,929.010;
28.884,41.822,929.294;
28.854,41.570,929.576;
28.823,41.320,929.856;
28.793,41.072,930.135;
28.763,40.825,930.412;
28.733,40.579,930.688;
28.704,40.335,930.962;
28.674,40.092,931.234;
28.645,39.850,931.504;
28.616,39.611,931.773;
28.588,39.372,932.040;
28.559,39.135,932.306;
28.531,38.899,932.570;
28.503,38.665,932.833;
28.475,38.432,933.094;
28.447,38.200,933.353;
28.419,37.970,933.611;
28.392,37.741,933.867;
28.365,37.514,934.122;
28.338,37.288,934.375;
28.311,37.063,934.626;
28.284,36.839,934.876;
28.258,36.617,935.125;
28.232,36.396,935.372;
28.206,36.177,935.618;
28.180,35.958,935.862;
28.154,35.741,936.104;
28.129,35.526,936.346;
28.103,35.311,936.585;
28.078,35.098,936.824;
28.053,34.886,937.060;
28.028,34.676,937.296;
28.004,34.466,937.530;
27.979,34.258,937.762;
27.955,34.051,937.994;
27.931,33.846,938.223;
27.907,33.641,938.452;
27.883,33.438,938.679;
27.859,33.236,938.904;
27.836,33.035,939.129;
27.813,32.836,939.352;
27.790,32.637,939.573;
27.767,32.440,939.793;
27.744,32.244,940.012;
27.721,32.049,940.230;
27.699,31.855,940.446;
27.676,31.663,940.661;
27.654,31.471,940.875;
27.632,31.281,941.087;
27.610,31.092,941.298;
27.588,30.904,941.508;
27.567,30.717,941.717;
27.545,30.531,941.924;
27.524,30.346,942.130;
27.503,30.163,942.335;
27.482,29.980,942.538;
27.461,29.799,942.740;
27.440,29.618,942.942;
27.419,29.439,943.141;
27.399,29.261,943.340;
27.379,29.084,943.538;
27.358,28.908,943.734;
27.338,28.733,943.929;
27.319,28.559,944.123;
27.299,28.386,944.316;
27.279,28.214,944.507;
27.260,28.043,944.697;
27.240,27.873,944.887;
27.221,27.704,945.075;
27.202,27.536,945.262;
27.183,27.370,945.448;
27.164,27.204,945.632;
27.145,27.039,945.816;
27.127,26.875,945.998;
27.108,26.712,946.180;
27.090,26.550,946.360;
27.072,26.389,946.539;
27.054,26.229,946.717;
27.036,26.070,946.894;
27.018,25.912,947.070;
27.000,25.755,947.245;
26.982,25.599,947.419;
26.965,25.444,947.591;
26.947,25.289,947.763;
26.930,25.136,947.934;
26.913,24.983,948.103;
26.896,24.832,948.272;
];
susceptibleRatio = dynamics (:, 1);
infectedRatio = dynamics (:, 2);
recoveredRatio = dynamics (:, 3);
figure
plot (susceptibleRatio.', 'color', 'green');
hold on
plot (infectedRatio.', 'color', 'red');
hold on
plot (recoveredRatio.', 'color', 'blue');
xlabel ('Steps');
ylabel ('Population');
legend('Susceptible','Infected', 'Recovered');
title ('SIR Dynamics with 0.1 dt, 1000 steps');
