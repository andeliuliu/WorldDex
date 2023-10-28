FROM python:3.8-slim-buster

# Set working directory
WORKDIR /workspace

# Install git and clone GroundingDINO repository
RUN apt-get update && apt-get install -y git && \
    git clone https://github.com/IDEA-Research/GroundingDINO.git /workspace/GroundingDINO && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install torch and any other dependencies
RUN pip install --no-cache-dir torch

# Install GroundingDINO
RUN pip install --no-cache-dir -e /workspace/GroundingDINO

# Set default command
CMD ["python"]