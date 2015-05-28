rm -rf ./data/crf ./data/folds ./data/logs ./data/models ./data/tag ./data/fold_eval
echo "Generating CRF vectors from documents..."
sh extract_vectors.sh
echo "Splitting vectors into folds..."
sh split_in_folds.sh
echo "Training models..."
sh train_models.sh
echo "Evaluation..."
sh eval_models.sh
