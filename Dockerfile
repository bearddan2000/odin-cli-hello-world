FROM ubuntu:latest

WORKDIR /app

RUN apt update

# Ubuntu specific issues
# - DEBIAN_FRONTEND=noninteractive prevents from asking timezone
# - --no-install-recommends prevents install extras
# - specific deps for https
#   - apt-transport-https
#   - software-properties-common
# - specific deps to set gpg key
#   - wget
#   - sudo
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-transport-https \
    software-properties-common \
    git make wget sudo

# Set key for llvm repository
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

# Read from llvm repository
# Get clang and llvm
RUN apt-get install -yq clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python3-clang

# Get latest odin build
RUN git clone https://github.com/odin-lang/Odin

RUN make -C /app/Odin

# Make executable global
RUN ln -s /app/Odin/odin /bin/odin

WORKDIR /workspace

COPY bin .

# builds and runs
ENTRYPOINT ["odin", "run"]

# -file flag means run a single file
CMD ["main.odin", "-file"]