import matplotlib
try:
    # matplotlib.use('MacOSX')
    matplotlib.use('TkAgg')
    import matplotlib.pyplot as plt
except ImportError:
    matplotlib.use('TkAgg')
    import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import _add_sandbox_paths
