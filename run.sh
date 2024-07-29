#!/bin/bash

echo "======================================"
echo "Select an OntoClue Embedding Approach"
echo "======================================"
echo ""
echo "1. Word2doc2vec"
echo "2. Doc2vec"
echo "3. fastText"
echo "4. WMD-Word2vec"
echo "5. BERT"
echo "6. Hybrid-pre-word2doc2vec"
echo "7. Hybrid-pre-doc2vec"
echo "8. Hybrid-pre-fasttext"
echo "9. Hybrid-pre-wmd-word2vec"
echo "10. Hybrid-post-word2doc2vec"
echo "11. Hybrid-post-fasttext"
echo "12. Hybrid-post-wmd-word2vec"
echo "13. Hybrid-postreduction-word2doc2vec"
echo "14. Hybrid-postreduction-fasttext"
echo "15. Hybrid-postreduction-wmd-word2vec"
echo ""

read -p "Enter the number corresponding to your choice: " choice
echo "-------------------------------------------------"
echo ""

case $choice in
  1)
    echo ">> You selected: Word2doc2vec"
    echo ">> Downloading repository for Word2doc2vec."
    approach="word2doc2vec-doc-relevance-training"
    ;;
  2)
    echo ">> You selected: Doc2vec"
    echo ">> Downloading repository for Doc2vec."
    approach="doc2vec-doc-relevance-training"
    ;;
  3)
    echo ">> You selected: fastText"
    echo ">> Downloading repository for fastText."
    approach="fasttext2doc2vec-doc-relevance-training"
    ;;
  4)
    echo ">> You selected: WMD-Word2vec"
    echo ">> Downloading repository for WMD-Word2vec."
    approach="WMD-word2vec-doc-relevance-training"
    ;;
  5)
    echo ">> You selected: BERT"
    echo ">> Downloading repository for BERT."
    approach="bert-embeddings-doc-relevance"
    ;;
  6|7|8|9|10|11|12|13|14|15)
    echo ">> You selected: Hybrid approach"
    echo ">> Downloading repository for Hybrid approach."
    approach="hybrid-doc-relevance-training"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

git clone https://github.com/zbmed-semtec/${approach}.git
echo "Repository cloned successfully."
 
annotated_data_list=("7" "8" "9")

annotated_data=false
for num in "${annotated_data_list[@]}"; do
    if [[ "$choice" == "$num" ]]; then
        annotated_data=true
        break
    fi
done

sh data.sh "$approach" "$annotated_data" 

cd ${approach}

echo ""
echo "Select a class distribution for $approach approach: "
echo "2. Use a two class distribution: Relevant + Partially relevant articles vs. Non-relevant articles."
echo "3. Use a three class distribution: Relevant vs. Partially relevant vs. Non-relevant articles."
echo ""

read -p "Select a class distribution to train the model: " class
echo ">> You selected: $class distribution"
echo ""

case $class in
  2)
    echo "Using a two class distribution."
    n_class=2
    ;;
  3)
    echo "Using a three class distribution."
    n_class=3
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo ""
echo "Do you want to use the validation dataset for $approach approach: "
echo "y.Uses validation dataset to optimize hyperparameters for the model."
echo "n.Uses test dataset to optimize the hyperparameters and evaluate the model."
echo ""

read -p "Select yes or no (y/n): " validation
echo ">> You selected: $validation"
echo ""

case $validation in
  y)
    echo "Using validation datasets."
    ;;
  n)
    echo "Using test datasets."
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo "Initiating pipeline."
tail -f /dev/null