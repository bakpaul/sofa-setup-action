        echo "------ GITHUB_WORKSPACE/sofa-setup-action ------"
        mkdir -p "$GITHUB_WORKSPACE/sofa-setup-action"
        cp "${{ github.action_path }}"/*.yml "$GITHUB_WORKSPACE/sofa-setup-action"
        ls -la "$GITHUB_WORKSPACE/sofa-setup-action"
        echo "------------------------------------------------"

        # Set executable extension
        EXE=''
        if [[ "$RUNNER_OS" == "Windows" ]]; then
          EXE='.exe'
        fi
        echo "EXE=$EXE" | tee -a $GITHUB_ENV
        echo "exe=$EXE" >> $GITHUB_OUTPUT

        if [ -n "${{ github.event.number }}" ]; then
          RUN_BRANCH="PR-${{ github.event.number }}"
        elif [ -n "${{ github.event.pull_request.number }}" ]; then
          RUN_BRANCH="PR-${{ github.event.pull_request.number }}"
        elif [ -n "${{ github.event.issue.number }}" ]; then
          RUN_BRANCH="PR-${{ github.event.issue.number }}"
        else
          RUN_BRANCH="${GITHUB_REF#refs/heads/}"
        fi
        echo "RUN_BRANCH=$RUN_BRANCH" | tee -a $GITHUB_ENV
        echo "run_branch=$RUN_BRANCH" >> $GITHUB_OUTPUT

        # Auto-setup workspace + env vars
        if [[ "${{ inputs.workspace_auto_setup }}" == "true" ]]; then
          mkdir -p "$GITHUB_WORKSPACE/src" "$GITHUB_WORKSPACE/build" "$GITHUB_WORKSPACE/install" "$GITHUB_WORKSPACE/artifact"
               WORKSPACE_SRC_PATH="$(cd $GITHUB_WORKSPACE/src      && pwd -W 2>/dev/null || pwd)"
             WORKSPACE_BUILD_PATH="$(cd $GITHUB_WORKSPACE/build    && pwd -W 2>/dev/null || pwd)"
           WORKSPACE_INSTALL_PATH="$(cd $GITHUB_WORKSPACE/install  && pwd -W 2>/dev/null || pwd)"
          WORKSPACE_ARTIFACT_PATH="$(cd $GITHUB_WORKSPACE/artifact && pwd -W 2>/dev/null || pwd)"
        else
               WORKSPACE_SRC_PATH="$GITHUB_WORKSPACE"
             WORKSPACE_BUILD_PATH="$GITHUB_WORKSPACE"
           WORKSPACE_INSTALL_PATH="$GITHUB_WORKSPACE"
          WORKSPACE_ARTIFACT_PATH="$GITHUB_WORKSPACE"
        fi
        echo "WORKSPACE_SRC_PATH=$WORKSPACE_SRC_PATH" | tee -a $GITHUB_ENV
        echo "WORKSPACE_BUILD_PATH=$WORKSPACE_BUILD_PATH" | tee -a $GITHUB_ENV
        echo "WORKSPACE_INSTALL_PATH=$WORKSPACE_INSTALL_PATH" | tee -a $GITHUB_ENV
        echo "WORKSPACE_ARTIFACT_PATH=$WORKSPACE_ARTIFACT_PATH" | tee -a $GITHUB_ENV
        echo "workspace_src_path=$WORKSPACE_SRC_PATH" >> $GITHUB_OUTPUT
        echo "workspace_build_path=$WORKSPACE_BUILD_PATH" >> $GITHUB_OUTPUT
        echo "workspace_install_path=$WORKSPACE_INSTALL_PATH" >> $GITHUB_OUTPUT
        echo "workspace_artifact_path=$WORKSPACE_ARTIFACT_PATH" >> $GITHUB_OUTPUT

        # Set default settings for ccache
        echo "CCACHE_COMPRESS=true" | tee -a $GITHUB_ENV
        echo "CCACHE_COMPRESSLEVEL=6" | tee -a $GITHUB_ENV
        echo "CCACHE_MAXSIZE=1G" | tee -a $GITHUB_ENV
        echo "CCACHE_BASEDIR=$WORKSPACE_BUILD_PATH" | tee -a $GITHUB_ENV
        echo "CCACHE_DIR=$GITHUB_WORKSPACE/.ccache" | tee -a $GITHUB_ENV

        # TODO: find a better way to handle dependency versions
        QT_INSTALL_DIR="$HOME/Qt"
        EIGEN_INSTALL_DIR="$(cd "$HOME" && pwd -W 2>/dev/null || pwd)/eigen"
        BOOST_INSTALL_DIR="/tmp/deps_cache_is_for_windows_only"
        PYBIND11_INSTALL_DIR="${{ runner.temp }}/pybind11"
        SUDO='sudo'
        if [[ "$RUNNER_OS" == "Linux" ]]; then
          BOOST_VERSION="apt-latest"
        elif [[ "$RUNNER_OS" == "macOS" ]]; then
          BOOST_VERSION="brew-latest"
        elif [[ "$RUNNER_OS" == "Windows" ]]; then
          SUDO=''
          QT_INSTALL_DIR="C:/Qt"
          EIGEN_INSTALL_DIR="C:/eigen"
          BOOST_VERSION=1.74.0
          BOOST_INSTALL_DIR="C:/boost"

          # vsdevcmd.bat is here: 'C:/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/Common7/Tools/vsdevcmd.bat'
          VS_INSTALL_DIR="$(cmd //c 'vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath')"
          VS_VSDEVCMD='cd /d '$VS_INSTALL_DIR'\Common7\Tools && VsDevCmd.bat -host_arch=amd64 -arch=amd64'
        fi

        echo "SUDO=$SUDO" | tee -a $GITHUB_ENV
        echo "QT_INSTALL_DIR=$QT_INSTALL_DIR" | tee -a $GITHUB_ENV
        echo "EIGEN_INSTALL_DIR=$EIGEN_INSTALL_DIR" | tee -a $GITHUB_ENV
        echo "BOOST_VERSION=$BOOST_VERSION" | tee -a $GITHUB_ENV
        echo "BOOST_INSTALL_DIR=$BOOST_INSTALL_DIR" | tee -a $GITHUB_ENV
        echo "PYBIND11_INSTALL_DIR=$PYBIND11_INSTALL_DIR" | tee -a $GITHUB_ENV
        echo "VS_INSTALL_DIR=$VS_INSTALL_DIR" | tee -a $GITHUB_ENV
        echo "VS_VSDEVCMD=$VS_VSDEVCMD" | tee -a $GITHUB_ENV

        echo "vs_install_dir=$VS_INSTALL_DIR" >> $GITHUB_OUTPUT
        echo "vs_vsdevcmd=$VS_VSDEVCMD" >> $GITHUB_OUTPUT