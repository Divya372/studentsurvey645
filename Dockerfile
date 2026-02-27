# Dockerfile
# Author: Divya Soni
# Course: SWE645 - Assignment 2
# Purpose: Containerizes the student survey web application using Apache httpd server

FROM httpd:2.4

# Copy website files to Apache's web directory
COPY index.html /usr/local/apache2/htdocs/
COPY survey.html /usr/local/apache2/htdocs/
COPY error.html /usr/local/apache2/htdocs/
COPY campus.jpg /usr/local/apache2/htdocs/

# Expose port 80
EXPOSE 80

# Apache httpd runs automatically when container starts
