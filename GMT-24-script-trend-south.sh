#!/bin/bash
# Purpose: Regression trend1d mixed models
# GMT modules: gmtset, gmtdefaults, trend1d, psxy, pstext, logo, psconvert
# Unix progs:   echo, rm
#
# Step-1. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.8c \
    MAP_ANNOT_OFFSET=0.2c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
#    MAP_GRID_PEN_PRIMARY=thin,dimgray \
#    MAP_GRID_PEN_SECONDARY=thinnest,dimgray
    MAP_DEFAULT_PEN thin dimgray \
    FONT_TITLE=11p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=8p,Palatino-Roman,dimgray \
    FONT_LABEL=9p,Palatino-Roman,dimgray \
# Step-2. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-3. Generate file
ps=KKTtrends_S.ps
# Step-4. Basic LS line y = a + bx
gmt trend1d -Fxm stack1.txt -Np1 > model.txt
gmt psxy -R-200/200/-10000/0 -JX15c/4c -P -Bpxag100f10 -Bsxg50 -Byaf+u"m" -Bsyg2000 \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    -BWSne+gazure1 -Sc0.05c -Gred stack1.txt -X5.0c -K > $ps
gmt psxy -R -J -W0.5p,blue model.txt \
    -UBL/-15p/-45p -O -K >> $ps
echo "m@-2@-(t) = a + b\267t" | gmt pstext -R -J -F+f12p+cBL -Dj0.1i -Glightyellow -O -K >> $ps
# Step-5. Basic LS line y = a + bx + cx^2
gmt trend1d -Fxm stack1.txt -Np2 > model.txt
gmt psxy -R -J -Bpxag100f10 -Bsxg50 -Bpyaf+u"m" -Bsyg2000 \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    -BWSne+gazure1 -Sc0.05c -Gred stack1.txt -Y5.0c -O -K >> $ps
gmt psxy -R -J -W0.5p,blue model.txt -O -K >> $ps
echo "m@-3@-(t) = a + b\267 t + c\267t@+2@+" | gmt pstext -R -J \
    -F+f12p+cBL -Dj0.1i -Glightyellow -O -K >> $ps
# Step-6. Basic LS line y = a + bx + cx^2 + spatial change
gmt trend1d -Fxmr stack1.txt -Np2,f1+l1 > model.txt
gmt psxy -R -J -Bpxag100f10 -Bsxg50 -Bpyaf+u"m" -Bsyg2000 \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    -BWSne+gazure1 -Sc0.05c -Gred stack1.txt -Y5.0c -O -K >> $ps
gmt psxy -R -J -W0.25p,blue model.txt -O -K >> $ps
echo "m@-5@-(t) = a + b\267t + c\267t@+2@+ + d\267cos(2@~p@~t) + e\267sin(2@~p@~t)" | gmt pstext -R -J \
    -F+f12p+cTL -Dj0.1i -Glightyellow -O -K >> $ps
# Step-7. Plot residuals of last model
gmt psxy -R-200/200/-3000/3000 -J -Bpxag100f10 -Bsxg50 -Bpyaf+u"m" -Bsyg1000 \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    -BWSne+gazure1 -W0.1 -Sc0.05c \
    -Gred model.txt -i0,2 -Y5.0c -O -K >> $ps
echo "@~e@~(t) = y(t) - m@-5@-(t) (plot of the residuals)" | gmt pstext -R -J \
    -F+f12p+cTL -Dj0.1i -Glightyellow -O -K >> $ps
# Step-8. Plot graph
gmt psxy -R-200/200/-10000/100 -JX15c/4c \
    -Bpxag100f10+l"Distance from trench (km)" -Bsxg50 -Bpyagf+l"Depth (m)" -Bsyg2000 \
    --FONT_ANNOT_PRIMARY=8p,Palatino-Roman,dimgray \
    --FONT_LABEL=8p,Palatino-Roman,dimgray \
    --MAP_GRID_PEN_PRIMARY=thinnest,dimgray \
    --MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    -BWSne+t"Graph of the modelled trend curves of the Kuril-Kamchatka Trench geomorphology (south)" \
    -Glightgray env1.txt -Y5.0c -O -K >> $ps
gmt psxy -R -J -W1p -Ey stack1.txt -O -K >> $ps
gmt psxy -R -J -W1p,red stack1.txt \
    -O -K >> $ps
# Step-9. Add test annotations
echo "-150 -7000 Pacific Plate" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
echo "-100 -300 Median stacked profile with error bars" | gmt pstext -R -J -Gwhite -F+jTC+f10p,red -O -K >> $ps
echo "0 -9000 Kuril-Kamchatka Trench" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps
echo "150 -3000 Greater Kuril Chain" | gmt pstext -R -J -Gwhite -F+jTC+f9p -O -K >> $ps

# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX15c/4c -X0.0c -Y0.5c -N -O -K \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.0 15.0 Fitted regression models y=f(x)+e, by weighted least squares (WLS), polynomial and Fourier
EOF
# Step-11. Add GMT logo
gmt logo -Dx6.2/-21.0+o0.25c/-1.3c+w2c -O >> $ps
# Step-12. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert KKTtrends_S.ps -A0.2c -E720 -Tj -P -Z
# Step-13. Clean up
rm -f model.txt
