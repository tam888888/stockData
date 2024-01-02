#!/bin/bash

# Kiểm tra xem có đủ đối số truyền vào hay không
if [ $# -ne 1 ]; then
    echo "Sử dụng: $0 <tệp_dữ_liệu>"
    exit 1
fi

input_file="$1"

# Khởi tạo biến lưu trữ các thông tin theo mã chứng khoán và thời gian
declare -A buy
declare -A sell
declare -A unknown
declare -A buy_value
declare -A sell_value
declare -A unknown_value

# Sử dụng awk để duyệt qua các dòng và tính toán
awk -F"|" '
{
    l=substr($0,0,2)
    # print substr($0,length($0)+1)
    if(l == "L#" && length($5) == 8 && NR > 1){    
        # print "000" $0  
        symbol = $1
        time = $5
        action = $7
        quantity = $3
        price = $2

        # Lấy giờ và phút từ thời gian (hh:mm:ss)
        split(time, time_parts, ":")
        hours = time_parts[1]
        minutes = time_parts[2]

        # Chuyển thời gian thành phút
        minutes_since_start = hours * 60 + minutes
        
        # Xác định khung thời gian mỗi 5 phút
        time_slot = int(minutes_since_start / 5)*5;
        T="VNINDEX"
        if (action == "bu") {
            buy[symbol, time_slot] += quantity
            buy_value[symbol, time_slot] += quantity * price
            buy[T, time_slot] += quantity
            buy_value[T, time_slot] += quantity * price            
        } else if (action == "sd") {
            sell[symbol, time_slot] += quantity
            sell_value[symbol, time_slot] += quantity * price
            sell[T, time_slot] += quantity
            sell_value[T, time_slot] += quantity * price            
        } else if (action == "unknown") {
            unknown[symbol, time_slot] += quantity
            unknown_value[symbol, time_slot] += quantity * price
            unknown[T, time_slot] += quantity
            unknown_value[T, time_slot] += quantity * price            
        }
        symbols[symbol] = symbol
        symbols[T] = T
        atime[time_slot] = time_slot        
    }
}
END {
    # In tiêu đề
    printf "%-15s%-15s%-20s%-20s%-15s%-15s%-15s%-15s%-15s%-15s\n", "Thời gian", "Mã Chứng Khoán", "Mua-Ban", "Tổng" ,"Mua", "Bán", "Không Xác Định", "Giá Trị Mua", "Giá Trị Bán", "Giá Trị Không Xác Định"


    for(symbol in symbols){
        for(time_slot in atime){
            mua = buy[symbol, time_slot]
            ban = sell[symbol, time_slot]
            khongxacdinh = unknown[symbol, time_slot]
            giatrimua = buy_value[symbol, time_slot]
            giatriban = sell_value[symbol, time_slot]
            giatrikhongxacdinh = unknown_value[symbol, time_slot]
            printf "%02d:%02d-%02d:%02d%-20s%-20'\''.f%-20'\''.0f%-15d%-15d%-15d%-15d%-15d%-15d\n", int(time_slot/60), time_slot%60, int((time_slot+5)/60), (time_slot+5)%60, symbol, giatrimua-giatriban,giatrimua+giatriban+giatrikhongxacdinh ,mua, ban, khongxacdinh, giatrimua, giatriban, giatrikhongxacdinh
        }
    }
    printf "%-15s%-15s%-20s%-20s%-15s%-15s%-15s%-15s%-15s%-15s\n", "Thời gian", "Mã Chứng Khoán", "Mua-Ban", "Tổng" ,"Mua", "Bán", "Không Xác Định", "Giá Trị Mua", "Giá Trị Bán", "Giá Trị Không Xác Định"
}' "$input_file"
