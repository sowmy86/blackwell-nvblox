# blackwell-nvblox Docker Environment
# Provides a ready-to-use environment for nvblox on Blackwell (sm_120)

FROM nvidia/cuda:12.8.0-devel-ubuntu24.04

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    make \
    gcc-13 \
    g++-13 \
    libgoogle-glog-dev \
    libeigen3-dev \
    python3-pip \
    python3-dev \
    python3-setuptools \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Use GCC 13 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100

# Set environment variables
ENV INSTALL_PREFIX=/opt/nvblox
ENV CUDAARCHS=120
ENV CMAKE_PREFIX_PATH=$INSTALL_PREFIX:$CMAKE_PREFIX_PATH
ENV PKG_CONFIG_PATH=$INSTALL_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=$INSTALL_PREFIX/lib:$LD_LIBRARY_PATH

WORKDIR /opt/blackwell-nvblox

# Copy patches and build script
COPY patches/ ./patches/
COPY build.sh ./

# Make build script executable
RUN chmod +x build.sh

# Run the build script
# Note: pip install might need a virtualenv or --break-system-packages on Ubuntu 24.04
RUN ./build.sh $INSTALL_PREFIX $CUDAARCHS

# Set default command
CMD ["bash"]
