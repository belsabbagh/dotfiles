#!/bin/sh
# Network rate for the tmux status bar: "↓14.9M ↑1.2M".
#
# Samples the default-route interface twice, 1s apart, so the number is a real
# rate for any attach/suspend history (a plugin that keeps its own previous
# sample would report bytes-since-last-refresh divided by status-interval).

iface=$(ip route show default | awk '{ print $5; exit }')
[ -n "$iface" ] || exit 0
[ -r "/sys/class/net/$iface/statistics/rx_bytes" ] || exit 0

read_bytes() { cat "/sys/class/net/$iface/statistics/$1"; }

rx=$(read_bytes rx_bytes)
tx=$(read_bytes tx_bytes)
sleep 1

human() {
	awk -v b="$(($(read_bytes "$1") - $2))" 'BEGIN {
		split("B K M G T", u, " ")
		i = 1
		while (b >= 1024 && i < 5) { b /= 1024; i++ }
		if (b < 10 && i > 1) printf "%.1f%s", b, u[i]
		else printf "%.0f%s", b, u[i]
	}'
}

printf '↓%s ↑%s' "$(human rx_bytes "$rx")" "$(human tx_bytes "$tx")"
