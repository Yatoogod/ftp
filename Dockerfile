FROM ubuntu:20.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install vsftpd and basic utilities
RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

# Create FTP user directories
RUN useradd -m ftpuser && \
    mkdir -p /home/ftpuser/ftp && \
    chown ftpuser:ftpuser /home/ftpuser/ftp

# Configure vsftpd to use port 80
RUN echo "listen=YES" >> /etc/vsftpd.conf && \
    echo "listen_ipv6=NO" >> /etc/vsftpd.conf && \
    echo "anonymous_enable=NO" >> /etc/vsftpd.conf && \
    echo "local_enable=YES" >> /etc/vsftpd.conf && \
    echo "write_enable=YES" >> /etc/vsftpd.conf && \
    echo "local_umask=022" >> /etc/vsftpd.conf && \
    echo "chroot_local_user=YES" >> /etc/vsftpd.conf && \
    echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf && \
    echo "listen_port=80" >> /etc/vsftpd.conf && \
    echo "ftp_data_port=80" >> /etc/vsftpd.conf && \
    echo "pasv_enable=NO" >> /etc/vsftpd.conf && \
    echo "userlist_enable=YES" >> /etc/vsftpd.conf && \
    echo "userlist_file=/etc/vsftpd.userlist" >> /etc/vsftpd.conf && \
    echo "userlist_deny=NO" >> /etc/vsftpd.conf

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'echo "ftpuser:${FTP_PASSWORD}" | chpasswd' >> /start.sh && \
    echo 'echo "ftpuser" > /etc/vsftpd.userlist' >> /start.sh && \
    echo 'exec vsftpd' >> /start.sh && \
    chmod +x /start.sh

# Expose port 80
EXPOSE 80

# Start FTP server
CMD ["/start.sh"]
