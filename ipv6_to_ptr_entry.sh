#!/bin/bash

# Ensure two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <IPv6_Address> <Hostname>" >&2
    echo "Example: $0 2611:2050:4b03:1314:2e87:d035:4169:e554 ep36" >&2
    exit 1
fi

IPV6_INPUT="$1"
HOSTNAME_INPUT="$2"

# Validate and reverse the IPv6 address using Python's standard network library
PTR_REVERSED=$(python3 -c '
import sys
import ipaddress
try:
    # This natively handles compression (::) and checks syntax validity
    ip = ipaddress.IPv6Address(sys.argv[1])
    # reverse_pointer generates the nibble format ending in ip6.arpa
    print(f"{ip.reverse_pointer}.")
except ValueError:
    sys.exit(1)
' "$IPV6_INPUT" 2>/dev/null)

# Verify if the syntax check passed
if [ $? -ne 0 ] || [ -z "$PTR_REVERSED" ]; then
    echo "Error: '$IPV6_INPUT' is not a valid IPv6 address." >&2
    exit 2
fi

# Print the final BIND-compliant zone record
echo "${PTR_REVERSED} IN PTR ${HOSTNAME_INPUT}.home.lan."
