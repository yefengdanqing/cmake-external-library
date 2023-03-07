set -x
set -e
function update_gcc() {
  ls -lf /usr/bin/gcc10-* | while read f
  do
   str=$(echo $f | sed 's/.*gcc10-//g')
   update-alternatives --install /usr/bin/$str $str $f 10
  done
}
function update_python() {
    cd /usr/bin
    if [ ! -f python ]; then
        ln -s python3 python
    fi
    pip3 install -U awscli awscli-plugin-endpoint wheel
}
function update_seastar_deps() {
    local arch=x86_64
    deps_list=(
        https://download-ib01.fedoraproject.org/pub/epel/8/Everything/${arch}/Packages/c/cryptopp-8.6.0-1.el8.${arch}.rpm
        https://download-ib01.fedoraproject.org/pub/epel/8/Everything/${arch}/Packages/c/cryptopp-progs-8.6.0-1.el8.${arch}.rpm
        https://download-ib01.fedoraproject.org/pub/epel/8/Everything/${arch}/Packages/c/cryptopp-devel-8.6.0-1.el8.${arch}.rpm
        https://download-ib01.fedoraproject.org/pub/epel/8/Everything/${arch}/Packages/c/colm-0.13.0.7-1.el8.${arch}.rpm
        https://download-ib01.fedoraproject.org/pub/epel/8/Everything/${arch}/Packages/c/colm-devel-0.13.0.7-1.el8.${arch}.rpm
        https://download-ib01.fedoraproject.org/pub/epel/8/Everything/${arch}/Packages/r/ragel-7.0.0.12-2.el8.${arch}.rpm
        https://download-ib01.fedoraproject.org/pub/epel/8/Everything/${arch}/Packages/r/ragel-devel-7.0.0.12-2.el8.${arch}.rpm
        https://download-ib01.fedoraproject.org/pub/epel/8/Everything/${arch}/Packages/p/pbzip2-1.1.13-1.el8.${arch}.rpm
        https://vault.centos.org/centos/8/PowerTools/${arch}/os/Packages/ninja-build-1.8.2-1.el8.${arch}.rpm
    )
    for pkg in ${deps_list[@]}
    do
        echo $pkg
        rpm -vhi $pkg
    done
}
function update_cmake() {
    if [ -f /usr/bin/cmake/bin/cmake ];then
        return
    fi
    if [ $# -eq 0 ]; then
        arch=x86_64
    else
        arch=$1
    fi
    # arch = aarch64
    wget https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-Linux-${arch}.sh \
      -q -O /tmp/cmake-install.sh                                                                \
      && chmod u+x /tmp/cmake-install.sh                                                         \
      && mkdir /usr/bin/cmake                                                                    \
      && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake                            \
      && rm /tmp/cmake-install.sh
    cd /usr/bin/cmake/bin &&    \
    ln -s cmake cmake3
}
update_ninja() {
    if [ -f /usr/bin/ninja ]; then
        ln -s /usr/bin/ninja /usr/local/bin/ninja
    fi
    if [ -f /usr/local/bin/ninja ];then
      return
    fi
    if [ -f /usr/bin/ninja-build ]; then
        ln -s /usr/bin/ninja-build /usr/local/bin/ninja
    fi
}
if [ $# -eq 0 ]; then
    update_gcc
fi
update_python
update_cmake $(arch)
update_ninja
if [ $# -eq 1 ]; then
    update_seastar_deps x86_64
fi
