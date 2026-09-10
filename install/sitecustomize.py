import os
import sys

# When a local virtual environment is active ($VIRTUAL_ENV is set),
# add its site-packages to sys.path so Neovim can access project packages
# while still using ~/.venv/nvim's pynvim.
virtual_env = os.environ.get("VIRTUAL_ENV")
if virtual_env:
    py_version = f"python{sys.version_info.major}.{sys.version_info.minor}"
    site_packages = os.path.join(virtual_env, "lib", py_version, "site-packages")
    if os.path.exists(site_packages) and site_packages not in sys.path:
        sys.path.insert(0, site_packages)
