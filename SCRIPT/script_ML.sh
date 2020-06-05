#!/bin/bash

#####################################################################
# Script     :                                                      #
# Funcion    : 							    #
# Autor      : Chiavasco Gaston                                     #
# Date       :                                                      #
#                                                                   #
# Changes control:                                                  #
# 	   DATE        VER DESCRIPTION                              #
# -------  ----------- --- ---------------------------------------- #
# 	                                                            #
#####################################################################


clear


##### validacion archivo

test ! -s sellers.txt
flag=`echo $?`

if [ $flag -eq 0 ]
then
    echo  "fecha: $(date "+%Y%m%d") \nno se cargo el archivo..  \n\n"           
    exit
else
    echo  "fecha: $(date "+%Y%m%d") \ngenerando archivo de datos.. \n\n"           
fi   



##### generacion de archivo LOG #####

for i in `cat sellers.txt`
do
	seller_id=`echo $i`	


curl -o 2>>curlLog.t -X GET "https://api.mercadolibre.com/sites/MLA/search?seller_id=$seller_id" | sed -e 's/{/''/g' | sed -e 's/\"results\":\[/''/g' | awk '{ n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | awk '{if ($0~/category_id/ || $0~/\"id\":\"MLA........./ || $0~/\"title\"/) print $0}' | awk '{ if (FNR%3==0) { printf $0 
print""} 
else printf $0}' | sed -e 's/\"/''/g' | sed -e 's/title/''/g' | sed -e 's/category_id/''/g' | awk -F: -v var1="Id" -v var2="Title" -v var3="CategoryId" -v var4="--------" 'BEGIN{printf "%-14s %-15s %s\n",var1,var3,var2
printf "%-14s %-15s %s\n",var4,var4,var4} {printf "%-14s %-15s %s\n",$2,$4,$3}'  > log_$seller_id.t

# recupero id de las categorias para buscar los nombres

awk '{if( FNR!=1 && FNR!=2) print $2}' log_$seller_id.t > temp.t     

# recupero nombre de las categorias

for i in `cat temp.t`			
do
	category_id=`echo $i`

curl -o 2>>curlLog.t -X GET "https://api.mercadolibre.com/categories/$category_id" | sed -e 's/{/''/g' | awk '{ n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | awk '{if ($0~/name/ || $0~/date_created/) print $0}' | awk '{if ($0~/name/) printf $0
else print""}' | awk -F'"' '{print $4}'  >> temp2_$seller_id.t 
	

done

# Incorporo los nombres de las categorias al archivo de log

vector=`awk  '{vec[FNR]= $0} END{for (x=1; x<=FNR; x++) {printf vec[x]; printf ":"} }' temp2_$seller_id.t`

awk -v vec=$vector -v var1="Id" -v var2="Title" -v var3="CategoryId" -v var4="--------" -v var5="Category" 'BEGIN {n=split(vec,a,":");printf "%-14s %-15s %-119s %s\n",var1,var3,var2,var5; printf "%-14s %-15s %-119s %s\n",var4,var4,var4,var4} {if( FNR!=1 && FNR!=2) printf "%-150s %s\n",$0,a[FNR-2] }' log_$seller_id.t > LOG_$seller_id.t


done


rm -f temp* log_*
      

        



