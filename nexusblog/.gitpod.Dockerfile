# Gitpod Docker Image
# This extends the standard Gitpod Java image with Node.js

FROM gitpod/workspace-full:latest

# Install Node.js (if not already included)
USER gitpod

# Configure Git
RUN git config --global user.name "Your Name" && \
    git config --global user.email "your.email@example.com"

# Keep container running
CMD ["tail", "-f", "/dev/null"]
