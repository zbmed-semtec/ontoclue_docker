# Docker Container for OntoClue

This repository contains the code for the Docker container for OntoClue. 

## About OntoClue

OntoClue is a project that explores various embedding approaches to assess document-to-document similarity using the RELISH Corpus. [RELISH](https://academic.oup.com/database/article/doi/10.1093/database/baz138/5871485?login=false) is an expert-curated database designed for benchmarking document similarity in biomedical literature and consists of PubMed IDs (PMIDs) with their expert curated corresponding document-2-document relevance assessments wrt other PMIDs. Relevance is categorized as "relevant", "partial" or "irrelevant".

This project consists of several approaches, each with detailed explanations and documentation. These approaches can be executed individually by following the instructions provided in their respective repositories.

1. [Word2doc2vec](https://github.com/zbmed-semtec/word2doc2vec-doc-relevance-training)
2. [Doc2vec](https://github.com/zbmed-semtec/doc2vec-doc-relevance-training)
3. [fastText](https://github.com/zbmed-semtec/fasttext2doc2vec-doc-relevance-training)
4. [WMD-Word2vec]()
5. [BERT]()
6. [Hybrid-pre-word2doc2vec](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/pre/word2doc2vec)
7. [Hybrid-pre-doc2vec](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/pre/doc2vec)
8. [Hybrid-pre-fasttext](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/pre/fasttext)
9. [Hybrid-pre-wmd-word2vec](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/pre/wmd-word2vec)
10. [Hybrid-post-word2doc2vec](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/post/word2doc2vec)
11. [Hybrid-post-fasttext](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/post/fasttext)
12. [Hybrid-post-wmd-word2vec](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/post/wmd-word2vec)
13. [Hybrid-postreduction-word2doc2vec](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/postreduction/word2doc2vec)
14. [Hybrid-postreduction-fasttext](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/postreduction/fasttext)
15. [Hybrid-postreduction-wmd-word2vec](https://github.com/zbmed-semtec/hybrid-doc-relevance-training/tree/dev/code/postreduction/wmd-word2vec)

## Dockerized version of OntoClue

The Docker container for this project ensures reproducibility of the runs, allowing for consistent training and evaluation of different neural network models on the document-to-document similarity within the RELISH Corpus. The entire pipeline can be executed with a few commands. This pipeline includes:

+ Cloning the corresponding repository for the selected approach, which contains all the necessary code.
+ Downloading the appropriate pre-processed datasets based on the chosen approach (normal text vs annotated text).
+ Running tests to verify dataset integrity and reproducibility of runs.
+ Evaluating the models.

**NOTE:** The datasets that are downloaded are already preprocessed using a preprocessing pipeline, as explained in the [relish-preprocessing](https://github.com/zbmed-semtec/relish-preprocessing) repository, and include annotated datasets as well. Documentation on [datasets](https://github.com/zbmed-semtec/relish-preprocessing), [data preprocessing](https://github.com/zbmed-semtec/relish-preprocessing), and [annotation](https://github.com/zbmed-semtec/relish-preprocessing) are also available.

## Requirements

In order to get started with the pipeline it is essential that you have Docker installed. Please follow the instructions below to install Docker.

### Setting up Docker on Linux

For Linux distribution like Ubuntu, Debian, CentOS, execute the following:

1. Update your existing list of packages:
```
sudo apt update
```

2. Install a few prerequisite packages which let apt use packages over HTTPS:
```
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```


3. Add the GPG key for the official Docker repository:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```


4. Add the Docker repository to APT sources:
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
```


5. Update the package database with the Docker packages:
```
sudo apt update
```


7. Install Docker:
```
sudo apt install docker-ce
```


## Getting Started


### 1. Building the Docker Image:

```
sudo docker build -t ontoclue .
```

### 2. Running the Docker Container:

```
sudo docker run -it ontoclue
```

### 3. Selecting Embedding Approach:

After running the container, you will be prompted to select an embedding approach:

![](./docs/select_approach.png)

Upon selecting an approach, the corresponding repository will be cloned from GitHub, and the appropriate datasets will be downloaded based on the chosen approach.

### 4. Running Tests:

Once the datasets are downloaded, you will have the option to run tests. These tests verify:

- If the data was downloaded to the correct directory.
- If the correct data corresponding to the selected approach was downloaded.
- Quick reproducibility checks between runs.

Depending on your preference, you can select **y** (yes) or **n** (no). You will see a prompt like this:

![](./docs/select_test.png)

### 5. Selecting Class Distribution:

After the tests are completed, you will be prompted to select the class distribution. Depending on your preference, you can select **3** (three class distribution) or **2** (two class distribution).

![](./docs/select_class.png)

Following this, you will see a message indicating that the pipeline is being initiated. This process will take a while to complete 100 iterations.

### 6. Viewing Log Files:

To view log files, enter the Docker container by executing the following commands:

#### 1. List all containers:
```
sudo docker ps -a
```

#### 2. Access the container:
```
sudo docker exec -it <container_id> /bin/bash
```

#### 3. View log files:

```
cat <name_of_the_approach>/output_{3/2}/Optuna_trials_{3/2}.log
```

### 7. Mounting a volume to the Docker Container (Optional):

Alternatively you can start the docker by attaching a volume.

#### 1. Starting a container with a volume:

```
sudo docker run -v ontoclue_volume:/<name_of_the_approach> -it ontoclue
```

This will create and mount a volume named 'ontoclue_volume' if it does not exist into the /data directory of the 'ontoclue' container

#### 2. Verify the creation of the volume.
To verify if the volume was created and mounted to the container correctly, run the following command

sudo docker inspect ontoclue_volume

This should result in:

```
[
    {
        "CreatedAt": "2024-08-06T15:05:57Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/ontoclue_volume/_data",
        "Name": "ontoclue_volume",
        "Options": null,
        "Scope": "local"
    }
]
```

#### 3. Output 

The output files will be stored in the directory ```<name_of_the_approach/output_3>``` in case of a three class distribution and ```<name_of_the_approach/output_2>``` in case of a two class distribution.

#### 4. Copying files to your local system
To copy files in your local system, find out the container ID and execute

sudo docker cp <container_ID>:/<name_of_the_approach>/output_[3/2] <path_to_local_dir>

The first path is the path in the Docker container and the second path is the path on your local system 