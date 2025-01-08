# Use Ubuntu as a base image
FROM ubuntu:20.04

# Install required packages
RUN apt-get update && apt-get install -y \
    rclone \
    vsftpd \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create the necessary directory for rclone configuration
RUN mkdir -p /root/.config/rclone

# Copy rclone configuration file into the container
COPY rclone.conf /root/.config/rclone/rclone.conf

# Create a user for FTP access
RUN useradd -m ftpuser && echo "ftpuser:password" | chpasswd

# Expose FTP port
EXPOSE 21

# Configure vsftpd for local user access
RUN echo "listen=0.0.0.0" >> /etc/vsftpd.conf \
    && echo "listen_ipv6=NO" >> /etc/vsftpd.conf \
    && echo "anonymous_enable=NO" >> /etc/vsftpd.conf \
    && echo "local_enable=YES" >> /etc/vsftpd.conf \
    && echo "write_enable=YES" >> /etc/vsftpd.conf \
    && echo "chroot_local_user=YES" >> /etc/vsftpd.conf \
    && echo "user_sub_token=$USER" >> /etc/vsftpd.conf \
    && echo "local_root=/home/ftpuser/rclone" >> /etc/vsftpd.conf

# Mount Google Drive and start FTP server
CMD rclone mount remote:/ /home/ftpuser/rclone --vfs-cache-mode full --allow-other --log-level DEBUG --log-file /var/log/rclone.log & \
    /usr/sbin/vsftpd /etc/vsftpd.conf --log-file /var/log/vsftpd.log
