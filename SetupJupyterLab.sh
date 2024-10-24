
# With RISE, a Jupyter notebook extension, you can instantly turn your jupyter notebook into a live reveal.js-based presentation.

# not needed any more ?
# jupyter-nbextension install rise --py --sys-prefix
# jupyter-nbextension enable rise --py --sys-prefix

if [ "$1" != "" ]; then
    echo "Git Repo $1 requested..."
    cd /workspace/
    git clone $1
fi

export SHELL=/bin/bash

# setting up users
if [ "$OWNER" != "" ] && [ "$CONNECT_GROUP" != "" ]; then
    PATH=$PATH:/usr/sbin
    #/sync_users_debian.sh -u root."$CONNECT_GROUP" -g root."$CONNECT_GROUP" -e https://api.ci-connect.net:18080
    groupadd $CONNECT_GROUP -g $CONNECT_GID
    useradd -M -u $OWNER_UID -G $CONNECT_GROUP $OWNER
    # Do not leak some important tokens
    unset API_TOKEN
    # Ensure the owner owns their home directory ## Commented out 7/17 by L.B., causing issues with taking too long
    #chown -R $OWNER: /home/$OWNER
    # Set the user's $DATA dir
    export DATA=/data/$OWNER
    # Match PS1 as we have it on the login nodes
    echo 'export PS1="[\A] \H:\w $ "' >> /etc/bash.bashrc
    # Chown the /workspace directory so users can create notebooks
    chown -R $OWNER: /workspace
    # Change to the user's homedir
    cd /home/$OWNER
    # get tutorial in.
    cp -r /ML_platform_tests/tutorial ~/.

    # setup ROOT
    cd /opt/root/
    source bin/thisroot.sh
    cp -r $ROOTSYS/etc/notebook/kernels/root /usr/local/share/jupyter/kernels/

    # Root-pandas does not recognize 6.32.04 root version?
    # python -m pip --no-cache-dir install  root-pandas 
    
    unset JUPYTER_PATH
    unset JUPYTER_CONFIG_DIR
    cd /home/$OWNER

    # Invoke Jupyter lab as the user
    su $OWNER -c ". base/bin/activate && jupyter lab --ServerApp.root_dir=/home/${OWNER} --no-browser --config=/usr/local/etc/jupyter_notebook_config.py"

fi 
