# Updating DNS Configuration After IPv6 Prefix Changes

This document provides a clear, technically complete workflow for updating BIND9 DNS configuration when your IPv6 delegated prefix changes. It expands on the basic hints and includes best practices for zone hygiene, serial management, and safe reload/notify sequencing across primary and secondary servers.

---

## 1. Update ACLs and Options for the New Delegated Prefix
Modify your primary server’s `named.conf.options` (or equivalent) so that any ACLs referencing your IPv6 prefix include the newly delegated range.

Example:
acl "internal-v6" {
    2001:db8:abcd:1234::/56;  // update to new prefix
};

After editing, validate syntax:
```sh
named-checkconf
```

---

## 2. Update `home.lan` Forward Zone
Update all AAAA records that depend on the old prefix. Also increment the SOA serial.

Example SOA bump:
@   IN  SOA ns1.home.lan. admin.home.lan. (
        2026051701 ; serial – increment
        3600        ; refresh
        900         ; retry
        604800      ; expire
        86400 )     ; minimum

Validate the zone:
```sh
named-checkzone home.lan /etc/bind/zones/home.lan
```

---

## 3. Update `ipv6.home.lan.rev` Reverse Zone
Update PTR entries to reflect the new IPv6 prefix and increment the SOA serial.

Validate the reverse zone:
```sh
named-checkzone ipv6.home.lan.rev /etc/bind/zones/ipv6.home.lan.rev
```

---

## 4. Update `named.conf.local` on Primary
Ensure the `also-notify` IPv6 address points to the correct secondary server.

Example:
also-notify { 2001:db8:abcd:1234::2; };  // update to new secondary IPv6

Validate configuration:
```sh
named-checkconf
```

---

## 5. Reload Primary DNS
Apply all changes on the primary:
```sh
sudo rndc reload
```

Check logs for errors:
```sh
sudo journalctl -u bind9 -n 50
```

---

## 6. Update Secondary Server
On the secondary:
- Update `named.conf.local` so the `masters { ... }` block references the primary’s new IPv6 address.
- Reload configuration:
```sh
sudo rndc reload
```

---

## 7. Trigger Notify from Primary
Force the primary to notify the secondary of zone changes:
```sh
sudo rndc notify home.lan
```

Confirm notify events in logs.

---

## 8. Refresh Secondary
On the secondary, explicitly request a refresh:
```sh
sudo rndc refresh
```

Check that the new serial is pulled:
```sh
sudo rndc zonestatus home.lan
```

---

## Recommended Additional Safety Checks
- Confirm both servers now serve the same SOA serial.
- Use `dig` to verify forward and reverse resolution:
```sh
dig AAAA host.home.lan @primary
dig -x 2001:db8:abcd:1234::50 @secondary
```
- Ensure firewall rules allow DNS/IPv6 traffic between primary and secondary.

---

This checklist ensures a clean, consistent update cycle whenever your IPv6 delegated prefix changes, minimizing stale records and synchronization issues across your DNS infrastructure.
