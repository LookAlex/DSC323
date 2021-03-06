*import data;
proc import datafile = "ChicagoUsedCarDataset_1.csv" out = used_cars replace;
delimiter = ',';
getnames = yes;
run;

title "Dummy Variables for Type";
DATA used_cars;
set used_cars;
if (type = 'sedan') then d_type = 1;
else if (type = 'SUV') then d_type = 2;
else if (type = 'suv') then d_type = 2;
else if (type = 'van') then d_type = 3;
else if (type = 'coupe') then d_type = 4;
else if (type = 'truck') then d_type = 5;
else d_type = 0;
run;

title "Dummy Variables for Type";
DATA used_cars;
set used_cars;
if (drive = 'rwd') then d_drive = 1;
else if (drive = 'fwd') then d_drive = 2;
else if (drive = '4wd') then d_drive = 3;
else d_drive = 0;
run;

title "Dummy Variables for Type";
DATA used_cars;
set used_cars;
if (transmission = 'automatic') then d_transmission = 1;
else if (transmission = 'manual') then d_transmission = 2;
else d_transmission = 0;
run;

title "Dummy Variables for Type";
DATA used_cars;
set used_cars;
if (condition = 'excellent') then d_condition = 1;
else if (condition = 'like new') then d_condition = 2;
else if (condition = 'good') then d_condition = 3;
else if (condition = 'fair') then d_condition = 4;
else if (condition = 'salvage') then d_condition = 5;

else d_condition = 0;
run;

title "Dummy Variables for Type";
DATA used_cars;
set used_cars;
if (fuel = 'gas') then d_fuel = 1;
else if (fuel = 'die') then d_fuel = 2;
else if (fuel = 'hyb') then d_fuel = 3;
else if (fuel = 'ele') then d_fuel = 4;

else d_fuel = 0;
run;




*Removing outliers and Influential points;
* Data points 140, 165, 218 for Price;
* Data points 426, 44 for odometer;
data used_cars;
set used_cars;
if _n_ in (140 ,165, 218, 426,  44) then delete;
run;


*Removing outliers and Influential points;
* Data points 576, 581 for Odometer;
* Data points 167 for Price;
data used_cars;
set used_cars;
if _n_ in (576 , 167, 581) then delete;
run;

*Removing outliers and Influential points;
* Data points 274, 273 for odometer;
data used_cars;
set used_cars;
if _n_ in (274, 273) then delete;
run;

*Create Histogram and 5 point summary for Price;
title "Odometer Histogram and 5 Num summary";
proc univariate normal;
var odometer;
histogram / normal (mu=est sigma=est);
run;
proc means min max median q1 q3;
var odometer;
run;

*Log for price variable;
title "Log transformation for Price variable";
data used_cars;
set used_cars;
ln_price=log(price);
run;

*Create Histogram and 5 point summary for Price;
title "ln_Price Histogram";
proc univariate normal;
var ln_price;
histogram / normal (mu=est sigma=est);
run;
proc means min max median q1 q3;
var ln_price;
run;

*Create Histogram and 5 point summary for Mileage;
title "Mileage Histogram";
proc univariate normal;
var odometer;
histogram / normal (mu=est sigma=est);
run;
proc means min max median q1 q3;
var odometer;
run;


*Printing entire Dataset;
title "Printing main Dataset";
proc print data=used_cars;
run;

*ScatterPlots with Dummy Variables;
title "ScatterPlots with Dummy Variables For Price";
proc sgscatter;
title"Scatterplots";
matrix ln_price odometer d_transmission d_drive d_type d_fuel d_condition year cylinders;
run;

*ScatterPlots with Dummy Variables;
title "ScatterPlots with Dummy Variables for Odometer";
proc sgscatter;
title"ScatterPlots with Dummy Variables for Odometer";
matrix  odometer ln_price d_transmission d_drive d_type d_fuel d_condition year cylinders;
run;

*Corr values;
title "Correlation for price";
proc corr;
var ln_price odometer d_transmission d_drive d_type d_fuel d_condition year cylinders;
run;

*Corr values;
title "Correlation for odometer";
proc corr;
var odometer ln_price d_transmission d_drive d_type d_fuel d_condition year cylinders;
run;

*Regression model;
*Found condition to be insignificant;
Title "Regression Model for Price";
proc reg;
model ln_price = odometer d_transmission d_drive d_type d_fuel d_condition year cylinders/ vif influence r tol;
run;

*Regression model;
*Found condition to be insignificant;
Title "Regression Model for Odometer";
proc reg;
model odometer = price d_transmission d_drive d_type d_fuel d_condition year cylinders/ vif influence r tol;
run;

*Hand worked step-by-step removal of significant variables to get rid of d_condition;
Title "Regression Model for Odometer removal of d_fuel";
proc reg;
model odometer = price d_transmission d_drive d_type d_condition year cylinders;
run;

Title "Regression Model for Odometer removal of year";
proc reg;
model odometer = price d_transmission d_drive d_type d_condition cylinders;
run;

Title "Regression Model for Odometer removal of d_tranmission";
proc reg;
model odometer = price d_drive d_type d_condition cylinders;
run;

Title "Regression Model for Odometer removal of d_condition";
proc reg;
model odometer = price d_drive d_type cylinders;
run;

Title "Selection Method for Odometer";
proc reg;
model odometer = price d_transmission d_drive d_type d_fuel d_condition year cylinders/ selection = stepwise;
run;

Title "Selection Method for Price";
proc reg;
model ln_price = odometer d_transmission d_drive d_type d_fuel d_condition year cylinders/ selection = stepwise;
run;

Title "Final Model for price Without insignificant variabels";
proc reg;
model  ln_price = odometer d_transmission d_drive d_type year cylinders/ vif influence r stb;
plot student.*predicted.;
plot npp.*student.;
run;


*Removing outliers and Influential points;
data used_cars;
set used_cars;
if _n_ in (25,35,333,475,570,578) then delete;
run;

Title "Final Model for odometer Without insignificant variabels";
proc reg;
model  odometer = price  d_drive d_type cylinders/ vif influence r stb;
plot student.*predicted.;
plot npp.*student.;
run;


*prediction data;
data used_cars_1;
input price odometer d_transmission d_drive d_type d_fuel d_condition year cylinders ln_price;
datalines;
6500 80000 1 1 1 2 2 2014 8 3.8129 
85000 20 2 2 1 1 1 2021 10 4.92  
;

title "Predicted car values";
proc print;
run;

*Combing generated car values to the dataset;
data prediction;
set used_cars_1 used_cars ;
run;

* prediction for price model;
*Removed d_transmission since it was not significant enough;
title "ln_price Prediction";
proc reg data=prediction;
model ln_price = odometer  d_drive d_type year cylinders / p clm cli;
run;

*regression and CI; 
title "Odometer prediction";
proc reg data=prediction; 
model odometer = price d_drive d_type cylinders / p clm cli; 
run; 
proc print;
run;

**********Training and Testing ********************;

*5 fold testing for price;
title"Training and Testing for Price";
proc glmselect data = used_cars
plots=(asePlot Criteria);
partition fraction(test=0.25);
model ln_price = odometer d_transmission d_drive d_type year cylinders/selection = stepwise(stop=cv)cvMethod=split(5) cvDetails=all;
run;

*5 fold testing for mileage;
title"Training and Testing for Odometer";
proc glmselect data = used_cars
plots=(asePlot Criteria);
partition fraction(test=0.25);
model odometer = price d_transmission d_drive d_type year cylinders/selection = stepwise(stop=cv)cvMethod=split(5) cvDetails=all;
run;

*Train and testing;
title"Training and Testing for Price";
proc surveyselect data=used_cars out=xv_all seed=137287 samprate=0.75 outall;
run;

********Database Creation************;

title "Creating New dataset for Price";
data xv_all;
set xv_all;
if selected then new_y=ln_price;
run;

*printing new dataset;
proc print data = xv_all;
run;

***********Model Selection***********;

title "Model Training for Price Model";
proc reg data = xv_all;
model new_y = odometer d_transmission d_drive d_type d_fuel d_condition year cylinders/ selection = stepwise;
run;

title "Model Selection for Price Model";
proc reg data = xv_all;
model new_y = odometer d_transmission d_drive d_type year cylinders;
output out = outm1(where=(new_y=.)) p=yhat;
run;

*Performance Stats;
title "Final Training for Price Model";
data outm1_sum;
set outm1;
d = ln_price - yhat;
absd=abs(d);
run;


title"Summary For  Price Model Testing";
proc summary data=outm1_sum;
var d absd;
output out=outm1_stats std(d)=rmse mean(absd)=mae;
run;

title "validation stats for Price model";
proc print data = outm1_stats;
run;
title "Correlation stats for Price model";
proc corr data=outm1;
var ln_price yhat;
run;

**************************Train and testing for Odometer Model;*******************************;
title "Validation for Odometer Model";
proc surveyselect data=used_cars out=xv_all2 seed=146486 samprate=0.75 outall;
run;

title "Creating New dataset for Odometer Model";
data xv_all2;
set xv_all2;
if selected then new_y=odometer;
run;
proc print data = xv_all2;
run;

title "Model selection for Odometer Model";
proc reg data = xv_all2;
model new_y = price d_transmission d_drive d_type d_fuel d_condition year cylinders/ selection = stepwise;
run;

title "Validation testing for Odometer Model";
proc reg data = xv_all2;
model new_y = price d_type d_drive cylinders;
output out = outm2(where=(new_y=.)) p=yhat;
run;

**** 
*Performance Stats;
title "Difference between observed and predicted in test for Odometer Model";
data outm2_sum;
set outm2;
d = odometer - yhat;
absd=abs(d);

run;

title "Summary for Odometer Model";
proc summary data=outm2_sum;
var d absd;
output out=outm2_stats std(d)=rmse mean(absd)=mae;
run;

title "validation stats for Odometer model";
proc print data = outm2_stats;
run;

title "Correlation stats for Odometer model";
proc corr data=outm2;
var odometer yhat;
run;
