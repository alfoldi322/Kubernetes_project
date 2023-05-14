FROM ubuntu:18.04

# Install apache2, unzip, curl
RUN apt-get update && apt-get install -y apache2 unzip curl
# Download and extract the zip file
RUN mkdir -p /var/www/html && \
    cd /var/www/html && \
    curl -L https://www.free-css.com/assets/files/free-css-templates/download/page289/greenhost.zip -o greenhost.zip && \
    unzip greenhost.zip && \
    rm greenhost.zip && \
    mv web-hosting-html-template/* . && \
    rm -r web-hosting-html-template

# Set Apache's default page to index.html
RUN sed -i 's/DirectoryIndex.*/DirectoryIndex index.html/g' /etc/apache2/mods-enabled/dir.conf

# Set the ServerName directive to suppress warning message
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf


EXPOSE 80

# Start apache2 in the foreground
CMD ["apachectl", "-D", "FOREGROUND"]
