FROM ubuntu:20.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install OpenSSH server
RUN apt-get update && apt-get install -y \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/run/sshd /home/sftpuser/upload
RUN chmod 755 /home/sftpuser

# Create SFTP user group and user
RUN groupadd sftpgroup && \
    useradd -g sftpgroup -d /home/sftpuser -s /bin/false sftpuser && \
    chown root:root /home/sftpuser && \
    chown sftpuser:sftpgroup /home/sftpuser/upload

# Configure SSH for SFTP only
RUN echo "Port 80" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config && \
    echo "Match Group sftpgroup" >> /etc/ssh/sshd_config && \
    echo "    ChrootDirectory /home/sftpuser" >> /etc/ssh/sshd_config && \
    echo "    ForceCommand internal-sftp" >> /etc/ssh/sshd_config && \
    echo "    AllowTcpForwarding no" >> /etc/ssh/sshd_config && \
    echo "    X11Forwarding no" >> /etc/ssh/sshd_config

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'echo "sftpuser:${SFTP_PASSWORD}" | chpasswd' >> /start.sh && \
    echo 'exec /usr/sbin/sshd -D' >> /start.sh && \
    chmod +x /start.sh

# Expose port 80
EXPOSE 80

# Start SSH server
CMD ["/start.sh"]
