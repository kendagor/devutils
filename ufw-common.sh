ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# imap
ufw allow 143/tcp
ufw allow 993/tcp

# lmtp
ufw allow 24/tcp
ufw allow 1024/tcp

# MySQL

# MySQL service and cluster.
#   - the regular MySQL port (default 3306)
#   - port for group (Galera) communication (default 4567)
#   - port for State Transfer (default 4444)
#   - port for Incremental State Transfer (default is: port for group communication (4567) + 1 = 4568)
#
# Note: Please make sure MySQL service is not binding to localhost with
#       'bind-address=127.0.0.1'.
ufw allow  3306/tcp
ufw allow  4444/tcp
ufw allow  4567/tcp
ufw allow  4568/tcp

# PostgreSQL service.
ufw allow  5432/tcp

# Amavisd
ufw allow  10024/tcp
ufw allow  10025/tcp
ufw allow  10026/tcp
ufw allow  9998/tcp

# iRedAPD
ufw allow  7777/tcp

# ftp.
ufw allow  20/tcp
ufw allow  21/tcp

# ejabberd
ufw allow  5222/tcp
ufw allow  5223/tcp
ufw allow  5280/tcp

# POP3 - Recommending IMAP
# ufw allow 110/tcp
# ufw allow 995/tcp

# SMTP - Recommending IMAP
# ufw allow 587/tcp
