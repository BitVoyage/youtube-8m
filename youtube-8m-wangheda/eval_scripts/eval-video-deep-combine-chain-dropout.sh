GPU_ID=0
EVERY=100
MODEL=DeepCombineChainModel
MODEL_DIR="../model/video_chain_moe4_deep_combine_dropout/input_dropout_0.8"

start=$1
DIR="$(pwd)"

for checkpoint in $(cd $MODEL_DIR && python ${DIR}/training_utils/select.py $EVERY); do
        echo $checkpoint;
        if [ $checkpoint -gt $start ]; then
                echo $checkpoint;
                CUDA_VISIBLE_DEVICES=$GPU_ID python eval.py \
                        --train_dir="$MODEL_DIR" \
                        --model_checkpoint_path="${MODEL_DIR}/model.ckpt-${checkpoint}" \
                        --eval_data_pattern="/Youtube-8M/data/video/validate/validatea*" \
                        --frame_features=False \
                        --feature_names="mean_rgb,mean_audio" \
                        --feature_sizes="1024,128" \
			--moe_num_mixtures=4 \
			--deep_chain_layers=4 \
			--deep_chain_relu_cells=256 \
			--label_loss=MultiTaskCrossEntropyLoss \
			--multitask=True \
			--support_type="label,label,label,label" \
			--support_loss_percent=0.05 \
                        --batch_size=128 \
                        --model=$MODEL \
                        --run_once=True
        fi
done

