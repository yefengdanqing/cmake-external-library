# ML Platform 二方、三方库

* 二方库：由机器学习平台团队开发，包括各个 ml- 开头的库，以及 mxnet、seastar。
* 三方库：开源库并且没有做过修改。

# 增加库规范
1. 无论增加二方库、三方库，都需要在 check.cmake 中明确版本号，可以是 git tag、git revision 等，禁止使用分支名编译。版本号变量必须是 `_DEP_VER` 或 `_DEP_TAG`, 示例:

    ```cmake
    set(_DEP_VER 1.7.108)
    # 或
    set(_DEP_TAG 7e8df10ad24812c87d805bb05c707c96f11fb283)
    ```
2. 原则上默认生成静态库；
3. check.cmake 需要能够涵盖完整下载、解压、配置、编译等流程；
3. check.cmake 中需要加上检查版本号的代码：
    ```cmake
    CheckVersion()
    ```
    这是一个定义在根目录 check.cmake 中的 function。它会检查 `_DEP_VER` 或 `_DEP_TAG` 的值，
    并与目标目录下 VERSION.txt 的内容做比较，来判断是否需要重新编译。
    这个函数调用时需要保证 `_DEP_TAG` 或者 `_DEP_VER`，以及 `_DEP_PREFIX`、`_DEP_NAME` 这几个变量已经被赋值。

3. 当某个库和它的依赖都需要更新时，如果下游依赖并没有更新代码，那么不会自动重新编译。
这种情况可以手工删除 built 目录下面下游依赖目录，强制触发重新编译。

4. 如果依赖库使用 cmake 作为 build 系统，并且需要传递当前 $CMAKE_PREFIX_PATH 时，需要对分号转义，如下是一个示例：
    ```cmake
    string (REPLACE ";" "\\;" CMAKE_PREFIX_PATH_STR "${CMAKE_PREFIX_PATH}")
    execute_process(
        COMMAND ${CMAKE_COMMAND}
                -G Ninja
                -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_STR}
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
        RESULT_VARIABLE rc)
    ```
    原因是直接使用 ${CMAKE_PREFIX_PATH} 会形成一个分号分隔的字符串，在 shell 命令中会被截断，因此需要提前转义。

5. Push Docker 镜像之前，请先和大家 review，说明做了什么修改，以及版本信息；

# 编译、打包以及 Docker 镜像制作
1. 登录 hub.mobvista.com
    ```shell
    docker login hub.mobvista.com
    ```

    docker 请使用个人账号，防止登录信息影响其他人。个人账号使用方法：
    ```shell
    sudo groupadd docker
    sudo usermod -aG docker $USER
    ```
    然后退出重新登录，所有 docker 命令就都不需要加 sudo 了。

2. 修改 docker/VERSIONS 文件，调整相应的 tag、revision 等；

3. 创建编译环境基础镜像：
    ```shell
    bash build_centos_build_image.sh
    ```
    基础镜像主要是编译器的环境，不涉及到具体的编译。


    镜像创建后需要手工 push 到 docker hub：
    ```shell
    docker push hub.mobvista.com/ml-platform/ml-platform-thirdparty-build:0.7
    ```
    该 base 镜像依赖 docker 目录下的 Dockerfile_centos_build 文件构建，执行``` docker build  -f Dockerfile_centos_build -t docker_name```

    在当前 base 镜像（build:0.7）的基础上构建了 gpu 基础镜像：

    ```shell
    hub.mobvista.com/ml-platform/ml-platform-thirdparty-build-gpu:0.1 
    ```
    该镜像中拷贝了 GPU 机器上的 /usr/local/cuda 以及 /usr/lib64/libcud*, /usr/include/cudnn* 的相关库文件。

    *cuda Installation Instructions：*
    ```shell
    sudo wget https://developer.download.nvidia.com/compute/cuda/11.0.3/local_installers/cuda-repo-rhel7-11-0-local-11.0.3_450.51.06-1.x86_64.rpm

    sudo rpm -i cuda-repo-rhel7-11-0-local-11.0.3_450.51.06-1.x86_64.rpm
    
    sudo yum clean all
    
    sudo yum -y install nvidia-driver-latest-dkms cuda
    
    sudo yum -y install cuda-drivers
    ```

    *Install cuDNN ON linux :*
    ```base
    Procedure
    Go to: NVIDIA cuDNN home page(https://developer.nvidia.com/cudnn).
    Click Download.
    Complete the short survey and click Submit.
    Accept the Terms and Conditions. A list of available download versions of cuDNN displays.
    Select the cuDNN version you want to install. A list of available resources displays.
    ```
    cudnn 的安装通过 cmake 实现比较繁琐。于是根据官网推荐的做法（如下），合并 cudnn 和 cuda。之后将 cuda 库打入 build-gpu 镜像的 /usr/local/ 目录下。
    ```
    $ sudo cp cuda/include/cudnn*.h /usr/local/cuda/include
    $ sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64
    $ sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
    ``` 
    当且 cuda 架构为 7.5 ，且不需要常改动。因此纳入 base 镜像目前来看比较合理的，只是 build-gpu:0.1 不能像 build:0.7 形成一个完整闭环，build:0.7 可以通过 Dockerfile 文件构建, build-gpu:0.1 没有将 cuda 以及 cuDNN 的 install process 通过文件组织起来，有手动操作拷入的过程，需要搞出构建 build-gpu 的 Dockerfile 文件。
4. 编译 external 库，生成容器的中间脚本：
    
    4.1 create_library
    ```shell
    sh create_library.sh -b # 仅执行 build
    sh create_library.sh -b -v branch # 使用 external 的 branch 分支编译
    sh create_library.sh -p # 仅执行 package
    ```

    build 会编译根目录下 check.cmake 中指定的库，以及它们的依赖库，目标目录为 built/ 下依赖库名目录。

    package 会打包编译后的目录（built）目录，文件名为 ```ml-platform-thirparty-RelWithDebInfo-$(git rev-parse --short HEAD).tar.bz2，```
    然后上传到 ```s3://mob-emr-test/ml-platform/ml-thirdparty-libs/```

    如果不加 -b、-p 参数，会执行 build、package 两个步骤。

    在 external 各个子模块中，编译后都会在目标目录加上 VERSION.txt，内容是当前库的 check.cmake 中指定的版本号。
    在下次编译时，如果版本号不同，这个库会自动重新编译。在某个库需要更新时， built 目录不需要整个删除，
    只需要更新对应模块下 check.cmake 中的版本号，就会自动重编该库，而其他已经编好并且没有变化的库不受影响。

    4.2 create_image
    ```shell
    sh create_image.sh -b # 仅执行 build image
    sh create_image.sh -p # 仅执行 push image
    ```

    build 会通过这样的命令生成镜像，以一个父镜像为基础通过下载安装 aws 上已编译好的包，生成一子镜像：

    ```bash
     docker build -f docker/Dockerfile_ml_platform_dev -t ${output_images} \
        --build-arg thirdparty_build_image_tag=${base_images}             \
        --build-arg external_url=${EXTERNAL_URL}/ml-platform-${build_name}-RelWithDebInfo-${external_version}.tar.bz2 \
        --build-arg external_file_name=ml-platform-${build_name}-RelWithDebInfo-${external_version}.tar.bz2 .

    ``` 
    push 将生成的镜像上传至仓库 ```hub.mobvista.com/ml-platform```.


    4.3 compile
    ```shell
    sh compile.sh -para # 检查版本，下载，编译
    ```

    ```compile.sh ```通过不同的参数，选择不同的镜像编译库。

5. 创建开发环境镜像：
   
    |Command|Descriptions|
   | --- | --- |
   | sh build_thirdparty_build_image.sh|生成三方库镜像 ml-platform-thirdparty-build|
   | sh build_ml_image.sh|生成 RS 镜像 ml-platform-dev，编译旧版 ml- 库，旧 ml- 库已不再维护，该脚本后期不再使用|
   | sh build_unity_image.sh|生成 RS 镜像 ml-platform-unity，编译 ml-unity|
   | sh build_thirdparty_gpu_image.sh| 生成 GPU 三方库镜像 ml-platform-thirdparty-build-gpu|
   | sh build_nps_image.sh |生成 NPS 镜像 ml-predict-service-dev，编译 ml-unity，开启 USE_TORCH_CUDA options|

   一般情况下使用上述5个 build 脚本就能完成镜像的开发过程。

6. 启动镜像：
    启动镜像，需要避免用 host 中的 /data/code/ml-platform-thirdparty 目录覆盖镜像中的目录，起 docker 容器的命令可以参考：
   ```bash
    docker run -ti --net=host --cap-add=SYS_PTRACE --cap-add=SYS_NICE --security-opt seccomp=unconfined  \
               -e TERM=xterm-256color -e COLUMNS="`tput cols`" -e LINES="`tput lines`" \
               -v /home:/home -v /data:/data -v /data/code/ml-platform-thirdparty \
               hub.mobvista.com/ml-platform/ml-platform-dev:3cfe04c bash
    ```

    在 gpu 机器启动镜像参考：
    ```
    export DEVICES=$(\ls /dev/nvidia* | xargs -I{} echo '--device {}:{}')
    docker run --gpus all $DEVICES -ti --rm --net=host --name gpu-docker-env \
	   --cap-add=SYS_PTRACE --cap-add=SYS_NICE --security-opt seccomp=unconfined \
           -e TERM=xterm-256color -e COLUMNS="`tput cols`" -e LINES="`tput lines`"\
           -v /home/yf.zhao:/home/yf.zhao \
	       -w /home/yf.zhao \
           hub.mobvista.com/ml-platform/ml-platform-thirdparty-build-gpu：0.2 bash

    ```


   
    
