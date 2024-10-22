import os
import pytest
import regex as re
import pandas as pd
import numpy as np


class TestDataset:

    @pytest.fixture(autouse=True)
    def setup(self, annotated_data):
        self.base_path = "data/Split_Dataset"
        self.data_path = os.path.join(self.base_path, "Data")
        self.annotated_data_path = os.path.join(self.base_path, "Annotated_Data")
        self.ground_truth_path = os.path.join(self.base_path, "Ground_truth")
        self.files = ['test.npy', 'train.npy', 'valid.npy']
        self.annotated_files = ['test_annotated.npy', 'train_annotated.npy', 'valid_annotated.npy']
        self.ground_truth_files = ['train.tsv', 'test.tsv', 'valid.tsv']
        self.regex_pattern = re.compile(r'^(?!mesh$)mesh(?=.*\d)[a-z0-9]*')

    def test_data_files(self, annotated_data):
        if annotated_data==False:
            for file_name in self.files:
                file_path = os.path.join(self.data_path, file_name)
                assert os.path.exists(file_path), f"{file_name} is missing in {self.data_path}"
        elif annotated_data==True:
            for file_name in self.annotated_files:
                file_path = os.path.join(self.annotated_data_path, file_name)
                assert os.path.exists(file_path), f"{file_name} is missing in {self.annotated_data_path}"

    def test_content(self, annotated_data):
        if annotated_data==False:
            for file_name in self.files:
                normal_file = os.path.join(self.data_path, file_name)
                data = np.load(normal_file, allow_pickle=True)

                for i, row in enumerate(data):
                    assert len(row) == 3, f"Row {i} in {file_name} does not have three columns."
                    assert isinstance(row[0], np.ndarray), f"First column in row {i} of {file_name} is not an int."
                    assert isinstance(row[1], list), f"Second column in row {i} of {file_name} is not an array."
                    assert isinstance(row[2], list), f"Third column in row {i} of {file_name} is not an array."
                    
                    contains_annotations = not any(self.regex_pattern.search(str(item)) for item in row[2])
                    assert contains_annotations, f"Third column in row {i} of {file_name} contains annotations."
        elif annotated_data==True:
            for file_name in self.annotated_files:
                annotated_file = os.path.join(self.annotated_data_path, file_name)
                data = np.load(annotated_file, allow_pickle=True)
                
                title_rows_without_annotations = 0
                abstract_rows_without_annotations = 0

            for i, row in enumerate(data):
                assert len(row) == 3, f"Row {i} in {file_name} does not have three columns."
                assert isinstance(row[0], np.ndarray), f"First column in row {i} of {file_name} is not an int."
                assert isinstance(row[1], list), f"Second column in row {i} of {file_name} is not an array."
                assert isinstance(row[2], list), f"Third column in row {i} of {file_name} is not an array."
                
                # Check for annotations in the title (row[1])
                title_contains_annotations = any(self.regex_pattern.search(str(item)) for item in row[1])
                if not title_contains_annotations:
                    title_rows_without_annotations += 1

                # Check for annotations in the abstract (row[2])
                abstract_contains_annotations = any(self.regex_pattern.search(str(item)) for item in row[2])
                if not abstract_contains_annotations:
                    abstract_rows_without_annotations += 1

            # Assert based on the respective thresholds
            assert title_rows_without_annotations < 500, (
                f"Too many rows in title column without annotations in {file_name}: {title_rows_without_annotations}."
            )
            assert abstract_rows_without_annotations < 3000, (
                f"Too many rows in abstract column without annotations in {file_name}: {abstract_rows_without_annotations}."
            )
        
    def test_ground_truth_files(self):
        for file_name in self.ground_truth_files:
            file_path = os.path.join(self.ground_truth_path, file_name)
            assert os.path.exists(file_path), f"{file_name} is missing in {self.ground_truth_path}"
    
    def test_ground_truth_content(self):
        for file_name in self.ground_truth_files:
            ground_truth_file = os.path.join(self.ground_truth_path, file_name)
            
            df = pd.read_csv(ground_truth_file, sep='\t')

            expected_columns = ['PMID1', 'PMID2', 'Relevance']
            assert all(col in df.columns for col in expected_columns), f"Columns in the ground truth file do not match as expected: {expected_columns}"

            null_values = df['Relevance'].isnull().sum()
            assert null_values==0, f"'Relevance' column contains {null_values} null values."