# #!/bin/bash

# # Kiểm tra xem có đủ đối số truyền vào hay không
# if [ $# -ne 1 ]; then
#     echo "Sử dụng: $0 <tệp_dữ_liệu>"
#     exit 1
# fi

# input_file="$1"

# # Tạo biến để lưu trữ tổng lượng mua, bán và không xác định
# total_buy=0
# total_sell=0
# total_unknown=0
# total_buy_v=0
# total_sell_v=0
# total_unknown_v=0
# # Sử dụng awk để duyệt qua các dòng và tính toán lượng mua, bán và không xác định
# awk -F"|" -v OFS="\t" '{
#     # print $NF
#     if ($7 == "unknown") {
#         unknown[$1] += $3
#         unknown_v[$1] += $3*($6+$8)
#     } else if ($7 == "sd") {
#         sell[$1] += $3
#         sell_v[$1] += $3*($6+$8)
#     } else if ($7 == "bu") {
#         buy[$1] += $3
#         buy_v[$1] += $3*($6+$8)
#     }
# }
# END {
#     print "Mã Chứng Khoán", "Lượng Mua", "Lượng Bán", "Không Xác Định"
#     for (symbol in buy) {
#         print symbol, buy_v[symbol]- sell_v[symbol],  buy[symbol], sell[symbol], unknown[symbol], buy_v[symbol], sell_v[symbol], unknown_v[symbol]
#     }
#     for (symbol in unknown) {
#         total_unknown += unknown[symbol]
#         total_unknown_v += unknown_v[symbol]
#     }
#     for (symbol in buy) {
#         total_buy += buy[symbol]
#         total_buy_v += buy_v[symbol]
#     }
#     for (symbol in sell) {
#         total_sell += sell[symbol]
#         total_sell_v += sell_v[symbol]
#     }
#     print "Tổng",total_buy_v-total_sell_v,  total_buy, total_sell, total_unknown,total_buy_v, total_sell_v,total_unknown_v
# }' "$input_file"

#!/bin/bash

# Kiểm tra xem có đủ đối số truyền vào hay không
if [ $# -ne 1 ]; then
    echo "Sử dụng: $0 <tệp_dữ_liệu>"
    exit 1
fi

input_file="$1"

# Tạo biến để lưu trữ tổng lượng mua, bán và không xác định
total_buy=0
total_sell=0
total_unknown=0
total_buy_v=0
total_sell_v=0
total_unknown_v=0

# Sử dụng awk để duyệt qua các dòng và tính toán lượng mua, bán và không xác định
awk -F"|" -v OFS="\t" '{
    l=substr($0,0,2)
    if(l == "L#"){
        if ($7 == "unknown") {
            unknown[$1] += $3
            unknown_v[$1] += $3 * ($6 + $8)
        } else if ($7 == "sd") {
            sell[$1] += $3
            sell_v[$1] += $3 * ($6 + $8)
        } else if ($7 == "bu") {
            buy[$1] += $3
            buy_v[$1] += $3 * ($6 + $8)
        }
    }
}
END {
    printf "%-20s%-20s%-20s%-20s%-20s%-20s%-20s%-20s\n", "Mã Chứng Khoán", "Lượng Mua-V", "Lượng Mua", "Lượng Bán", "Không Xác Định", "Lượng Mua-Val", "Lượng Bán-Val", "Không Xác Định-Val"
    for (symbol in buy) {
        printf "%-20s%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f\n", symbol, buy_v[symbol] - sell_v[symbol], buy[symbol], sell[symbol], unknown[symbol], buy_v[symbol], sell_v[symbol], unknown_v[symbol]
    }
    for (symbol in unknown) {
        total_unknown += unknown[symbol]
        total_unknown_v += unknown_v[symbol]
    }
    for (symbol in buy) {
        total_buy += buy[symbol]
        total_buy_v += buy_v[symbol]
    }
    for (symbol in sell) {
        total_sell += sell[symbol]
        total_sell_v += sell_v[symbol]
    }
    printf "%-20s%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f\n", "Total", total_buy_v - total_sell_v, total_buy, total_sell, total_unknown, total_buy_v, total_sell_v, total_unknown_v
}' "$input_file"
