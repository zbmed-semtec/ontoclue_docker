import os
import yaml
import shutil
import pytest
import tempfile
import subprocess
import regex as re
import pandas as pd

class TestRun:

    @pytest.fixture(autouse=True)
    def setup(self):
        self.base_path = "code"
        self.log_file = "output_3/Optuna_trials_3.log"
        self.evaluation_path = "output_3/evaluation"
        self.precision_file = "precision_3.tsv"
        self.parameter_file = "hyperparameters.yaml"
        self.parameter_file_path = os.path.join(self.base_path, self.parameter_file)
        with open(self.parameter_file_path, 'r') as file:
            self.content = yaml.safe_load(file)
            self.params = self.content.get('params', {})
            self.iterations = self.content.get('iterations', {})

    def test_parameters(self):
        for key, param in self.params.items():
            if 'values' in param:
                assert isinstance(param['values'], list) and len(param['values']) > 0
                assert all(isinstance(v, int) for v in param['values'])
            elif 'value' in param:
                assert isinstance(param['value'], int)
            else:
                raise AssertionError("Parameter must have either 'values' or 'value'.")

        for key, param in self.iterations.items():
            if 'values' in param:
                assert isinstance(param['values'], list) and len(param['values']) > 0
                assert all(isinstance(v, int) for v in param['values'])
            elif 'value' in param:
                assert isinstance(param['value'], int)
            else:
                raise AssertionError("Parameter must have either 'values' or 'value'.")

    def test_modify_yaml(self):
        with open(self.parameter_file_path, 'w') as file:
            yaml.dump(self.content, file)
        
        modified_data = self.content.copy()

        if 'params' in modified_data:
            if 'epochs' in modified_data['params']:
                modified_data['params']['epochs']['values'] = [1, 2]  # Change epochs for testing
        if 'iterations' in modified_data:
            if 'n_trials' in modified_data['iterations']:
                modified_data['iterations']['n_trials']['value'] = 1  # Change iterations for testing

        with open(self.parameter_file_path, 'w') as file:
            yaml.dump(modified_data, file, default_flow_style=None)

        with open(self.parameter_file_path, 'r') as file:
            updated_content = yaml.safe_load(file)

        # Assertions to verify the modifications
        assert 'params' in updated_content
        assert 'epochs' in updated_content['params']
        assert updated_content['params']['epochs']['values'] == [1, 2]

        assert 'iterations' in updated_content
        assert 'n_trials' in updated_content['iterations']
        assert updated_content['iterations']['n_trials']['value'] == 1

    def test_runs(self):

        subprocess.run(['python3', 'code/main.py', '-i', '../data/Split_Dataset/Data/train.npy', '-t', '../data/Split_Dataset/Data/test.npy', '-g', '../data/Split_Dataset/Ground_truth/test.tsv', '-c', '3', '-win', '0'], check=True)

        with open(self.log_file, 'r') as file:
            lines = file.readlines()
                
        params_line = None
        for line_no, line in enumerate(lines):
            if "Trial number: 0" in line:
                params_line = lines[line_no+1]
                match = re.search(r"Params: ({.*})", params_line)
                params_str = match.group(1)
                params_dict_one = eval(params_str)

    
        precision_df_one = pd.read_csv('output_3/evaluation/precision_3.tsv', sep='\t')
        precision_values_one = precision_df_one[-1].tolist()

        if os.path.exists('output_3'):
            shutil.rmtree('output_3')
        
        subprocess.run(['python3', 'code/main.py', '-i', '../data/Split_Dataset/Data/train.npy', '-v', '../data/Split_Dataset/Data/test.npy', '-t', '../data/Split_Dataset/Data/test.npy', '-gv', '../data/Split_Dataset/Ground_truth/test.tsv', '-gt', '../data/Split_Dataset/Ground_truth/test.tsv', '-c', '3', '-win', '0'], check=True)

        with open(self.log_file, 'r') as file:
            lines = file.readlines()

        params_line = None
        for line_no, line in enumerate(lines):
            if "Trial number: 0" in line:
                params_line = lines[line_no+1]
                match = re.search(r"Params: ({.*})", params_line)
                params_str = match.group(1)
                params_dict_two = eval(params_str)
        
        precision_df_two = pd.read_csv('output_3/evaluation/precision_3.tsv', sep='\t')
        precision_values_two = precision_df_two[-1].tolist()

        assert params_dict_one == params_dict_two, "Hyperparameter configurations differ between runs!"
        assert precision_values_one == precision_values_two, "Precision values differ between runs!"
