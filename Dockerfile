# syntax=docker/dockerfile:1
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
      build-essential \
      pkg-config \
      cmake \
      libzip-dev \
      libjpeg-dev

# Set up environment variables for cache directories
ENV MPLCONFIGDIR=/tmp/matplotlib-cache
ENV TRANSFORMERS_CACHE=/tmp/transformers-cache
ENV TORCH_HOME=/tmp/torch-cache
ENV VIRTUAL_ENV=/opt/venv

# Create and set permissions for cache directories
RUN mkdir -p $MPLCONFIGDIR $TRANSFORMERS_CACHE $TORCH_HOME $VIRTUAL_ENV && \
    chmod 777 $MPLCONFIGDIR $TRANSFORMERS_CACHE $TORCH_HOME

# Create a virtual environment
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Set working directory
WORKDIR /eland

# Copy the current directory contents into the container
COPY . /eland

# Install PyTorch and other dependencies
RUN pip install --no-cache-dir torch==1.13.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html && \
    pip install --no-cache-dir -e .[pytorch]

# Verify PyTorch version
RUN python -c "import torch; print(f'PyTorch version: {torch.__version__}')"

# Set the default command
CMD ["python", "-m", "eland_import_hub_model"]