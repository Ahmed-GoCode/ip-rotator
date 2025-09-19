#!/bin/bash

IFACE=$1
ACTION=$2
IP_FILE="/tmp/orig_ip_$IFACE.txt"

get_ip() { ip addr show dev $IFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1; }
get_gw() { ip route show default dev $IFACE 2>/dev/null | awk '{print $3}'; }
get_mask() { ip addr show dev $IFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+' | head -n1 | cut -d'/' -f2; }

save_orig() {
    OIP=$(get_ip)
    [ -z "$OIP" ] && echo "No IP on $IFACE" && exit 1
    OG=$(get_gw)
    OM=$(get_mask)
    echo "$OIP $OM $OG" > "$IP_FILE"
    echo "Saved: IP=$OIP Mask=$OM GW=$OG"
}

restore_orig() {
    [ -f "$IP_FILE" ] || { echo "No saved config"; return; }
    read OIP OM OG < "$IP_FILE"
    sudo ip addr flush dev $IFACE
    sudo ip addr add $OIP/$OM dev $IFACE
    [ -n "$OG" ] && sudo ip route add default via $OG dev $IFACE
    echo "Restored: IP=$OIP Mask=$OM GW=$OG"
    rm -f "$IP_FILE"
}

rand_ip() {
    case $((RANDOM % 3)) in
        0) echo "10.$((RANDOM % 254)).$((RANDOM % 254)).$((RANDOM % 253 + 1))" ;;
        1) echo "172.$((RANDOM % 16 + 16)).$((RANDOM % 254)).$((RANDOM % 253 + 1))" ;;
        2) echo "192.168.$((RANDOM % 254)).$((RANDOM % 253 + 1))" ;;
    esac
}

change_ip() {
    NIP=$(rand_ip)
    MASK="24"
    GW="${NIP%.*}.1"
    
    echo "Changing to: $NIP/$MASK GW:$GW"
    
    sudo ip link set $IFACE down
    sudo ip addr flush dev $IFACE
    sudo ip addr add $NIP/$MASK dev $IFACE
    sudo ip route add default via $GW dev $IFACE
    sudo ip link set $IFACE up
    
    VIP=$(get_ip)
    [ "$VIP" = "$NIP" ] && echo "OK: $VIP" || echo "FAIL: got $VIP, wanted $NIP"
}

start_rot() {
    save_orig
    trap restore_orig EXIT INT TERM
    echo "Rotating IP every 5s on $IFACE (Ctrl+C to stop)"
    while true; do
        change_ip
        sleep 5
    done
}

[ $# -lt 2 ] && echo "Usage: $0 <interface> <start|stop>" && exit 1
ip link show $IFACE > /dev/null 2>&1 || { echo "Interface $IFACE not found!"; exit 1; }

case $ACTION in
    start)
        [ -f "$IP_FILE" ] && { echo "Already running on $IFACE"; exit 1; }
        start_rot
        ;;
    stop)
        restore_orig
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Usage: $0 <interface> <start|stop>"
        exit 1
        ;;
esac