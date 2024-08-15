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
        self.test_dir_1 = "../tests/run_one"
        self.test_dir_2 = "../tests/run_two"
        self.log_file = "output_3/Optuna_trials_3.log"
        self.evaluation_path = "output_3/evaluation"
        self.parameter_file = "hyperparameters.yaml"
        self.precision_file = os.path.join(self.evaluation_path, "precision_3.tsv")
        self.parameter_file_path = os.path.join(self.base_path, self.parameter_file)
        with open(self.parameter_file_path, 'r') as file:
            self.content = yaml.safe_load(file)
            self.params = self.content.get('params', {})
            self.iterations = self.content.get('iterations', {})
        
        os.makedirs(self.test_dir_1, exist_ok=True)
        os.makedirs(self.test_dir_2, exist_ok=True)


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
                modified_data['iterations']['n_trials']['value'] = 3  # Change iterations for testing

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
        assert updated_content['iterations']['n_trials']['value'] == 3

    def test_runs(self):

        run_trials = {}
        for run in range(1, 3):
            subprocess.run(['python3', 'code/main.py', '-i', 'data/Split_Dataset/Data/train.npy', '-t', 'data/Split_Dataset/Data/test.npy', '-g', 'data/Split_Dataset/Ground_truth/test.tsv', '-c', '3', '-win', '0'], check=True)

            with open(self.log_file, 'r') as file:
                lines = file.readlines()
            run_trials[run] = {}
            params_line = None
            for trial_no in range(3):
                for line_no, line in enumerate(lines):
                    if f"Trial number: {trial_no}" in line:
                        params_line = lines[line_no+1]
                        match = re.search(r"Params: ({.*})", params_line)
                        params_str = match.group(1)
                        run_trials[run][trial_no] = eval(params_str)
        
            precision_df_one = pd.read_csv(self.precision_file, sep='\t')
            run_trials[run]['precision'] = precision_df_one.iloc[-1].tolist()
            
            test_dir_log_filename = f'test_dir_{run}'
            test_dir = getattr(self, test_dir_log_filename)

            shutil.copy(self.log_file, os.path.join(test_dir, 'Optuna_trials_3.log'))
            shutil.copy(self.precision_file, os.path.join(test_dir, 'precision_3.tsv'))
        
        assert run_trials[1][0] == run_trials[2][0], "Hyperparameter configurations differ between runs: trial one!"
        assert run_trials[1][1] == run_trials[2][1], "Hyperparameter configurations differ between runs: trial two!"
        assert run_trials[1][2] == run_trials[2][2], "Hyperparameter configurations differ between runs: trial three!"
        assert run_trials[1]['precision'] == run_trials[2]['precision'], "Precision values differ between runs!"
        
        if os.path.exists('output_3'):
            shutil.rmtree('output_3')

    def test_remodify_yaml(self):

        original_data = self.content.copy()

        if 'params' in original_data:
            if 'epochs' in original_data['params']:
                original_data['params']['epochs']['values'] = [5, 15]  # Change epochs for testing
        if 'iterations' in original_data:
            if 'n_trials' in original_data['iterations']:
                original_data['iterations']['n_trials']['value'] = 100 # Change iterations for testing

        with open(self.parameter_file_path, 'w') as file:
            yaml.dump(original_data, file, default_flow_style=None)

        with open(self.parameter_file_path, 'r') as file:
            updated_original_content = yaml.safe_load(file)


        # Assertions to verify the modifications
        assert 'params' in updated_original_content
        assert 'epochs' in updated_original_content['params']
        assert updated_original_content['params']['epochs']['values'] == [5, 15]

        assert 'iterations' in updated_original_content
        assert 'n_trials' in updated_original_content['iterations']
        assert updated_original_content['iterations']['n_trials']['value'] == 100