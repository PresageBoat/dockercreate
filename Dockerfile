FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

LABEL MAINTAINER=Caffe

ENV TZ=Asia/Shanghai

RUN echo "==> install build-essential and SSH server......" && \
    sed -ri -e 's/archive.ubuntu.com/mirrors.aliyun.com/g' \ 
            -e 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    rm /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get -y update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    vim git cmake \
    wget curl \
    libeigen3-dev \
    ffmpeg unzip \
    python python-pip python-future python-numpy \
    bash-completion \
    cuda-command-line-tools-10-0 \
    zlib1g-dev lsb-core \
    libgtk2.0-dev \
    pkg-config zsh \
    net-tools telnet iputils-ping \
    libprotobuf-dev protobuf-compiler \
    swig \
    gdb \
    tmux \
    openssh-server && \
    mkdir /var/run/sshd && echo "root:123456" | chpasswd && \
    sed -ri -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' \
            -e 's/#UsePAM yes/UsePAM yes/g' /etc/ssh/sshd_config && \
    rm -rf /var/lib/apt/lists/* && \
    touch .tmux.conf && \
    echo "set-option -g mouse on" >> ~/.tmux.conf && \
    echo "setw -g mode-keys vi" >> ~/.tmux.conf && \
    echo "==> build-essential and SSH server install successfully......"

RUN echo "==> oh-my-zsh install......" && \
    git clone https://gitee.com/rgbitx/ohmyzsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    cd ~/.oh-my-zsh/plugins/ && \
    git clone https://gitee.com/rgbitx/zsh-autosuggestions.git && \
    git clone https://gitee.com/rgbitx/zsh-syntax-highlighting.git && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc && \
    chsh -s /bin/zsh && \
    echo "\nset nonomatch \n" >> ~/.zshrc && \
    echo "\n##add cuda" >> ~/.zshrc && \
    echo "export PATH=/usr/local/cuda/bin:\$PATH" >> ~/.zshrc && \
    echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH \n" >> ~/.zshrc && \
    echo "==> install oh-my-zsh successfully......"

RUN echo "==> cudnn install......" && \
    cd /usr/local && \
    wget http://10.0.10.53:8080/cuda/cudnn-10.0-linux-x64-v7.6.3.30.tgz && \
    tar xzvf cudnn-10.0-linux-x64-v7.6.3.30.tgz && \
    rm cudnn-10.0-linux-x64-v7.6.3.30.tgz && \
    echo "==> cudnn install successfully......"

RUN echo "==> anaconda3 install......" && \
    cd /root/ && \
    wget -O anaconda3.sh http://10.0.10.53:8080/software/Anaconda3-2020.02-Linux-x86_64.sh && \
    /bin/bash anaconda3.sh -b -p /usr/local/anaconda3 && \
    echo "# >>> conda initialize >>> " >> ~/.zshrc && \
    echo "# !! Contents within this block are managed by 'conda init' !!" >> ~/.zshrc && \
    echo "__conda_setup=\"\$('/usr/local/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)\"" >> ~/.zshrc && \
    echo "if [ \$? -eq 0 ]; then" >> ~/.zshrc && \
    echo " eval \"\$__conda_setup\"" >> ~/.zshrc && \
    echo "else" >> ~/.zshrc && \
    echo " if [ -f \"/usr/local/anaconda3/etc/profile.d/conda.sh\" ]; then" >> ~/.zshrc && \
    echo " . \"/usr/local/anaconda3/etc/profile.d/conda.sh\"" >> ~/.zshrc && \
    echo " else" >> ~/.zshrc && \
    echo " export PATH=\"/usr/local/anaconda3/bin:\$PATH\"" >> ~/.zshrc && \
    echo " fi" >> ~/.zshrc && \
    echo "fi" >> ~/.zshrc && \
    echo "unset __conda_setup" >> ~/.zshrc && \
    echo "# <<< conda initialize <<< \n" >> ~/.zshrc && \
    touch ~/.condarc && \
    echo "channels:" >> ~/.condarc && \
    echo " - https://mirrors.ustc.edu.cn/anaconda/pkgs/main/" >> ~/.condarc && \
    echo " - https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/" >> ~/.condarc && \
    echo " - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/" >> ~/.condarc && \
    echo " - defaults" >> ~/.condarc && \
    echo "show_channel_urls: true" >> ~/.condarc && \
    rm anaconda3.sh && \
    echo "==> install anaconda3 successfully......"

ENV PATH=/usr/local/anaconda3/bin:$PATH

RUN pip config set global.index-url http://mirrors.aliyun.com/pypi/simple && \
    pip config set install.trusted-host mirrors.aliyun.com && \
    pip install -U pip

RUN echo "==> opencv compile and install......" && \
    cd /root/ && \
    wget -O opencv-3.4.2.tar ftp://common:common@10.0.10.53:21/opencv/opencv-3.4.2.tar && \
    tar xvf opencv-3.4.2.tar && \
    rm opencv-3.4.2.tar && \
    cd opencv-3.4.2 && mkdir build && \
    cd build && \
    cmake -D CMAKE_INSTALL_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local/ .. && \
    make -j16 && make install && cd /root/ && rm -rf opencv-3.4.2 && \
    echo "==> opencv install successfully..."

RUN echo "==> tensorrt install......" && \
    cd /root/ && \
    wget http://10.0.10.53:8080/tensorrt/7.0.0.11/cuda10.0/TensorRT-7.0.0.11.tar && \
    tar xvf TensorRT-7.0.0.11.tar && \
    rm TensorRT-7.0.0.11.tar && \
    mv TensorRT-7.0.0.11 /usr/local && \
    echo "\n## add tensorrt" >> ~/.zshrc && \
    echo "export LD_LIBRARY_PATH=/usr/local/TensorRT-7.0.0.11/lib:\$LD_LIBRARY_PATH \n" >> ~/.zshrc && \
    echo "==> tensorrt install successfully..."

RUN pip install torch torchvision torchsummary  

# RUN echo "==> install ros......" && \
#     sh -c '. /etc/lsb-release && \
#             echo "deb http://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > \
#             /etc/apt/sources.list.d/ros-latest.list' && \
#     apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
#     apt-get -y update && \
#     DEBIAN_FRONTEND=noninteractive apt-get install -y ros-melodic-desktop && \
#     echo "source /opt/ros/melodic/setup.zsh" >> ~/.zshrc && \
#     /bin/zsh -c "source ~/.zshrc" && \
#     echo "==> ros install successfully......"

