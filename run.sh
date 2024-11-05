#!/bin/bash

while true; do
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
  echo "16. Word2doc2vec using Pre-trained Word2Vec model"
  echo "17. fastText using Pre-trained fastText model"
  echo "18. WMD-Word2vec using Pre-trained Word2Vec model"
  echo ""

  read -p "Enter the number corresponding to the approach: " choice
  echo "-------------------------------------------------"
  echo ""

pre_trained=false

case $choice in
    1|16)
      echo ">> You selected: Word2doc2vec"
      echo ">> Downloading repository for Word2doc2vec."
      approach="word2doc2vec-doc-relevance-training"
      if [ "$choice" -eq 16 ]; then
        pre_trained=true
      fi
      break
      ;;
    2)
      echo ">> You selected: Doc2vec"
      echo ">> Downloading repository for Doc2vec."
      approach="doc2vec-doc-relevance-training"
      break
      ;;
    3|17)
      echo ">> You selected: fastText"
      echo ">> Downloading repository for fastText."
      approach="fasttext2doc2vec-doc-relevance-training"
      if [ "$choice" -eq 17 ]; then
        pre_trained=true
      fi
      break
      ;;
    4|18)
      echo ">> You selected: WMD-Word2vec"
      echo ">> Downloading repository for WMD-Word2vec."
      approach="wmd-word2vec-training"
      if [ "$choice" -eq 18 ]; then
        pre_trained=true
      fi
      break
      ;;
    5)
      echo ">> You selected: BERT"
      echo ">> Downloading repository for BERT."
      approach="bert-embeddings-doc-relevance-training"
      break
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
            ;;
            7)
            algorithm="doc2vec"
            echo ">> You selected: Hybrid-pre-doc2vec approach"
            ;;
            8)
            algorithm="fasttext"
            echo ">> You selected: Hybrid-pre-fasttext approach"
            ;;
            9)
            algorithm="wmd-word2vec"
            echo ">> You selected: Hybrid-pre-wmd-word2vec approach"
            ;;
          esac
        ;;
        10|11|12)
        category="post"
          case $choice in
            10)
            algorithm="word2doc2vec"
            echo ">> You selected: Hybrid-post-word2doc2vec approach"
            ;;
            11)
            algorithm="fasttext"
            echo ">> You selected: Hybrid-post-fasttext approach"
            ;;
            12)
            algorithm="wmd-word2vec"
            echo ">> You selected: Hybrid-post-wmd-word2vec approach"
            ;;
          esac
        ;;
        13|14|15)
        category="postreduction"
          case $choice in
            13)
            algorithm="word2doc2vec"
            echo ">> You selected: Hybrid-postreduction-word2doc2vec approach"
            ;;
            14)
            algorithm="fasttext"
            echo ">> You selected: Hybrid-postreduction-fasttext approach"
            ;;
            15)
            algorithm="wmd-word2vec"
            echo ">> You selected: Hybrid-postreduction-wmd-word2vec approach"
            ;;
          esac
      esac

      echo ">> Downloading repository for Hybrid approach."
      break
      ;;
    *)
      echo "Invalid choice. Please try again."
      echo ""
      ;;
  esac
done

echo ""
attempt=1
max_attempts=3

while [ $attempt -le $max_attempts ]; do
  echo "======================================"
  echo "Select how to download the repository"
  echo "======================================"
  echo ""
  echo "1. With https"
  echo "2. With ssh"
  echo ""
  read -p "Enter the number corresponding to the download method: " download_choice
  echo "-------------------------------------------------"
  echo ""

  case $download_choice in
      1)
        echo ">> You selected: With https"
        git clone https://github.com/zbmed-semtec/${approach}.git
        clone_result=$?
        ;;
      2)
        echo ">> You selected: With ssh"
        git clone git@github.com:zbmed-semtec/${approach}.git
        clone_result=$?
        ;;
      *)
        echo "Invalid choice. Please try again."
        echo ""
        ;;
  esac

  if [ $clone_result -eq 0 ]; then
      echo "Repository cloned successfully."
      break
  else
      echo "Attempt $attempt of $max_attempts failed. Retrying..."
      attempt=$((attempt+1))
      sleep 2 
  fi

  if [ $attempt -gt $max_attempts ]; then
    echo "Error: Git clone failed after $max_attempts attempts. Please check your authentication or repository URL."
    exit 1
  fi
done


annotated_data_list=("6" "7" "8" "9")

annotated_data=False
for num in "${annotated_data_list[@]}"; do
    if [[ "$choice" == "$num" ]]; then
        annotated_data=True
        break
    fi
done

./data.sh "$approach" "$annotated_data" 

cd ${approach}
git checkout dev
echo "Changed branch"

if [ "$pre_trained" = false ]; then
  while true; do
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
        echo "WARNING! This could take a minute or two."
        pytest ../tests/test_dataset.py --annotated_data "$annotated_data" 
        echo "Running tests for run reproducibility"
        echo "WARNING! This could take up to 2 to 3 hours."
        pytest ../tests/test_reproducibility.py --category "$category" --algorithm "$algorithm"
        break
        ;;
      n)
        echo "Skipping tests"
        break
        ;;
      *)
        echo "Invalid choice. Please try again."
        echo ""
        ;;
    esac
  done
else
  echo "Pre-trained model selected, skipping running tests."
fi

while true; do
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
      break
      ;;
    3)
      echo "Using a three class distribution."
      n_class=3
      break
      ;;
    *)
      echo "Invalid choice. Please try again."
      echo ""
      ;;
  esac
done

train_dataset="data/Split_Dataset/Data/train.npy"
test_dataset="data/Split_Dataset/Data/test.npy"
valid_dataset="data/Split_Dataset/Data/valid.npy"

train_annotated_dataset="data/Split_Dataset/Annotated_Data/train_annotated.npy"
test_annotated_dataset="data/Split_Dataset/Annotated_Data/test_annotated.npy"
valid_annotated_dataset="data/Split_Dataset/Annotated_Data/valid_annotated.npy"

test_ground_truth="data/Split_Dataset/Ground_truth/test.tsv"
valid_ground_truth="data/Split_Dataset/Ground_truth/valid.tsv"
mesh_pmid_dict="data/mesh_to_pmid_dict.tsv"
 
if [[ -n "$category" ]]; then
  python_script="code/${algorithm}/${category}/main.py"
else
  python_script="code/main.py"
fi

echo ">> Initiating pipeline."

if [ "$pre_trained" = true ]; then
    python3 $python_script -i $train_dataset -t $test_dataset -v $valid_dataset -gt $test_ground_truth -gv $valid_ground_truth -u 1 -c $n_class -win 0
elif [ -z "${category}" ]; then
    python3 $python_script -i $train_dataset -t $test_dataset -v $valid_dataset -gt $test_ground_truth -gv $valid_ground_truth -c $n_class -win 0
elif [ "$category" = "pre" ]; then
    python3 $python_script -i $train_annotated_dataset -t $test_annotated_dataset -v $valid_annotated_dataset -gt $test_ground_truth -gv $valid_ground_truth -c $n_class -win 0
elif [ "$category" = "post" ] || [ "$category" = "postreduction" ]; then
    python3 $python_script -i $train_dataset -t $test_dataset -v $valid_dataset -gt $test_ground_truth -gv $valid_ground_truth -dict $mesh_pmid_dict -c $n_class -win 0
else
    echo "Invalid category value: $category"
    exit 1
fi


tail -f /dev/null
