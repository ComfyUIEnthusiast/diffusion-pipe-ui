# Docker_Diffusion-Pipe
Currently I have to pip reinstall flash-attn from the startup scripts. Not sure why, probably to do with me not versioning any of my packages :)
	
Add a wslconfig to grant more shared memory to the wsl environment if running on windows (alternatively modify the docker compose file to include ipc: host):

	[wsl2]
	memory=72GB
	swap=96GB

Update the dataset.toml to point at the correct dataset, and update settings in config.toml

Run this in the diffusion-pipe directory:

	NCCL_P2P_DISABLE="1" NCCL_IB_DISABLE="1" deepspeed --num_gpus=1 train.py --deepspeed --config /configs/config.toml

To continue training from an existing LoRA, uncomment the line config.toml for "init_from_existing", and point it at a directory with an adapter_model.safetensors

To continue from checkpoint:

	NCCL_P2P_DISABLE="1" NCCL_IB_DISABLE="1" deepspeed --num_gpus=1 train.py --deepspeed --config /configs/config.toml --resume_from_checkpoint