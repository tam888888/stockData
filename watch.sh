d=`date +'%Y%m%d'`
echo $d
watch -n 1 './tk3.sh data'$d'".txt" '$1' '$2'|egrep "VNIN|ALL|VN30|gian"'
