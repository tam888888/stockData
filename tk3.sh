#!/bin/bash

# Kiểm tra xem có đủ đối số truyền vào hay không
if [ $# -lt 1 ]; then
    echo "Sử dụng: $0 <tệp_dữ_liệu> <record display> <interval> <symbols(ABC-DIG-PDR)>"
    exit 1
fi

input_file="$1"
record="$2"
interval="$3"
SYMBOLS="$4"
if [ -z "$record" ]; then
    # Nếu biến chưa được khởi tạo, gán giá trị mặc định là 10
    record=10
fi

if [ -z "$interval" ]; then
    # Nếu biến chưa được khởi tạo, gán giá trị mặc định là 10
    interval=5
fi
if [ -z "$SYMBOLS" ]; then
    # Nếu biến chưa được khởi tạo, gán giá trị mặc định là 10
    SYMBOLS="HPG-SSI-DIG-PDR-DXG-VCI-HSG-NKG-DGW"
fi

# Khởi tạo biến lưu trữ các thông tin theo mã chứng khoán và thời gian
declare -A buy
declare -A sell
declare -A unknown
declare -A buy_value
declare -A sell_value
declare -A unknown_value

# Sử dụng awk để duyệt qua các dòng và tính toán
awk -F"|" -v record="$record" -v interval="$interval" -v MA="$SYMBOLS" 'BEGIN{
    ss="AAA-AAM-AAT-ABR-ABS-ABT-ACB-ACC-ACG-ACL-ADG-ADP-ADS-AGG-AGM-AGR-ANV-APC-APG-APH-ASG-ASM-ASP-AST-BAF-BBC-BCE-BCG-BCM-BFC-BHN-BIC-BID-BKG-BMC-BMI-BMP-BRC-BSI-BTP-BTT-BVH-BWE-C32-C47-CAV-CCI-CCL-CDC-CHP-CIG-CII-CKG-CLC-CLL-CLW-CMG-CMV-CMX-CNG-COM-CRC-CRE-CSM-CSV-CTD-CTF-CTG-CTI-CTR-CTS-CVT-D2D-DAG-DAH-DAT-DBC-DBD-DBT-DC4-DCL-DCM-DGC-DGW-DHA-DHC-DHG-DHM-DIG-DLG-DMC-DPG-DPM-DPR-DQC-DRC-DRH-DRL-DSN-DTA-DTL-DTT-DVP-DXG-DXS-DXV-EIB-ELC-EVE-EVF-EVG-FCM-FCN-FDC-FIR-FIT-FMC-FPT-FRT-FTS-GAS-GDT-GEG-GEX-GIL-GMC-GMD-GMH-GSP-GTA-GVR-HAG-HAH-HAP-HAR-HAS-HAX-HBC-HCD-HCM-HDB-HDC-HDG-HHP-HHS-HHV-HID-HII-HMC-HNG-HPG-HPX-HQC-HRC-HSG-HSL-HT1-HTI-HTL-HTN-HTV-HU1-HUB-HVH-HVN-HVX-IBC-ICT-IDI-IJC-ILB-IMP-ITA-ITC-ITD-JVC-KBC-KDC-KDH-KHG-KHP-KMR-KOS-KPF-KSB-L10-LAF-LBM-LCG-LDG-LEC-LGC-LGL-LHG-LIX-LM8-LPB-LSS-MBB-MCP-MDG-MHC-MIG-MSB-MSH-MSN-MWG-NAF-NAV-NBB-NCT-NHA-NHH-NHT-NKG-NLG-NNC-NO1-NSC-NT2-NTL-NVL-NVT-OCB-OGC-OPC-ORS-PAC-PAN-PC1-PDN-PDR-PET-PGC-PGD-PGI-PGV-PHC-PHR-PIT-PJT-PLP-PLX-PMG-PNC-PNJ-POM-POW-PPC-PSH-PTB-PTC-PTL-PVD-PVP-PVT-QBS-QCG-RAL-RDP-REE-S4A-SAB-SAM-SAV-SBA-SBT-SBV-SC5-SCD-SCR-SCS-SFC-SFG-SFI-SGN-SGR-SGT-SHA-SHB-SHI-SHP-SIP-SJD-SJF-SJS-SKG-SMA-SMB-SMC-SPM-SRC-SRF-SSB-SSC-SSI-ST8-STB-STG-STK-SVC-SVD-SVI-SVT-SZC-SZL-TBC-TCB-TCD-TCH-TCL-TCM-TCO-TCR-TCT-TDC-TDG-TDH-TDM-TDP-TDW-TEG-TGG-THG-TIP-TIX-TLD-TLG-TLH-TMP-TMS-TMT-TN1-TNA-TNC-TNH-TNI-TNT-TPB-TPC-TRA-TRC-TSC-TTA-TTB-TTE-TTF-TV2-TVB-TVS-TVT-TYA-UIC-VAF-VCA-VCB-VCF-VCG-VCI-VDP-VDS-VFG-VGC-VHC-VHM-VIB-VIC-VID-VIP-VIX-VJC-VMD-VND-VNE-VNG-VNL-VNM-VNS-VOS-VPB-VPD-VPG-VPH-VPI-VPS-VRC-VRE-VSC-VSH-VSI-VTB-VTO-YBM-YEG"
    split(ss,aa, "-")
    m["HPG"]="HPG"
    for(a in aa){
        m[aa[a]]=aa[a]
    }
    vn30s="ACB-BCM-BID-BVH-CTG-FPT-GAS-GVR-HDB-HPG-MBB-MSN-MWG-PLX-POW-SAB-SHB-SSB-SSI-STB-TCB-TPB-VCB-VHM-VIB-VIC-VJC-VNM-VPB-VRE"
    split(vn30s,aa, "-")
    for(a in aa){
        m30[aa[a]]=aa[a]
    }
    # print m["AAA"]

    split(MA,aa, "-")
    for(a in aa){
        ma[aa[a]]=aa[a]
    }

    current_time = systime()+ 7 *60*60;  # Lấy thời gian hiện tại dưới dạng Unix timestamp
    midnight_time = mktime(strftime("%Y %m %d 00 00 00", current_time));  # Lấy thời gian bắt đầu của ngày dưới dạng Unix timestamp
    delta = (current_time - midnight_time)/60
    # print delta" "current_time" "midnight_time 
}
{
    l=substr($0,0,2)
    # print substr($0,length($0)+1)
    if(l == "L#" && length($5) == 8 && NR > 1){    
        # print "000" $0  
        symbol = $1
        s2 = substr($1,3)
        symbol=s2
        # print s2
        time = $5
        action = $7
        quantity = $3
        price = $2
        # print symbol" "quantity" "price" "(price*quantity) 
        # print $0

        # Lấy giờ và phút từ thời gian (hh:mm:ss)
        split(time, time_parts, ":")
        hours = time_parts[1]
        minutes = time_parts[2]

        # Chuyển thời gian thành phút
        minutes_since_start = hours * 60 + minutes
        
        # Xác định khung thời gian mỗi 5 phút
        # tt=5
        time_slot = int(minutes_since_start / interval)*interval;
        T="VNINDEX"
        ALL="ALL"
        VN30="VN30"
        if (action == "bu") {
            buy[symbol, time_slot] += quantity
            buy_value[symbol, time_slot] += quantity * price
            # print m[s2]
            if(length(m[s2]) > 0){
                buy[T, time_slot] += quantity
                buy_value[T, time_slot] += quantity * price      
            }  
            if(length(m30[s2]) > 0){
                buy[VN30, time_slot] += quantity
                buy_value[VN30, time_slot] += quantity * price      
            }                
            buy[ALL, time_slot] += quantity
            buy_value[ALL, time_slot] += quantity * price                  
        } else if (action == "sd") {
            sell[symbol, time_slot] += quantity
            sell_value[symbol, time_slot] += quantity * price
            if(length(m[s2]) > 0){
                sell[T, time_slot] += quantity
                sell_value[T, time_slot] += quantity * price
            }
            if(length(m30[s2]) > 0){
                sell[VN30, time_slot] += quantity
                sell_value[VN30, time_slot] += quantity * price
            }            
            sell[ALL, time_slot] += quantity
            sell_value[ALL, time_slot] += quantity * price                          
        } else if (action == "unknown") {
            unknown[symbol, time_slot] += quantity
            unknown_value[symbol, time_slot] += quantity * price
            if(length(m[s2]) > 0){
                unknown[T, time_slot] += quantity
                unknown_value[T, time_slot] += quantity * price
            } 
            if(length(m30[s2]) > 0){
                unknown[VN30, time_slot] += quantity
                unknown_value[VN30, time_slot] += quantity * price
            }                
            unknown[ALL, time_slot] += quantity
            unknown_value[ALL, time_slot] += quantity * price                 
        }
        symbols[symbol] = symbol
        symbols[T] = T
        symbols[ALL] = ALL
        symbols[VN30] = VN30        
        atime[time_slot] = time_slot        
    }
}
END {
    # In tiêu đề
    printf "%-15s%-10s%-20s%-20s%-20s%-15s%-15s%-15s%-20s%-20s%-20s\n", "Thời gian", "Mã CK", "Mua-Ban", "Tổng" ,"TPS","Mua", "Bán", "KoXĐ", "GT Mua", "GT Bán", "GT KoXĐ"

    for(symbol in symbols){    
        sum[symbol,0]=0        
        sum[symbol,1]=0
        sum[symbol,2]=0
    }
    l=length(atime)
    for(symbol in symbols){
        c=0
        for(time_slot in atime){
            mua = buy[symbol, time_slot]
            ban = sell[symbol, time_slot]
            khongxacdinh = unknown[symbol, time_slot]
            giatrimua = buy_value[symbol, time_slot]
            giatriban = sell_value[symbol, time_slot]
            giatrikhongxacdinh = unknown_value[symbol, time_slot]
            x=interval
            if(delta-time_slot>=interval || delta-time_slot < 0) x=interval
            else x=delta-time_slot
            t=giatrimua+giatriban+giatrikhongxacdinh
            if(x==0) x=1
            tps=t/x
            v = delta-time_slot
            # print v    
            c++        
            if(c >= l-record) {
                printf "%02d:%02d-%02d:%02d    %-10s%-20'\''.0f%-20'\''.0f%-20'\''.0f%-15d%-15d%-15d%-20'\''.0f%-20'\''.0f%-20'\''.0f\n", int(time_slot/60), time_slot%60, int((time_slot+interval)/60), (time_slot+interval)%60, symbol, giatrimua-giatriban,t,tps ,mua, ban, khongxacdinh, giatrimua, giatriban, giatrikhongxacdinh
            }                                                   
            sum[symbol,0] += giatrimua-giatriban            
            sum[symbol,1] += giatrimua+giatriban+giatrikhongxacdinh
            sum[symbol,2] += mua
            sum[symbol,3] += ban
            sum[symbol,4] += mua-ban
            sum[symbol,5] += tps
            sum[symbol,6] += 1
            sum[symbol,7] += giatrimua
            sum[symbol,8] += giatriban
        }
    }
    p[1]="VNINDEX"
    p[2]="ALL"
    p[3]="VN30"
    # p[4]="HPG"
    for(s in ma){
        print ma[s]" "length(p)+1
        p[length(p)+1] = ma[s]               
    }
    printf "%-15s%-15s%-20s%-20s%-20s%-20s%-15s%-15s%-15s%-20s\n", "Thời gian", "Mã CK", "GT Mua-Ban", "GT Mua", "GT Bán", "Tổng" ,"Mua", "Bán","Mua-Bán","TPS",
    time=strftime("%H:%M:%S", current_time)
    for(S in p){
        t=p[S]        
        printf "%-15s%-15s%-20'\''.0f%-20'\''.0f%-20'\''.0f%-20'\''.0f%-15'\''.0f%-15'\''.0f%-15'\''.0f%-20'\''.0f\n", time,t,sum[t,0],sum[t,7],sum[t,8],sum[t,1],sum[t,2],sum[t,3],sum[t,4],sum[t,5]/sum[t,6]        
    }
    
    
}' "$input_file"
