#!/usr/bin/gnuplot

set output "test.png"
set title "Promises not kept"
set xlabel "Date"
set ylabel "Count"
set rmargin 7

set border linewidth 2
set style line 1 linecolor rgb 'red'   linetype 1 linewidth 2
set style line 2 linecolor rgb 'green' linetype 1 linewidth 2
set style fill solid

set xdata time
set timefmt "%Y-%m-%d"
set format x "%Y-%m-%d"
set grid front
set grid
set autoscale

# 1e8 reduces the epoch seconds for a less flat line.
p(x) = m1 * x/1e8 +b1
fit p(x) 'test.dat' using 1:2 via m1,b1
h(x) = m2 * x/1e8 +b2
fit h(x) 'test.dat' using 1:3 via m2,b2

set terminal png enhanced size 1024,768
plot 'test.dat' using 1:2 notitle with boxes lc rgb "blue", \
p(x) title 'Promise Trend' with lines linestyle 1, \
h(x) title 'Host Trend' with lines linestyle 2

