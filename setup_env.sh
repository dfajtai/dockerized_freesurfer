#!/bin/bash

# Create a virtual environment named 'env'
python -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install packages from requirements.txt
pip install -r requirements.txt

# Create a VS Code configuration file to use the virtual environment
mkdir -p .vscode
cat > .vscode/settings.json <<EOF
{
    "python.pythonPath": "${PWD}/venv/bin/python"
}
EOF

echo "Virtual environment 'venv' created and configured for VS Code."
echo "To activate the environment manually, run: source venv/bin/activate"