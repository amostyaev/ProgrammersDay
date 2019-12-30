#!/bin/bash

# функция проверки является ли год (передается в первом параметре) високосным
is_year_leap() {
    local result=$(($1 % 400 == 0 || $1 % 4 == 0 && $1 % 100 != 0))
    echo "$result"
}

# функция получения дня программиста для года (передается в первом параметре)
progday_year() {
    local is_leap=$(is_year_leap $1)
    if [ $is_leap == 1 ]
    then
        progday=(12 09)
    else
        progday=(13 09)
    fi
    local result="$1/${progday[1]}/${progday[0]}"
    echo "$result"
}

# получаем текущую дату в виде строки (год/месяц/день)
now=$(date +"%Y/%m/%d")
#now="2020/01/01"
#echo $now

# получаем текущий год
year_cur=$(date -d "$now" +"%Y")

# получаем дату дня программиста в этом году - 12 или 13 сентября
progday_cur=$(progday_year ${year_cur})
#echo $progday_cur

# проверяем, был ли уже день программиста в этом году, в progday_next записываем дату следующего дня программиста
if [[ "$progday_cur" > "$now" ]] || [ "$progday_cur" = "$now" ];
then
    progday_next=$progday_cur
else
    progday_next=$(progday_year $((${year_cur}+1)))
fi
#echo $progday_next
# из полученной даты получаем необходимые по заданию значения
echo "Следующий день программиста $(date -d "$progday_next" "+%F") ($(date -d "$progday_next" "+%d") число, $(date -d "$progday_next" "+%A"), $(date -d "$progday_next" "+%Y") год)"

# вычисляем разницу между текущим днем и днем программиста в секундах, делим на количество часов, минут и секунд
diff_days=$(( ( $(date -d "$progday_next" "+%s") - $(date -d "$now" "+%s") ) / 24 / 60 / 60))
echo "Дней до него: $diff_days"

line_len=$(tput cols)
year_start=$(date -d "$year_cur/01/01") # начало года
year_end=$(date -d "$year_cur/12/31") # конец года
year_days=$(( ( $(date -d "$year_end" "+%s") - $(date -d "$year_start" "+%s") ) / 24 / 60 / 60)) # дней в этом году (365 или 366)
year_done=$(( ( $(date -d "$now" "+%s") - $(date -d "$year_start" "+%s") ) / 24 / 60 / 60)) # прошло дней в этом году
cell_size=$(( year_days/line_len )) # количество дней в одном символе терминала
done_size=$(( year_done/cell_size )) # количество символов, показывающих прошедшие дни
progday_cell=$(( 256/cell_size )) # номер символа, который приходится на день программиста

# из-за округления при делении, последняя ячейка накапливает в себе всю погрешность
# поэтому включаем в нее все дни между ($line_len - 1) * $cell_size и $line_len * $cell_size
if [[ $done_size -ge $line_len && $year_done -ge $(( ($line_len - 1) * $cell_size )) ]];
then
    done_size=$(($line_len - 1))
fi
if [ $year_done = $year_days ]
then
    done_size=$line_len
fi

echo "Текущий год:"
for (( i = 0; i < $done_size; i++ )) do
    if [[ $i = $progday_cell ]]; 
    then printf "*" 
    else printf "#" 
    fi
done
for (( i = $done_size; i < line_len; i++ )) do
    if [[ $i = $progday_cell ]]; 
    then printf "*" 
    else printf "-" 
    fi
done
