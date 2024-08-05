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
    approach="bert-embeddings-doc-relevance-training"
    ;;
  6|7|8|9|10|11|12|13|14|15)
    approach="hybrid-doc-relevance-training"

    case $choice in
      6|7|8|9)
      category="pre"
        case $choice in
          6)
          algorithm="word2doc2vec"
          echo ">> You selected: Hybrid-pre-word2doc2vec approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
          7)
          algorithm="doc2vec"
          echo ">> You selected: Hybrid-pre-doc2vec approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
          8)
          algorithm="fasttext"
          echo ">> You selected: Hybrid-pre-fasttext approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
          9)
          algorithm="wmd-word2vec"
          echo ">> You selected: Hybrid-pre-wmd-word2vec approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
        esac
      ;;
      10|11|12)
      category="post"
        case $choice in
          10)
          algorithm="word2doc2vec"
          echo ">> You selected: Hybrid-post-word2doc2vec approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
          11)
          algorithm="fasttext"
          echo ">> You selected: Hybrid-post-fasttext approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
          12)
          algorithm="wmd-word2vec"
          echo ">> You selected: Hybrid-post-wmd-word2vec approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
        esac
      ;;
      13|14|15)
      category="postreduction"
        case $choice in
          13)
          algorithm="word2doc2vec"
          echo ">> You selected: Hybrid-postreduction-word2doc2vec approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
          14)
          algorithm="fasttext"
          echo ">> You selected: Hybrid-postreduction-fasttext approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
          15)
          algorithm="wmd-word2vec"
          echo ">> You selected: Hybrid-postreduction-wmd-word2vec approach"
          echo ">> Downloading repository for Hybrid approach."
          ;;
        esac
    esac
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo ""
git clone https://github.com/zbmed-semtec/${approach}.git
echo "Repository cloned successfully."


annotated_data_list=("6" "7" "8" "9")

annotated_data=false
for num in "${annotated_data_list[@]}"; do
    if [[ "$choice" == "$num" ]]; then
        annotated_data=true
        break
    fi
done

sh data.sh "$approach" "$annotated_data" 

cd ${approach}
git checkout dev
echo "Changed branch"

echo ""
echo "Do you want to run tests for the ${approach} approach?"
echo "y. Run test for checking the datasets and reproducibility of the runs."
echo "n. Skip running test and execute the ${approach} pipeline."
echo ""

read -p "Select yes or no (y/n): " test
echo ">> You selected: $test"
echo ""

case $test in
  y)
    echo "Running tests for dataset"
    pytest ../tests/test_dataset.py
    echo $(pwd)
    echo "Running tests for reproducible runs"
    pytest ../tests/test_reproducibility.py
    ;;
  n)
    echo "Skipping tests"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

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

train_dataset="data/Split_Dataset/Data/train.npy"
test_dataset="data/Split_Dataset/Data/test.npy"
test_ground_truth="data/Split_Dataset/Ground_truth/test.tsv"

echo $(pwd)
 
if [[ -n "$category" ]]; then
  python_script="code/${category}/${algorithm}/main.py"
else
  python_script="code/main.py"
fi

echo ">> Initiating pipeline."

python3 $python_script -i $train_dataset -t $test_dataset -g $test_ground_truth -c $n_class -win 0

tail -f /dev/null
