# Yolo local env setup
- follow to official website tutorial
```
https://docs.ultralytics.com/quickstart/#how-do-i-clone-the-ultralytics-repository-for-development
```
### Clone the ultralytics repository
```
git clone https://github.com/ultralytics/ultralytics
```
### Navigate to the cloned directory
```
cd ultralytics
```
### Install the package in editable mode for development
```
pip install -e .
```
### If error
ERROR: Project file:///home/arbor/Downloads/ultralytics has a 'pyproject.toml' and its build backend is missing the 'build_editable' hook. Since it does not have a 'setup.py' nor a 'setup.cfg', it cannot be installed in editable mode. Consider using a build backend that supports PEP 660.
```
pip install -U pip
```
