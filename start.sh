cp -r -u /importModels/* /models
pip uninstall -y flash-attn
pip install flash-attn
jupyter notebook --NotebookApp.token=$JUPYTER_TOKEN --NotebookApp.ip='0.0.0.0' --port $JUPYTER_PORT --allow-root & 
wait